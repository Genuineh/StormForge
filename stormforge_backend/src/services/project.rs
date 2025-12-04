use anyhow::{anyhow, Result};
use mongodb::{bson::doc, Collection, Database};
use chrono::Utc;
use futures_util::stream::TryStreamExt;

use crate::models::{Project, ProjectVisibility, ProjectSettings};

#[derive(Clone)]
pub struct ProjectService {
    projects: Collection<Project>,
}

impl ProjectService {
    pub fn new(db: &Database) -> Self {
        Self {
            projects: db.collection("projects"),
        }
    }

    pub async fn create_project(
        &self,
        name: String,
        namespace: String,
        description: String,
        owner_id: String,
        visibility: ProjectVisibility,
    ) -> Result<Project> {
        // Check if namespace already exists
        if self.find_by_namespace(&namespace).await.is_ok() {
            return Err(anyhow!("Namespace already exists"));
        }

        let project = Project::new(name, namespace, description, owner_id, visibility);
        self.projects.insert_one(&project, None).await?;

        Ok(project)
    }

    pub async fn find_by_id(&self, id: &str) -> Result<Project> {
        let project = self.projects
            .find_one(doc! { "id": id }, None)
            .await?
            .ok_or_else(|| anyhow!("Project not found"))?;

        Ok(project)
    }

    pub async fn find_by_namespace(&self, namespace: &str) -> Result<Project> {
        let project = self.projects
            .find_one(doc! { "namespace": namespace }, None)
            .await?
            .ok_or_else(|| anyhow!("Project not found"))?;

        Ok(project)
    }

    pub async fn list_by_owner(&self, owner_id: &str) -> Result<Vec<Project>> {
        let cursor = self.projects
            .find(doc! { "owner_id": owner_id }, None)
            .await?;
        let projects = cursor.try_collect().await?;

        Ok(projects)
    }

    pub async fn list_public_projects(&self) -> Result<Vec<Project>> {
        let cursor = self.projects
            .find(doc! { "visibility": "public" }, None)
            .await?;
        let projects = cursor.try_collect().await?;

        Ok(projects)
    }

    pub async fn update_project(
        &self,
        id: &str,
        name: Option<String>,
        description: Option<String>,
        visibility: Option<ProjectVisibility>,
        settings: Option<ProjectSettings>,
    ) -> Result<Project> {
        let mut update_doc = doc! { "updated_at": mongodb::bson::to_bson(&Utc::now())? };

        if let Some(n) = name {
            update_doc.insert("name", n);
        }
        if let Some(d) = description {
            update_doc.insert("description", d);
        }
        if let Some(v) = visibility {
            update_doc.insert("visibility", mongodb::bson::to_bson(&v)?);
        }
        if let Some(s) = settings {
            update_doc.insert("settings", mongodb::bson::to_bson(&s)?);
        }

        self.projects
            .update_one(
                doc! { "id": id },
                doc! { "$set": update_doc },
                None,
            )
            .await?;

        self.find_by_id(id).await
    }

    pub async fn delete_project(&self, id: &str) -> Result<()> {
        let result = self.projects
            .delete_one(doc! { "id": id }, None)
            .await?;

        if result.deleted_count == 0 {
            return Err(anyhow!("Project not found"));
        }

        Ok(())
    }
}
