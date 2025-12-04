use anyhow::Result;
use mongodb::{Client, Database};

#[derive(Clone)]
pub struct MongoDbService {
    db: Database,
}

impl MongoDbService {
    pub async fn new(connection_string: &str, database_name: &str) -> Result<Self> {
        let client = Client::with_uri_str(connection_string).await?;
        let db = client.database(database_name);

        // Test connection
        db.list_collection_names(None).await?;

        Ok(Self { db })
    }

    pub fn db(&self) -> &Database {
        &self.db
    }

    pub async fn initialize_collections(&self) -> Result<()> {
        // Create collections if they don't exist
        let collections = vec![
            "users",
            "projects",
            "project_members",
            "project_models",
            "model_versions",
            "project_activities",
            "entities",
            "connections",
        ];

        for collection_name in collections {
            let collection_names = self.db.list_collection_names(None).await?;
            if !collection_names.contains(&collection_name.to_string()) {
                self.db.create_collection(collection_name, None).await?;
            }
        }

        // Create indexes
        self.create_indexes().await?;

        Ok(())
    }

    async fn create_indexes(&self) -> Result<()> {
        use mongodb::bson::{doc, Document};
        use mongodb::IndexModel;

        // Users indexes
        let users = self.db.collection::<Document>("users");
        users
            .create_index(
                IndexModel::builder()
                    .keys(doc! { "username": 1 })
                    .options(
                        mongodb::options::IndexOptions::builder()
                            .unique(true)
                            .build(),
                    )
                    .build(),
                None,
            )
            .await?;
        users
            .create_index(
                IndexModel::builder()
                    .keys(doc! { "email": 1 })
                    .options(
                        mongodb::options::IndexOptions::builder()
                            .unique(true)
                            .build(),
                    )
                    .build(),
                None,
            )
            .await?;

        // Projects indexes
        let projects = self.db.collection::<Document>("projects");
        projects
            .create_index(
                IndexModel::builder()
                    .keys(doc! { "namespace": 1 })
                    .options(
                        mongodb::options::IndexOptions::builder()
                            .unique(true)
                            .build(),
                    )
                    .build(),
                None,
            )
            .await?;
        projects
            .create_index(
                IndexModel::builder().keys(doc! { "owner_id": 1 }).build(),
                None,
            )
            .await?;

        // Project members indexes
        let members = self.db.collection::<Document>("project_members");
        members
            .create_index(
                IndexModel::builder()
                    .keys(doc! { "project_id": 1, "user_id": 1 })
                    .options(
                        mongodb::options::IndexOptions::builder()
                            .unique(true)
                            .build(),
                    )
                    .build(),
                None,
            )
            .await?;

        // Entities indexes
        let entities = self.db.collection::<Document>("entities");
        entities
            .create_index(
                IndexModel::builder()
                    .keys(doc! { "project_id": 1, "name": 1 })
                    .options(
                        mongodb::options::IndexOptions::builder()
                            .unique(true)
                            .build(),
                    )
                    .build(),
                None,
            )
            .await?;
        entities
            .create_index(
                IndexModel::builder().keys(doc! { "project_id": 1 }).build(),
                None,
            )
            .await?;
        entities
            .create_index(
                IndexModel::builder()
                    .keys(doc! { "aggregate_id": 1 })
                    .build(),
                None,
            )
            .await?;

        Ok(())
    }
}
