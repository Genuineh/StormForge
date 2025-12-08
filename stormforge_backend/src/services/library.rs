use anyhow::{anyhow, Result};
use futures_util::stream::TryStreamExt;
use mongodb::{
    bson::{doc, DateTime as BsonDateTime, oid::ObjectId},
    Collection, Database,
};

use crate::models::{
    AddReferenceRequest, ComponentReference, ComponentReferenceMode, ComponentStatus,
    ComponentVersion, ImpactAnalysis, LibraryComponent, LibraryScope, ProjectImpact,
    PublishComponentRequest, UpdateVersionRequest, UsageStats,
};

#[derive(Clone)]
pub struct LibraryService {
    components: Collection<LibraryComponent>,
    versions: Collection<ComponentVersion>,
    references: Collection<ComponentReference>,
}

impl LibraryService {
    pub fn new(db: &Database) -> Self {
        Self {
            components: db.collection("library_components"),
            versions: db.collection("component_versions"),
            references: db.collection("component_references"),
        }
    }

    /// Create and publish a new component
    pub async fn publish_component(
        &self,
        request: PublishComponentRequest,
    ) -> Result<LibraryComponent> {
        // Check if component with same namespace exists
        if let Ok(_existing) = self.find_by_namespace(&request.namespace).await {
            return Err(anyhow!(
                "Component with namespace '{}' already exists",
                request.namespace
            ));
        }

        // Validate version format (should be semantic versioning)
        if !Self::is_valid_version(&request.version) {
            return Err(anyhow!(
                "Invalid version format. Use semantic versioning (e.g., 1.0.0)"
            ));
        }

        let now = BsonDateTime::now();
        let component = LibraryComponent {
            id: Some(ObjectId::new()),
            name: request.name.clone(),
            namespace: request.namespace,
            scope: request.scope,
            component_type: request.component_type,
            version: request.version.clone(),
            description: request.description,
            author: request.author.clone(),
            organization_id: request.organization_id,
            tags: request.tags,
            definition: request.definition.clone(),
            metadata: serde_json::Value::Object(serde_json::Map::new()),
            status: ComponentStatus::Active,
            usage_stats: UsageStats::default(),
            created_at: now,
            updated_at: now,
        };

        self.components.insert_one(&component, None).await?;

        // Save initial version
        let component_id = component
            .id
            .as_ref()
            .ok_or_else(|| anyhow!("Component ID not set"))?
            .to_string();

        let version = ComponentVersion {
            id: Some(ObjectId::new()),
            component_id: component_id.clone(),
            version: request.version,
            definition: request.definition,
            change_notes: "Initial version".to_string(),
            author: request.author.unwrap_or_else(|| "Unknown".to_string()),
            created_at: now,
        };

        self.versions.insert_one(&version, None).await?;

        Ok(component)
    }

    /// Find component by ID
    pub async fn find_by_id(&self, id: &str) -> Result<LibraryComponent> {
        let oid = ObjectId::parse_str(id)?;
        let component = self
            .components
            .find_one(doc! { "_id": oid }, None)
            .await?
            .ok_or_else(|| anyhow!("Component not found"))?;

        Ok(component)
    }

    /// Find component by namespace
    pub async fn find_by_namespace(&self, namespace: &str) -> Result<LibraryComponent> {
        let component = self
            .components
            .find_one(doc! { "namespace": namespace }, None)
            .await?
            .ok_or_else(|| anyhow!("Component not found"))?;

        Ok(component)
    }

    /// List components by scope
    pub async fn list_by_scope(&self, scope: LibraryScope) -> Result<Vec<LibraryComponent>> {
        let scope_str = match scope {
            LibraryScope::Enterprise => "enterprise",
            LibraryScope::Organization => "organization",
            LibraryScope::Project => "project",
        };

        let cursor = self
            .components
            .find(doc! { "scope": scope_str }, None)
            .await?;
        let components = cursor.try_collect().await?;

        Ok(components)
    }

    /// Search components
    pub async fn search(&self, query: &str) -> Result<Vec<LibraryComponent>> {
        let filter = doc! {
            "$or": [
                { "name": { "$regex": query, "$options": "i" } },
                { "description": { "$regex": query, "$options": "i" } },
                { "tags": { "$in": [query] } }
            ]
        };

        let cursor = self.components.find(filter, None).await?;
        let components = cursor.try_collect().await?;

        Ok(components)
    }

    /// Update component version
    pub async fn update_version(
        &self,
        component_id: &str,
        request: UpdateVersionRequest,
    ) -> Result<LibraryComponent> {
        let component = self.find_by_id(component_id).await?;

        // Validate new version is higher
        if !Self::is_newer_version(&request.new_version, &component.version) {
            return Err(anyhow!(
                "New version must be higher than current version"
            ));
        }

        // Update component
        let oid = ObjectId::parse_str(component_id)?;
        let update = doc! {
            "$set": {
                "version": &request.new_version,
                "definition": mongodb::bson::to_bson(&request.definition)?,
                "updated_at": BsonDateTime::now(),
            }
        };

        self.components
            .update_one(doc! { "_id": oid }, update, None)
            .await?;

        // Save version history
        let version = ComponentVersion {
            id: Some(ObjectId::new()),
            component_id: component_id.to_string(),
            version: request.new_version.clone(),
            definition: request.definition,
            change_notes: request.change_notes,
            author: request.author,
            created_at: BsonDateTime::now(),
        };

        self.versions.insert_one(&version, None).await?;

        self.find_by_id(component_id).await
    }

    /// Delete component
    pub async fn delete_component(&self, id: &str) -> Result<()> {
        let oid = ObjectId::parse_str(id)?;

        // Check if component is being used
        let references = self.find_references_by_component(id).await?;
        if !references.is_empty() {
            return Err(anyhow!(
                "Cannot delete component: it is being used by {} project(s)",
                references.len()
            ));
        }

        self.components
            .delete_one(doc! { "_id": oid }, None)
            .await?;

        Ok(())
    }

    /// List component versions
    pub async fn list_versions(&self, component_id: &str) -> Result<Vec<ComponentVersion>> {
        let cursor = self
            .versions
            .find(doc! { "component_id": component_id }, None)
            .await?;
        let versions = cursor.try_collect().await?;

        Ok(versions)
    }

    /// Add component reference to project
    pub async fn add_reference(
        &self,
        project_id: &str,
        request: AddReferenceRequest,
    ) -> Result<ComponentReference> {
        // Check if reference already exists
        let existing = self
            .references
            .find_one(
                doc! {
                    "project_id": project_id,
                    "component_id": &request.component_id
                },
                None,
            )
            .await?;

        if existing.is_some() {
            return Err(anyhow!(
                "Component reference already exists in this project"
            ));
        }

        // Get component to lock version
        let component = self.find_by_id(&request.component_id).await?;

        let reference = ComponentReference {
            id: Some(ObjectId::new()),
            project_id: project_id.to_string(),
            component_id: request.component_id,
            version: component.version,
            mode: request.mode,
            added_at: BsonDateTime::now(),
        };

        self.references.insert_one(&reference, None).await?;

        // Update usage stats
        self.update_usage_stats(&reference.component_id).await?;

        Ok(reference)
    }

    /// Remove component reference from project
    pub async fn remove_reference(&self, project_id: &str, component_id: &str) -> Result<()> {
        self.references
            .delete_one(
                doc! {
                    "project_id": project_id,
                    "component_id": component_id
                },
                None,
            )
            .await?;

        // Update usage stats
        self.update_usage_stats(component_id).await?;

        Ok(())
    }

    /// Find references by project
    pub async fn find_references_by_project(
        &self,
        project_id: &str,
    ) -> Result<Vec<ComponentReference>> {
        let cursor = self
            .references
            .find(doc! { "project_id": project_id }, None)
            .await?;
        let references = cursor.try_collect().await?;

        Ok(references)
    }

    /// Find references by component
    pub async fn find_references_by_component(
        &self,
        component_id: &str,
    ) -> Result<Vec<ComponentReference>> {
        let cursor = self
            .references
            .find(doc! { "component_id": component_id }, None)
            .await?;
        let references = cursor.try_collect().await?;

        Ok(references)
    }

    /// Update component usage statistics
    pub async fn update_usage_stats(&self, component_id: &str) -> Result<()> {
        let references = self.find_references_by_component(component_id).await?;

        let project_ids: std::collections::HashSet<_> =
            references.iter().map(|r| r.project_id.clone()).collect();

        let stats = UsageStats {
            project_count: project_ids.len() as i32,
            reference_count: references.len() as i32,
            last_used: Some(BsonDateTime::now()),
        };

        let oid = ObjectId::parse_str(component_id)?;
        let update = doc! {
            "$set": {
                "usage_stats": mongodb::bson::to_bson(&stats)?
            }
        };

        self.components
            .update_one(doc! { "_id": oid }, update, None)
            .await?;

        Ok(())
    }

    /// Analyze impact of component changes
    pub async fn analyze_impact(&self, component_id: &str) -> Result<ImpactAnalysis> {
        let references = self.find_references_by_component(component_id).await?;

        let mut affected_projects = Vec::new();

        for reference in &references {
            // In a real implementation, we would fetch project details
            // For now, we'll use project_id as project_name
            affected_projects.push(ProjectImpact {
                project_id: reference.project_id.clone(),
                project_name: format!("Project {}", reference.project_id),
                current_version: reference.version.clone(),
                reference_mode: reference.mode.clone(),
            });
        }

        Ok(ImpactAnalysis {
            component_id: component_id.to_string(),
            affected_projects,
            total_references: references.len() as i32,
        })
    }

    // Helper functions

    fn is_valid_version(version: &str) -> bool {
        let parts: Vec<&str> = version.split('.').collect();
        if parts.len() != 3 {
            return false;
        }

        parts.iter().all(|p| p.parse::<u32>().is_ok())
    }

    fn is_newer_version(new: &str, old: &str) -> bool {
        let new_parts: Vec<u32> = new.split('.').filter_map(|p| p.parse().ok()).collect();
        let old_parts: Vec<u32> = old.split('.').filter_map(|p| p.parse().ok()).collect();

        if new_parts.len() != 3 || old_parts.len() != 3 {
            return false;
        }

        for i in 0..3 {
            if new_parts[i] > old_parts[i] {
                return true;
            }
            if new_parts[i] < old_parts[i] {
                return false;
            }
        }

        false
    }
}
