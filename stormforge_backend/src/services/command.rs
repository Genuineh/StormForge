use anyhow::{anyhow, Result};
use chrono::Utc;
use futures_util::stream::TryStreamExt;
use mongodb::{bson::doc, Collection, Database};

use crate::models::{
    CommandDefinition, CommandField, CommandFieldRequest, CreateCommandRequest,
    Precondition, PreconditionRequest, UpdateCommandRequest, CommandValidationRule,
    CommandValidationRuleRequest,
};

#[derive(Clone)]
pub struct CommandService {
    commands: Collection<CommandDefinition>,
}

impl CommandService {
    pub fn new(db: &Database) -> Self {
        Self {
            commands: db.collection("commands"),
        }
    }

    pub async fn create_command(
        &self,
        request: CreateCommandRequest,
    ) -> Result<CommandDefinition> {
        // Check if command with same name exists in project
        let existing_count = self
            .commands
            .count_documents(doc! { "project_id": &request.project_id, "name": &request.name }, None)
            .await?;

        if existing_count > 0 {
            return Err(anyhow!(
                "Command with name '{}' already exists in project",
                request.name
            ));
        }

        let mut command = CommandDefinition::new(request.project_id, request.name);
        command.description = request.description;
        command.aggregate_id = request.aggregate_id;

        self.commands.insert_one(&command, None).await?;

        Ok(command)
    }

    pub async fn find_by_id(&self, id: &str) -> Result<CommandDefinition> {
        let command = self
            .commands
            .find_one(doc! { "_id": id }, None)
            .await?
            .ok_or_else(|| anyhow!("Command not found"))?;

        Ok(command)
    }

    pub async fn find_by_name(
        &self,
        project_id: &str,
        name: &str,
    ) -> Result<CommandDefinition> {
        let command = self
            .commands
            .find_one(doc! { "project_id": project_id, "name": name }, None)
            .await?
            .ok_or_else(|| anyhow!("Command not found"))?;

        Ok(command)
    }

    pub async fn list_for_project(&self, project_id: &str) -> Result<Vec<CommandDefinition>> {
        let cursor = self
            .commands
            .find(doc! { "project_id": project_id }, None)
            .await?;
        let commands = cursor.try_collect().await?;

        Ok(commands)
    }

    pub async fn update_command(
        &self,
        id: &str,
        request: UpdateCommandRequest,
    ) -> Result<CommandDefinition> {
        let mut update_doc = doc! { "updated_at": mongodb::bson::to_bson(&Utc::now())? };

        update_doc.insert("name", request.name);
        if let Some(description) = request.description {
            update_doc.insert("description", description);
        }
        if let Some(aggregate_id) = request.aggregate_id {
            update_doc.insert("aggregate_id", aggregate_id);
        }
        if let Some(produced_events) = request.produced_events {
            update_doc.insert("produced_events", produced_events);
        }

        self.commands
            .update_one(doc! { "_id": id }, doc! { "$set": update_doc }, None)
            .await?;

        self.find_by_id(id).await
    }

    pub async fn delete_command(&self, id: &str) -> Result<()> {
        let result = self.commands.delete_one(doc! { "_id": id }, None).await?;

        if result.deleted_count == 0 {
            return Err(anyhow!("Command not found"));
        }

        Ok(())
    }

    // Field operations
    pub async fn add_field(
        &self,
        command_id: &str,
        request: CommandFieldRequest,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        let field = CommandField {
            id: uuid::Uuid::new_v4().to_string(),
            name: request.name,
            field_type: request.field_type,
            required: request.required,
            source: request.source,
            default_value: request.default_value,
            description: request.description,
            validations: Vec::new(),
            display_order: command.payload.fields.len() as i32,
        };

        command.payload.fields.push(field);
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }

    pub async fn update_field(
        &self,
        command_id: &str,
        field_id: &str,
        request: CommandFieldRequest,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        let field_index = command
            .payload
            .fields
            .iter()
            .position(|f| f.id == field_id)
            .ok_or_else(|| anyhow!("Field not found"))?;

        // Preserve existing validations
        let existing_validations = command.payload.fields[field_index].validations.clone();

        command.payload.fields[field_index] = CommandField {
            id: field_id.to_string(),
            name: request.name,
            field_type: request.field_type,
            required: request.required,
            source: request.source,
            default_value: request.default_value,
            description: request.description,
            validations: existing_validations,
            display_order: command.payload.fields[field_index].display_order,
        };
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }

    pub async fn remove_field(
        &self,
        command_id: &str,
        field_id: &str,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        let field_index = command
            .payload
            .fields
            .iter()
            .position(|f| f.id == field_id)
            .ok_or_else(|| anyhow!("Field not found"))?;

        command.payload.fields.remove(field_index);
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }

    // Validation rule operations
    pub async fn add_validation(
        &self,
        command_id: &str,
        request: CommandValidationRuleRequest,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        let validation = CommandValidationRule {
            field_name: request.field_name,
            operator: request.operator,
            value: request.value,
            error_message: request.error_message,
        };

        command.validations.push(validation);
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }

    pub async fn remove_validation(
        &self,
        command_id: &str,
        validation_index: usize,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        if validation_index >= command.validations.len() {
            return Err(anyhow!("Validation index out of bounds"));
        }

        command.validations.remove(validation_index);
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }

    // Precondition operations
    pub async fn add_precondition(
        &self,
        command_id: &str,
        request: PreconditionRequest,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        let precondition = Precondition {
            description: request.description,
            expression: request.expression,
            operator: request.operator,
            error_message: request.error_message,
        };

        command.preconditions.push(precondition);
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }

    pub async fn remove_precondition(
        &self,
        command_id: &str,
        precondition_index: usize,
    ) -> Result<CommandDefinition> {
        let mut command = self.find_by_id(command_id).await?;

        if precondition_index >= command.preconditions.len() {
            return Err(anyhow!("Precondition index out of bounds"));
        }

        command.preconditions.remove(precondition_index);
        command.updated_at = Utc::now();

        self.commands
            .replace_one(doc! { "_id": command_id }, &command, None)
            .await?;

        Ok(command)
    }
}
