use anyhow::{anyhow, Result};
use chrono::Utc;
use futures_util::stream::TryStreamExt;
use mongodb::{bson::doc, Collection, Database};

use crate::models::{
    CreateEntityRequest, EntityDefinition, EntityInvariant, EntityMethod, EntityProperty,
    InvariantRequest, MethodRequest, PropertyRequest, UpdateEntityRequest,
};

#[derive(Clone)]
pub struct EntityService {
    entities: Collection<EntityDefinition>,
}

impl EntityService {
    pub fn new(db: &Database) -> Self {
        Self {
            entities: db.collection("entities"),
        }
    }

    pub async fn create_entity(&self, request: CreateEntityRequest) -> Result<EntityDefinition> {
        // Check if entity with same name exists in project
        if self.find_by_name(&request.project_id, &request.name).await.is_ok() {
            return Err(anyhow!(
                "Entity with name '{}' already exists in project",
                request.name
            ));
        }

        let entity = EntityDefinition::new(request.project_id, request.name, request.entity_type);
        let mut entity = entity;
        entity.description = request.description;
        entity.aggregate_id = request.aggregate_id;

        self.entities.insert_one(&entity, None).await?;

        Ok(entity)
    }

    pub async fn find_by_id(&self, id: &str) -> Result<EntityDefinition> {
        let entity = self
            .entities
            .find_one(doc! { "id": id }, None)
            .await?
            .ok_or_else(|| anyhow!("Entity not found"))?;

        Ok(entity)
    }

    pub async fn find_by_name(&self, project_id: &str, name: &str) -> Result<EntityDefinition> {
        let entity = self
            .entities
            .find_one(doc! { "project_id": project_id, "name": name }, None)
            .await?
            .ok_or_else(|| anyhow!("Entity not found"))?;

        Ok(entity)
    }

    pub async fn list_for_project(&self, project_id: &str) -> Result<Vec<EntityDefinition>> {
        let cursor = self
            .entities
            .find(doc! { "project_id": project_id }, None)
            .await?;
        let entities = cursor.try_collect().await?;

        Ok(entities)
    }

    pub async fn list_by_aggregate(&self, aggregate_id: &str) -> Result<Vec<EntityDefinition>> {
        let cursor = self
            .entities
            .find(doc! { "aggregate_id": aggregate_id }, None)
            .await?;
        let entities = cursor.try_collect().await?;

        Ok(entities)
    }

    pub async fn update_entity(
        &self,
        id: &str,
        request: UpdateEntityRequest,
    ) -> Result<EntityDefinition> {
        let mut update_doc = doc! { "updated_at": mongodb::bson::to_bson(&Utc::now())? };

        if let Some(name) = request.name {
            update_doc.insert("name", name);
        }
        if let Some(description) = request.description {
            update_doc.insert("description", description);
        }
        if let Some(aggregate_id) = request.aggregate_id {
            update_doc.insert("aggregate_id", aggregate_id);
        }
        if let Some(entity_type) = request.entity_type {
            update_doc.insert("entity_type", mongodb::bson::to_bson(&entity_type)?);
        }

        self.entities
            .update_one(doc! { "id": id }, doc! { "$set": update_doc }, None)
            .await?;

        self.find_by_id(id).await
    }

    pub async fn delete_entity(&self, id: &str) -> Result<()> {
        let result = self.entities.delete_one(doc! { "id": id }, None).await?;

        if result.deleted_count == 0 {
            return Err(anyhow!("Entity not found"));
        }

        Ok(())
    }

    // Property operations
    pub async fn add_property(
        &self,
        entity_id: &str,
        request: PropertyRequest,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        let property = EntityProperty {
            id: uuid::Uuid::new_v4().to_string(),
            name: request.name,
            property_type: request.property_type,
            required: request.required,
            is_identifier: request.is_identifier,
            is_read_only: request.is_read_only,
            default_value: request.default_value,
            description: request.description,
            display_order: request.display_order,
            validations: request.validations,
        };

        entity.properties.push(property);
        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn update_property(
        &self,
        entity_id: &str,
        property_id: &str,
        request: PropertyRequest,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        let property = entity
            .properties
            .iter_mut()
            .find(|p| p.id == property_id)
            .ok_or_else(|| anyhow!("Property not found"))?;

        property.name = request.name;
        property.property_type = request.property_type;
        property.required = request.required;
        property.is_identifier = request.is_identifier;
        property.is_read_only = request.is_read_only;
        property.default_value = request.default_value;
        property.description = request.description;
        property.display_order = request.display_order;
        property.validations = request.validations;

        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn remove_property(
        &self,
        entity_id: &str,
        property_id: &str,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        entity.properties.retain(|p| p.id != property_id);
        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    // Method operations
    pub async fn add_method(
        &self,
        entity_id: &str,
        request: MethodRequest,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        let method = EntityMethod {
            id: uuid::Uuid::new_v4().to_string(),
            name: request.name,
            method_type: request.method_type,
            return_type: request.return_type,
            parameters: request.parameters,
            description: request.description,
        };

        entity.methods.push(method);
        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn update_method(
        &self,
        entity_id: &str,
        method_id: &str,
        request: MethodRequest,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        let method = entity
            .methods
            .iter_mut()
            .find(|m| m.id == method_id)
            .ok_or_else(|| anyhow!("Method not found"))?;

        method.name = request.name;
        method.method_type = request.method_type;
        method.return_type = request.return_type;
        method.parameters = request.parameters;
        method.description = request.description;

        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn remove_method(
        &self,
        entity_id: &str,
        method_id: &str,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        entity.methods.retain(|m| m.id != method_id);
        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    // Invariant operations
    pub async fn add_invariant(
        &self,
        entity_id: &str,
        request: InvariantRequest,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        let invariant = EntityInvariant {
            id: uuid::Uuid::new_v4().to_string(),
            name: request.name,
            expression: request.expression,
            error_message: request.error_message,
            enabled: request.enabled,
        };

        entity.invariants.push(invariant);
        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn update_invariant(
        &self,
        entity_id: &str,
        invariant_id: &str,
        request: InvariantRequest,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        let invariant = entity
            .invariants
            .iter_mut()
            .find(|i| i.id == invariant_id)
            .ok_or_else(|| anyhow!("Invariant not found"))?;

        invariant.name = request.name;
        invariant.expression = request.expression;
        invariant.error_message = request.error_message;
        invariant.enabled = request.enabled;

        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn remove_invariant(
        &self,
        entity_id: &str,
        invariant_id: &str,
    ) -> Result<EntityDefinition> {
        let mut entity = self.find_by_id(entity_id).await?;

        entity.invariants.retain(|i| i.id != invariant_id);
        entity.updated_at = Utc::now();

        self.entities
            .replace_one(doc! { "id": entity_id }, &entity, None)
            .await?;

        Ok(entity)
    }

    pub async fn find_references(&self, entity_id: &str) -> Result<Vec<EntityDefinition>> {
        // Find entities that might reference this entity (e.g., through aggregate_id or properties)
        let entity = self.find_by_id(entity_id).await?;

        let cursor = self
            .entities
            .find(doc! { "aggregate_id": &entity.aggregate_id }, None)
            .await?;
        let references = cursor.try_collect().await?;

        Ok(references)
    }
}
