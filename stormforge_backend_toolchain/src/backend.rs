use anyhow::{Context, Result};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, Stdio};
use std::sync::{Arc, Mutex};

#[derive(Debug, Clone, PartialEq)]
pub enum ServiceStatus {
    NotStarted,
    Starting,
    Running,
    Stopping,
    Stopped,
    Error(String),
}

pub struct BackendManager {
    backend_path: PathBuf,
    backend_process: Arc<Mutex<Option<Child>>>,
    pub mongo_status: ServiceStatus,
    pub backend_status: ServiceStatus,
}

impl BackendManager {
    pub fn new() -> Result<Self> {
        let current_dir = std::env::current_dir()?;
        let backend_path = current_dir.join("../stormforge_backend");

        Ok(Self {
            backend_path,
            backend_process: Arc::new(Mutex::new(None)),
            mongo_status: ServiceStatus::NotStarted,
            backend_status: ServiceStatus::NotStarted,
        })
    }

    pub fn setup_environment(&mut self) -> Result<Vec<String>> {
        let mut messages = Vec::new();

        // Check if .env exists, if not create from .env.example
        let env_path = self.backend_path.join(".env");
        let env_example_path = self.backend_path.join(".env.example");

        if !env_path.exists() {
            if env_example_path.exists() {
                fs::copy(&env_example_path, &env_path)
                    .context("Failed to copy .env.example to .env")?;
                messages.push("✓ Created .env from .env.example".to_string());
            } else {
                messages.push("⚠ .env.example not found".to_string());
            }
        } else {
            messages.push("✓ .env already exists".to_string());
        }

        Ok(messages)
    }

    pub fn start_mongodb(&mut self) -> Result<String> {
        self.mongo_status = ServiceStatus::Starting;

        // Check if MongoDB is already running
        if self.check_mongodb_running() {
            self.mongo_status = ServiceStatus::Running;
            return Ok("MongoDB is already running".to_string());
        }

        // Try to start MongoDB using Docker
        match Command::new("docker")
            .args([
                "run",
                "-d",
                "-p",
                "27017:27017",
                "--name",
                "stormforge_mongodb",
                "--rm",
                "mongo:latest",
            ])
            .output()
        {
            Ok(output) => {
                if output.status.success() {
                    self.mongo_status = ServiceStatus::Running;
                    Ok("MongoDB started successfully via Docker".to_string())
                } else {
                    let error = String::from_utf8_lossy(&output.stderr);
                    if error.contains("already in use") {
                        // Container already exists
                        self.mongo_status = ServiceStatus::Running;
                        Ok("MongoDB container already exists".to_string())
                    } else {
                        self.mongo_status = ServiceStatus::Error(error.to_string());
                        Ok(format!("Failed to start MongoDB: {}", error))
                    }
                }
            }
            Err(e) => {
                self.mongo_status = ServiceStatus::NotStarted;
                Ok(format!(
                    "Docker not available: {}. Please start MongoDB manually.",
                    e
                ))
            }
        }
    }

    pub fn stop_mongodb(&mut self) -> Result<String> {
        self.mongo_status = ServiceStatus::Stopping;

        match Command::new("docker")
            .args(["stop", "stormforge_mongodb"])
            .output()
        {
            Ok(output) => {
                if output.status.success() {
                    self.mongo_status = ServiceStatus::Stopped;
                    Ok("MongoDB stopped successfully".to_string())
                } else {
                    let error = String::from_utf8_lossy(&output.stderr);
                    if error.contains("No such container") {
                        self.mongo_status = ServiceStatus::Stopped;
                        Ok("MongoDB was not running".to_string())
                    } else {
                        Ok(format!("Failed to stop MongoDB: {}", error))
                    }
                }
            }
            Err(e) => Ok(format!("Failed to stop MongoDB: {}", e)),
        }
    }

    pub fn build_backend(&mut self) -> Result<String> {
        let output = Command::new("cargo")
            .arg("build")
            .arg("--release")
            .current_dir(&self.backend_path)
            .output()
            .context("Failed to execute cargo build")?;

        if output.status.success() {
            Ok("Backend built successfully".to_string())
        } else {
            let error = String::from_utf8_lossy(&output.stderr);
            Ok(format!("Build failed:\n{}", error))
        }
    }

    pub fn start_backend(&mut self) -> Result<String> {
        self.backend_status = ServiceStatus::Starting;

        // Start backend process in background
        match Command::new("cargo")
            .arg("run")
            .arg("--release")
            .current_dir(&self.backend_path)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
        {
            Ok(child) => {
                *self.backend_process.lock().unwrap() = Some(child);
                self.backend_status = ServiceStatus::Running;
                Ok("Backend started successfully".to_string())
            }
            Err(e) => {
                self.backend_status = ServiceStatus::Error(e.to_string());
                Ok(format!("Failed to start backend: {}", e))
            }
        }
    }

    pub fn stop_backend(&mut self) -> Result<String> {
        self.backend_status = ServiceStatus::Stopping;

        let mut process = self.backend_process.lock().unwrap();
        if let Some(mut child) = process.take() {
            match child.kill() {
                Ok(_) => {
                    let _ = child.wait();
                    self.backend_status = ServiceStatus::Stopped;
                    Ok("Backend stopped successfully".to_string())
                }
                Err(e) => {
                    self.backend_status = ServiceStatus::Error(e.to_string());
                    Ok(format!("Failed to stop backend: {}", e))
                }
            }
        } else {
            self.backend_status = ServiceStatus::Stopped;
            Ok("Backend was not running".to_string())
        }
    }

    pub fn cleanup_all(&mut self) -> Result<Vec<String>> {
        let mut messages = Vec::new();

        // Stop backend
        messages.push(self.stop_backend()?);

        // Stop MongoDB
        messages.push(self.stop_mongodb()?);

        // Remove MongoDB container
        if let Ok(output) = Command::new("docker")
            .args(["rm", "-f", "stormforge_mongodb"])
            .output()
        {
            if output.status.success() {
                messages.push("✓ MongoDB container removed".to_string());
            }
        }

        Ok(messages)
    }

    pub fn check_status(&mut self) -> Result<()> {
        // Check MongoDB
        if self.check_mongodb_running() {
            if self.mongo_status != ServiceStatus::Running {
                self.mongo_status = ServiceStatus::Running;
            }
        } else if self.mongo_status == ServiceStatus::Running {
            self.mongo_status = ServiceStatus::Stopped;
        }

        // Check backend
        let mut process = self.backend_process.lock().unwrap();
        if let Some(child) = process.as_mut() {
            match child.try_wait() {
                Ok(Some(_)) => {
                    // Process has exited
                    *process = None;
                    self.backend_status = ServiceStatus::Stopped;
                }
                Ok(None) => {
                    // Process is still running
                    if self.backend_status != ServiceStatus::Running {
                        self.backend_status = ServiceStatus::Running;
                    }
                }
                Err(_) => {
                    *process = None;
                    self.backend_status = ServiceStatus::Error("Process check failed".to_string());
                }
            }
        } else if self.backend_status == ServiceStatus::Running {
            self.backend_status = ServiceStatus::Stopped;
        }

        Ok(())
    }

    pub fn check_health(&self) -> bool {
        // Try to connect to the health endpoint
        match Command::new("curl")
            .args([
                "-s",
                "-o",
                "/dev/null",
                "-w",
                "%{http_code}",
                "http://localhost:3000/health",
            ])
            .output()
        {
            Ok(output) => {
                let status_code = String::from_utf8_lossy(&output.stdout);
                status_code.trim() == "200"
            }
            Err(_) => false,
        }
    }

    fn check_mongodb_running(&self) -> bool {
        // Check if MongoDB container is running
        if let Ok(output) = Command::new("docker")
            .args([
                "ps",
                "--filter",
                "name=stormforge_mongodb",
                "--format",
                "{{.Names}}",
            ])
            .output()
        {
            let names = String::from_utf8_lossy(&output.stdout);
            return names.contains("stormforge_mongodb");
        }
        false
    }

    pub fn get_backend_path(&self) -> &Path {
        &self.backend_path
    }
}

impl Drop for BackendManager {
    fn drop(&mut self) {
        // Clean up processes on drop
        let _ = self.stop_backend();
    }
}
