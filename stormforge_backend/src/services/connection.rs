use anyhow::{anyhow, Result};
use futures_util::stream::TryStreamExt;
use mongodb::{bson::doc, Collection, Database};

use crate::models::{Connection, CreateConnectionRequest, UpdateConnectionRequest};

#[derive(Clone)]
pub struct ConnectionService {
    connections: Collection<Connection>,
}

impl ConnectionService {
    pub fn new(db: &Database) -> Self {
        Self {
            connections: db.collection("connections"),
        }
    }

    /// Creates a new connection.
    pub async fn create_connection(
        &self,
        project_id: String,
        request: CreateConnectionRequest,
    ) -> Result<Connection> {
        // Use provided style or default for connection type
        let style = request
            .style
            .unwrap_or_else(|| Connection::default_style_for_type(&request.connection_type));

        let connection = Connection::new(
            project_id,
            request.source_id,
            request.target_id,
            request.connection_type,
            request.label,
            style,
            request.metadata,
        );

        self.connections.insert_one(&connection, None).await?;

        Ok(connection)
    }

    /// Finds a connection by ID.
    pub async fn find_by_id(&self, id: &str) -> Result<Connection> {
        let connection = self
            .connections
            .find_one(doc! { "id": id }, None)
            .await?
            .ok_or_else(|| anyhow!("Connection not found"))?;

        Ok(connection)
    }

    /// Lists all connections for a project.
    pub async fn list_by_project(&self, project_id: &str) -> Result<Vec<Connection>> {
        let cursor = self
            .connections
            .find(doc! { "project_id": project_id }, None)
            .await?;
        let connections = cursor.try_collect().await?;

        Ok(connections)
    }

    /// Lists connections by source element ID.
    #[allow(dead_code)]
    pub async fn list_by_source(
        &self,
        project_id: &str,
        source_id: &str,
    ) -> Result<Vec<Connection>> {
        let cursor = self
            .connections
            .find(
                doc! {
                    "project_id": project_id,
                    "source_id": source_id
                },
                None,
            )
            .await?;
        let connections = cursor.try_collect().await?;

        Ok(connections)
    }

    /// Lists connections by target element ID.
    #[allow(dead_code)]
    pub async fn list_by_target(
        &self,
        project_id: &str,
        target_id: &str,
    ) -> Result<Vec<Connection>> {
        let cursor = self
            .connections
            .find(
                doc! {
                    "project_id": project_id,
                    "target_id": target_id
                },
                None,
            )
            .await?;
        let connections = cursor.try_collect().await?;

        Ok(connections)
    }

    /// Lists connections for an element (either as source or target).
    pub async fn list_by_element(
        &self,
        project_id: &str,
        element_id: &str,
    ) -> Result<Vec<Connection>> {
        let cursor = self
            .connections
            .find(
                doc! {
                    "project_id": project_id,
                    "$or": [
                        {"source_id": element_id},
                        {"target_id": element_id}
                    ]
                },
                None,
            )
            .await?;
        let connections = cursor.try_collect().await?;

        Ok(connections)
    }

    /// Updates a connection.
    pub async fn update_connection(
        &self,
        id: &str,
        request: UpdateConnectionRequest,
    ) -> Result<Connection> {
        let mut connection = self.find_by_id(id).await?;

        if let Some(label) = request.label {
            connection.label = label;
        }

        if let Some(style) = request.style {
            connection.style = style;
        }

        if let Some(metadata) = request.metadata {
            connection.metadata = metadata;
        }

        connection.updated_at = chrono::Utc::now();

        self.connections
            .replace_one(doc! { "id": id }, &connection, None)
            .await?;

        Ok(connection)
    }

    /// Deletes a connection.
    pub async fn delete_connection(&self, id: &str) -> Result<()> {
        let result = self.connections.delete_one(doc! { "id": id }, None).await?;

        if result.deleted_count == 0 {
            return Err(anyhow!("Connection not found"));
        }

        Ok(())
    }

    /// Deletes all connections for a project.
    #[allow(dead_code)]
    pub async fn delete_by_project(&self, project_id: &str) -> Result<u64> {
        let result = self
            .connections
            .delete_many(doc! { "project_id": project_id }, None)
            .await?;

        Ok(result.deleted_count)
    }

    /// Deletes all connections for an element (when element is deleted).
    #[allow(dead_code)]
    pub async fn delete_by_element(&self, project_id: &str, element_id: &str) -> Result<u64> {
        let result = self
            .connections
            .delete_many(
                doc! {
                    "project_id": project_id,
                    "$or": [
                        {"source_id": element_id},
                        {"target_id": element_id}
                    ]
                },
                None,
            )
            .await?;

        Ok(result.deleted_count)
    }
}
