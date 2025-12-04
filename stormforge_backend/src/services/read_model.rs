use anyhow::{anyhow, Result};
use chrono::Utc;
use futures_util::stream::TryStreamExt;
use mongodb::{bson::doc, Collection, Database};

use crate::models::{
    CreateReadModelRequest, DataSource, DataSourceRequest, FieldRequest, ReadModelDefinition,
    ReadModelField, UpdateReadModelRequest,
};

#[derive(Clone)]
pub struct ReadModelService {
    read_models: Collection<ReadModelDefinition>,
}

impl ReadModelService {
    pub fn new(db: &Database) -> Self {
        Self {
            read_models: db.collection("read_models"),
        }
    }

    pub async fn create_read_model(
        &self,
        request: CreateReadModelRequest,
    ) -> Result<ReadModelDefinition> {
        // Check if read model with same name exists in project
        let existing_count = self
            .read_models
            .count_documents(doc! { "project_id": &request.project_id, "name": &request.name }, None)
            .await?;

        if existing_count > 0 {
            return Err(anyhow!(
                "Read model with name '{}' already exists in project",
                request.name
            ));
        }

        let mut read_model = ReadModelDefinition::new(request.project_id, request.name);
        read_model.description = request.description;

        self.read_models.insert_one(&read_model, None).await?;

        Ok(read_model)
    }

    pub async fn find_by_id(&self, id: &str) -> Result<ReadModelDefinition> {
        let read_model = self
            .read_models
            .find_one(doc! { "_id": id }, None)
            .await?
            .ok_or_else(|| anyhow!("Read model not found"))?;

        Ok(read_model)
    }

    pub async fn find_by_name(
        &self,
        project_id: &str,
        name: &str,
    ) -> Result<ReadModelDefinition> {
        let read_model = self
            .read_models
            .find_one(doc! { "project_id": project_id, "name": name }, None)
            .await?
            .ok_or_else(|| anyhow!("Read model not found"))?;

        Ok(read_model)
    }

    pub async fn list_for_project(&self, project_id: &str) -> Result<Vec<ReadModelDefinition>> {
        let cursor = self
            .read_models
            .find(doc! { "project_id": project_id }, None)
            .await?;
        let read_models = cursor.try_collect().await?;

        Ok(read_models)
    }

    pub async fn update_read_model(
        &self,
        id: &str,
        request: UpdateReadModelRequest,
    ) -> Result<ReadModelDefinition> {
        let mut update_doc = doc! { "updated_at": mongodb::bson::to_bson(&Utc::now())? };

        update_doc.insert("name", request.name);
        if let Some(description) = request.description {
            update_doc.insert("description", description);
        }
        if let Some(updated_by_events) = request.updated_by_events {
            update_doc.insert("updated_by_events", updated_by_events);
        }

        self.read_models
            .update_one(doc! { "_id": id }, doc! { "$set": update_doc }, None)
            .await?;

        self.find_by_id(id).await
    }

    pub async fn delete_read_model(&self, id: &str) -> Result<()> {
        let result = self.read_models.delete_one(doc! { "_id": id }, None).await?;

        if result.deleted_count == 0 {
            return Err(anyhow!("Read model not found"));
        }

        Ok(())
    }

    // Data source operations
    pub async fn add_source(
        &self,
        read_model_id: &str,
        request: DataSourceRequest,
    ) -> Result<ReadModelDefinition> {
        let mut read_model = self.find_by_id(read_model_id).await?;

        let source = DataSource {
            entity_id: request.entity_id,
            alias: request.alias,
            join_condition: request.join_condition,
            join_type: request.join_type,
            display_order: read_model.sources.len() as i32,
        };

        read_model.sources.push(source);
        read_model.updated_at = Utc::now();

        self.read_models
            .replace_one(doc! { "_id": read_model_id }, &read_model, None)
            .await?;

        Ok(read_model)
    }

    pub async fn update_source(
        &self,
        read_model_id: &str,
        source_index: usize,
        request: DataSourceRequest,
    ) -> Result<ReadModelDefinition> {
        let mut read_model = self.find_by_id(read_model_id).await?;

        if source_index >= read_model.sources.len() {
            return Err(anyhow!("Source index out of bounds"));
        }

        read_model.sources[source_index] = DataSource {
            entity_id: request.entity_id,
            alias: request.alias,
            join_condition: request.join_condition,
            join_type: request.join_type,
            display_order: source_index as i32,
        };
        read_model.updated_at = Utc::now();

        self.read_models
            .replace_one(doc! { "_id": read_model_id }, &read_model, None)
            .await?;

        Ok(read_model)
    }

    pub async fn remove_source(
        &self,
        read_model_id: &str,
        source_index: usize,
    ) -> Result<ReadModelDefinition> {
        let mut read_model = self.find_by_id(read_model_id).await?;

        if source_index >= read_model.sources.len() {
            return Err(anyhow!("Source index out of bounds"));
        }

        read_model.sources.remove(source_index);
        read_model.updated_at = Utc::now();

        self.read_models
            .replace_one(doc! { "_id": read_model_id }, &read_model, None)
            .await?;

        Ok(read_model)
    }

    // Field operations
    pub async fn add_field(
        &self,
        read_model_id: &str,
        request: FieldRequest,
    ) -> Result<ReadModelDefinition> {
        let mut read_model = self.find_by_id(read_model_id).await?;

        let field = ReadModelField {
            id: uuid::Uuid::new_v4().to_string(),
            name: request.name,
            field_type: request.field_type,
            source_type: request.source_type,
            source_path: request.source_path,
            transform: request.transform,
            nullable: request.nullable,
            description: request.description,
            display_order: read_model.fields.len() as i32,
        };

        read_model.fields.push(field);
        read_model.updated_at = Utc::now();

        self.read_models
            .replace_one(doc! { "_id": read_model_id }, &read_model, None)
            .await?;

        Ok(read_model)
    }

    pub async fn update_field(
        &self,
        read_model_id: &str,
        field_id: &str,
        request: FieldRequest,
    ) -> Result<ReadModelDefinition> {
        let mut read_model = self.find_by_id(read_model_id).await?;

        let field_index = read_model
            .fields
            .iter()
            .position(|f| f.id == field_id)
            .ok_or_else(|| anyhow!("Field not found"))?;

        read_model.fields[field_index] = ReadModelField {
            id: field_id.to_string(),
            name: request.name,
            field_type: request.field_type,
            source_type: request.source_type,
            source_path: request.source_path,
            transform: request.transform,
            nullable: request.nullable,
            description: request.description,
            display_order: read_model.fields[field_index].display_order,
        };
        read_model.updated_at = Utc::now();

        self.read_models
            .replace_one(doc! { "_id": read_model_id }, &read_model, None)
            .await?;

        Ok(read_model)
    }

    pub async fn remove_field(
        &self,
        read_model_id: &str,
        field_id: &str,
    ) -> Result<ReadModelDefinition> {
        let mut read_model = self.find_by_id(read_model_id).await?;

        let field_index = read_model
            .fields
            .iter()
            .position(|f| f.id == field_id)
            .ok_or_else(|| anyhow!("Field not found"))?;

        read_model.fields.remove(field_index);
        read_model.updated_at = Utc::now();

        self.read_models
            .replace_one(doc! { "_id": read_model_id }, &read_model, None)
            .await?;

        Ok(read_model)
    }
}
