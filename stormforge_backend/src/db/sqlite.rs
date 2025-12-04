use anyhow::Result;
use r2d2::Pool;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, Connection, Result as SqliteResult};

pub type SqlitePool = Pool<SqliteConnectionManager>;

#[derive(Clone)]
pub struct SqliteService {
    pool: SqlitePool,
}

impl SqliteService {
    pub fn new(database_path: &str) -> Result<Self> {
        let manager = SqliteConnectionManager::file(database_path);
        let pool = Pool::new(manager)?;

        let service = Self { pool };
        service.initialize_schema()?;

        Ok(service)
    }

    pub fn pool(&self) -> &SqlitePool {
        &self.pool
    }

    fn initialize_schema(&self) -> Result<()> {
        let conn = self.pool.get()?;

        // Create users table
        conn.execute(
            "CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                display_name TEXT NOT NULL,
                avatar_url TEXT,
                role TEXT NOT NULL DEFAULT 'developer',
                permissions TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                last_synced_at TEXT
            )",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)",
            [],
        )?;

        // Create projects table
        conn.execute(
            "CREATE TABLE IF NOT EXISTS projects (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                namespace TEXT UNIQUE NOT NULL,
                description TEXT,
                owner_id TEXT NOT NULL,
                visibility TEXT NOT NULL DEFAULT 'private',
                settings TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                last_synced_at TEXT,
                FOREIGN KEY (owner_id) REFERENCES users(id)
            )",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_projects_namespace ON projects(namespace)",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(owner_id)",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_projects_updated_at ON projects(updated_at DESC)",
            [],
        )?;

        // Create project_members table
        conn.execute(
            "CREATE TABLE IF NOT EXISTS project_members (
                id TEXT PRIMARY KEY,
                project_id TEXT NOT NULL,
                user_id TEXT NOT NULL,
                role TEXT NOT NULL DEFAULT 'editor',
                permissions TEXT,
                joined_at TEXT NOT NULL,
                last_synced_at TEXT,
                FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users(id),
                UNIQUE(project_id, user_id)
            )",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_project_members_project_id ON project_members(project_id)",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_project_members_user_id ON project_members(user_id)",
            [],
        )?;

        // Create project_models table
        conn.execute(
            "CREATE TABLE IF NOT EXISTS project_models (
                id TEXT PRIMARY KEY,
                project_id TEXT NOT NULL,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                content TEXT NOT NULL,
                version INTEGER NOT NULL DEFAULT 1,
                created_by TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                updated_by TEXT NOT NULL,
                last_synced_at TEXT,
                FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
                FOREIGN KEY (created_by) REFERENCES users(id),
                FOREIGN KEY (updated_by) REFERENCES users(id)
            )",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_project_models_project_id ON project_models(project_id)",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_project_models_type ON project_models(type)",
            [],
        )?;

        // Create model_versions table
        conn.execute(
            "CREATE TABLE IF NOT EXISTS model_versions (
                id TEXT PRIMARY KEY,
                model_id TEXT NOT NULL,
                version INTEGER NOT NULL,
                content TEXT NOT NULL,
                changed_by TEXT NOT NULL,
                change_description TEXT,
                created_at TEXT NOT NULL,
                FOREIGN KEY (model_id) REFERENCES project_models(id) ON DELETE CASCADE,
                FOREIGN KEY (changed_by) REFERENCES users(id),
                UNIQUE(model_id, version)
            )",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_model_versions_model_id ON model_versions(model_id, version DESC)",
            [],
        )?;

        // Create sync_queue table
        conn.execute(
            "CREATE TABLE IF NOT EXISTS sync_queue (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                entity_type TEXT NOT NULL,
                entity_id TEXT NOT NULL,
                operation TEXT NOT NULL,
                data TEXT,
                created_at TEXT NOT NULL,
                retry_count INTEGER DEFAULT 0,
                last_error TEXT
            )",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_sync_queue_created_at ON sync_queue(created_at)",
            [],
        )?;

        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity_type, entity_id)",
            [],
        )?;

        Ok(())
    }
}
