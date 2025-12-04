use anyhow::{anyhow, Result};
use chrono::Utc;
use futures_util::stream::TryStreamExt;
use mongodb::{bson::doc, Collection, Database};

use crate::models::{User, UserRole};

#[derive(Clone)]
pub struct UserService {
    users: Collection<User>,
}

impl UserService {
    pub fn new(db: &Database) -> Self {
        Self {
            users: db.collection("users"),
        }
    }

    pub async fn create_user(
        &self,
        username: String,
        email: String,
        display_name: String,
        password_hash: String,
        role: UserRole,
    ) -> Result<User> {
        // Check if username or email already exists
        if self.find_by_username(&username).await.is_ok() {
            return Err(anyhow!("Username already exists"));
        }
        if self.find_by_email(&email).await.is_ok() {
            return Err(anyhow!("Email already exists"));
        }

        let mut user = User::new(username, email, display_name, role);
        user.password_hash = Some(password_hash);

        self.users.insert_one(&user, None).await?;

        Ok(user)
    }

    pub async fn find_by_id(&self, id: &str) -> Result<User> {
        let user = self
            .users
            .find_one(doc! { "id": id }, None)
            .await?
            .ok_or_else(|| anyhow!("User not found"))?;

        Ok(user)
    }

    pub async fn find_by_username(&self, username: &str) -> Result<User> {
        let user = self
            .users
            .find_one(doc! { "username": username }, None)
            .await?
            .ok_or_else(|| anyhow!("User not found"))?;

        Ok(user)
    }

    pub async fn find_by_email(&self, email: &str) -> Result<User> {
        let user = self
            .users
            .find_one(doc! { "email": email }, None)
            .await?
            .ok_or_else(|| anyhow!("User not found"))?;

        Ok(user)
    }

    pub async fn find_by_username_or_email(&self, username_or_email: &str) -> Result<User> {
        let user = self
            .users
            .find_one(
                doc! {
                    "$or": [
                        { "username": username_or_email },
                        { "email": username_or_email }
                    ]
                },
                None,
            )
            .await?
            .ok_or_else(|| anyhow!("User not found"))?;

        Ok(user)
    }

    pub async fn update_user(
        &self,
        id: &str,
        display_name: Option<String>,
        avatar_url: Option<String>,
        email: Option<String>,
    ) -> Result<User> {
        let mut update_doc = doc! { "updated_at": mongodb::bson::to_bson(&Utc::now())? };

        if let Some(name) = display_name {
            update_doc.insert("display_name", name);
        }
        if let Some(url) = avatar_url {
            update_doc.insert("avatar_url", url);
        }
        if let Some(email_addr) = email {
            // Check if email is already taken by another user
            if let Ok(existing_user) = self.find_by_email(&email_addr).await {
                if existing_user.id != id {
                    return Err(anyhow!("Email already taken by another user"));
                }
            }
            update_doc.insert("email", email_addr);
        }

        self.users
            .update_one(doc! { "id": id }, doc! { "$set": update_doc }, None)
            .await?;

        self.find_by_id(id).await
    }

    pub async fn update_last_login(&self, id: &str) -> Result<()> {
        self.users
            .update_one(
                doc! { "id": id },
                doc! { "$set": { "last_login_at": mongodb::bson::to_bson(&Utc::now())? } },
                None,
            )
            .await?;

        Ok(())
    }

    pub async fn list_users(&self) -> Result<Vec<User>> {
        let cursor = self.users.find(None, None).await?;
        let users = cursor.try_collect().await?;

        Ok(users)
    }
}
