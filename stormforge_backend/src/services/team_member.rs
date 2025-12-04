use anyhow::{anyhow, Result};
use futures_util::stream::TryStreamExt;
use mongodb::{bson::doc, Collection, Database};

use crate::models::{TeamMember, TeamRole};

#[derive(Clone)]
pub struct TeamMemberService {
    members: Collection<TeamMember>,
}

impl TeamMemberService {
    pub fn new(db: &Database) -> Self {
        Self {
            members: db.collection("project_members"),
        }
    }

    pub async fn add_member(
        &self,
        project_id: String,
        user_id: String,
        role: TeamRole,
        invited_by: Option<String>,
    ) -> Result<TeamMember> {
        // Check if member already exists
        if self.find_member(&project_id, &user_id).await.is_ok() {
            return Err(anyhow!("User is already a member of this project"));
        }

        let member = TeamMember::new(project_id, user_id, role, invited_by);
        self.members.insert_one(&member, None).await?;

        Ok(member)
    }

    pub async fn find_member(&self, project_id: &str, user_id: &str) -> Result<TeamMember> {
        let member = self
            .members
            .find_one(doc! { "project_id": project_id, "user_id": user_id }, None)
            .await?
            .ok_or_else(|| anyhow!("Member not found"))?;

        Ok(member)
    }

    pub async fn list_project_members(&self, project_id: &str) -> Result<Vec<TeamMember>> {
        let cursor = self
            .members
            .find(doc! { "project_id": project_id }, None)
            .await?;
        let members = cursor.try_collect().await?;

        Ok(members)
    }

    #[allow(dead_code)]
    pub async fn list_user_projects(&self, user_id: &str) -> Result<Vec<String>> {
        let cursor = self.members.find(doc! { "user_id": user_id }, None).await?;
        let members: Vec<TeamMember> = cursor.try_collect().await?;

        Ok(members.into_iter().map(|m| m.project_id).collect())
    }

    pub async fn update_member(
        &self,
        project_id: &str,
        user_id: &str,
        role: Option<TeamRole>,
    ) -> Result<TeamMember> {
        let mut update_doc = doc! {};

        if let Some(r) = role {
            let permissions = r.default_permissions();
            update_doc.insert("role", mongodb::bson::to_bson(&r)?);
            update_doc.insert("permissions", mongodb::bson::to_bson(&permissions)?);
        }

        self.members
            .update_one(
                doc! { "project_id": project_id, "user_id": user_id },
                doc! { "$set": update_doc },
                None,
            )
            .await?;

        self.find_member(project_id, user_id).await
    }

    pub async fn remove_member(&self, project_id: &str, user_id: &str) -> Result<()> {
        let result = self
            .members
            .delete_one(doc! { "project_id": project_id, "user_id": user_id }, None)
            .await?;

        if result.deleted_count == 0 {
            return Err(anyhow!("Member not found"));
        }

        Ok(())
    }

    #[allow(dead_code)]
    pub async fn is_project_owner(&self, project_id: &str, user_id: &str) -> Result<bool> {
        match self.find_member(project_id, user_id).await {
            Ok(member) => Ok(matches!(member.role, TeamRole::Owner)),
            Err(_) => Ok(false),
        }
    }

    #[allow(dead_code)]
    pub async fn can_manage_team(&self, project_id: &str, user_id: &str) -> Result<bool> {
        match self.find_member(project_id, user_id).await {
            Ok(member) => Ok(member.can_manage_team()),
            Err(_) => Ok(false),
        }
    }
}
