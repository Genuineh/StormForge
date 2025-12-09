# StormForge Administrator Guide

> **Version**: 2.0 (Modeler 2.0)  
> **Last Updated**: December 2025  
> **Audience**: System administrators, DevOps engineers, IT managers

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation and Deployment](#installation-and-deployment)
4. [Database Administration](#database-administration)
5. [User Management](#user-management)
6. [Security Configuration](#security-configuration)
7. [Backup and Recovery](#backup-and-recovery)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Performance Tuning](#performance-tuning)
10. [Troubleshooting](#troubleshooting)
11. [Upgrade Procedures](#upgrade-procedures)

---

## Introduction

### About StormForge

StormForge is an enterprise domain modeling platform consisting of:

- **Backend Service**: Rust-based REST API (Axum framework)
- **Database Layer**: MongoDB (cloud) + SQLite (local)
- **Frontend**: Flutter web/desktop application
- **Code Generators**: Rust and Dart code generation tools

### Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                   Users/Clients                  │
└─────────────────┬───────────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    ┌────▼─────┐     ┌────▼─────┐
    │ Flutter  │     │ Flutter  │
    │   Web    │     │ Desktop  │
    └────┬─────┘     └────┬─────┘
         │                │
         └────────┬───────┘
                  │ HTTPS/REST
         ┌────────▼────────┐
         │  StormForge     │
         │  Backend API    │
         │  (Axum/Rust)    │
         └────┬──────┬─────┘
              │      │
     ┌────────▼──┐ ┌▼────────┐
     │ MongoDB   │ │ SQLite  │
     │ (Cloud)   │ │ (Local) │
     └───────────┘ └─────────┘
```

### Administrator Responsibilities

- Deploy and maintain backend services
- Manage databases (MongoDB, SQLite)
- Configure security (JWT, SSL/TLS)
- Monitor system health and performance
- Manage user accounts and permissions
- Handle backups and disaster recovery
- Troubleshoot issues and optimize performance

---

## System Requirements

### Hardware Requirements

#### Minimum (Development/Small Teams)

- **CPU**: 2 cores, 2.0 GHz
- **RAM**: 4 GB
- **Storage**: 20 GB SSD
- **Network**: 10 Mbps

#### Recommended (Production/Medium Teams)

- **CPU**: 4 cores, 2.5 GHz
- **RAM**: 8 GB
- **Storage**: 100 GB SSD
- **Network**: 100 Mbps

#### Enterprise (Large Teams/High Load)

- **CPU**: 8+ cores, 3.0+ GHz
- **RAM**: 16+ GB
- **Storage**: 500+ GB SSD (NVMe preferred)
- **Network**: 1 Gbps

### Software Requirements

#### Backend Server

- **OS**: Linux (Ubuntu 20.04+, CentOS 8+, Debian 11+), macOS, Windows Server
- **Rust**: 1.70 or later
- **MongoDB**: 5.0 or later
- **SQLite**: 3.35 or later (bundled)

#### Optional

- **Docker**: 20.10+ (for containerized deployment)
- **Kubernetes**: 1.21+ (for orchestration)
- **Nginx**: 1.18+ (reverse proxy)
- **Let's Encrypt**: (SSL certificates)

### Network Requirements

- **Ports**:
  - `3000`: Backend API (HTTP/HTTPS)
  - `27017`: MongoDB (if not using MongoDB Atlas)
  - `80/443`: Web frontend (via reverse proxy)

- **Firewall**: Allow inbound traffic on required ports
- **DNS**: Configured domain name for production

---

## Installation and Deployment

### Method 1: Direct Installation (Development)

#### 1. Install Dependencies

**Ubuntu/Debian**:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

**macOS**:
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install MongoDB
brew tap mongodb/brew
brew install mongodb-community@5.0
brew services start mongodb-community@5.0
```

#### 2. Clone Repository

```bash
git clone https://github.com/Genuineh/StormForge.git
cd StormForge/stormforge_backend
```

#### 3. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit configuration
nano .env
```

**Configuration** (`.env`):
```bash
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017
DATABASE_NAME=stormforge

# SQLite Configuration (local storage)
SQLITE_PATH=./stormforge.db

# JWT Configuration (CHANGE IN PRODUCTION!)
JWT_SECRET=your-secret-key-change-in-production-use-openssl-rand-base64-32

# Server Configuration
PORT=3000
HOST=0.0.0.0

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:8080,https://yourdomain.com

# Logging
RUST_LOG=info
```

#### 4. Build and Run

```bash
# Build
cargo build --release

# Run
./target/release/stormforge-backend

# Or run directly
cargo run --release
```

#### 5. Verify Installation

```bash
# Health check
curl http://localhost:3000/health

# Expected output:
# {"status":"ok","version":"1.0.0"}

# API documentation
curl http://localhost:3000/api-docs/openapi.json
```

---

### Method 2: Docker Deployment

#### 1. Create Dockerfile

**File**: `stormforge_backend/Dockerfile`

```dockerfile
FROM rust:1.75-slim as builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/stormforge-backend .
COPY .env.example .env

EXPOSE 3000

CMD ["./stormforge-backend"]
```

#### 2. Create docker-compose.yml

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:5.0
    container_name: stormforge-mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    networks:
      - stormforge-network

  backend:
    build: ./stormforge_backend
    container_name: stormforge-backend
    ports:
      - "3000:3000"
    environment:
      MONGODB_URI: mongodb://admin:${MONGO_PASSWORD}@mongodb:27017
      DATABASE_NAME: stormforge
      JWT_SECRET: ${JWT_SECRET}
      RUST_LOG: info
    depends_on:
      - mongodb
    volumes:
      - ./data:/app/data
    networks:
      - stormforge-network
    restart: unless-stopped

volumes:
  mongodb_data:

networks:
  stormforge-network:
    driver: bridge
```

#### 3. Deploy with Docker Compose

```bash
# Create .env file for secrets
echo "MONGO_PASSWORD=$(openssl rand -base64 32)" > .env
echo "JWT_SECRET=$(openssl rand -base64 32)" >> .env

# Start services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

---

### Method 3: Kubernetes Deployment

#### 1. Create Kubernetes Manifests

**secrets.yaml**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: stormforge-secrets
type: Opaque
stringData:
  mongodb-password: CHANGE_ME
  jwt-secret: CHANGE_ME
```

**mongodb-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:5.0
        ports:
        - containerPort: 27017
        env:
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: stormforge-secrets
              key: mongodb-password
        volumeMounts:
        - name: mongodb-storage
          mountPath: /data/db
      volumes:
      - name: mongodb-storage
        persistentVolumeClaim:
          claimName: mongodb-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
spec:
  ports:
  - port: 27017
  selector:
    app: mongodb
```

**backend-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stormforge-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: stormforge-backend
  template:
    metadata:
      labels:
        app: stormforge-backend
    spec:
      containers:
      - name: backend
        image: your-registry/stormforge-backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: MONGODB_URI
          value: "mongodb://mongodb:27017"
        - name: DATABASE_NAME
          value: "stormforge"
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: stormforge-secrets
              key: jwt-secret
        - name: RUST_LOG
          value: "info"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: stormforge-backend
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: stormforge-backend
```

#### 2. Deploy to Kubernetes

```bash
# Create namespace
kubectl create namespace stormforge

# Apply secrets (update values first!)
kubectl apply -f secrets.yaml -n stormforge

# Deploy MongoDB
kubectl apply -f mongodb-deployment.yaml -n stormforge

# Deploy backend
kubectl apply -f backend-deployment.yaml -n stormforge

# Check status
kubectl get pods -n stormforge
kubectl get services -n stormforge

# View logs
kubectl logs -f deployment/stormforge-backend -n stormforge
```

---

## Database Administration

### MongoDB Administration

#### Connection

```bash
# Local connection
mongosh mongodb://localhost:27017/stormforge

# With authentication
mongosh "mongodb://admin:password@localhost:27017/stormforge?authSource=admin"

# MongoDB Atlas
mongosh "mongodb+srv://user:pass@cluster.mongodb.net/stormforge"
```

#### Database Schema

StormForge uses 6 main collections:

1. **users**: User accounts and global roles
2. **projects**: Project metadata and settings
3. **project_members**: Team membership and project roles
4. **entities**: Entity definitions
5. **read_models**: Read model definitions
6. **commands**: Command definitions

#### Creating Indexes

**Critical for Performance**:

```javascript
// Connect to database
use stormforge;

// Users collection
db.users.createIndex({ "username": 1 }, { unique: true });
db.users.createIndex({ "email": 1 }, { unique: true });

// Projects collection
db.projects.createIndex({ "owner_id": 1 });
db.projects.createIndex({ "namespace": 1 }, { unique: true });
db.projects.createIndex({ "created_at": -1 });

// Project members collection
db.project_members.createIndex({ "project_id": 1, "user_id": 1 }, { unique: true });
db.project_members.createIndex({ "user_id": 1 });

// Entities collection
db.entities.createIndex({ "project_id": 1 });
db.entities.createIndex({ "project_id": 1, "name": 1 }, { unique: true });

// Read models collection
db.read_models.createIndex({ "project_id": 1 });
db.read_models.createIndex({ "project_id": 1, "name": 1 }, { unique: true });

// Commands collection
db.commands.createIndex({ "project_id": 1 });
db.commands.createIndex({ "project_id": 1, "name": 1 }, { unique: true });
```

#### Backup MongoDB

**Manual Backup**:
```bash
# Dump entire database
mongodump --uri="mongodb://localhost:27017/stormforge" --out=/backup/stormforge-$(date +%Y%m%d)

# Dump specific collection
mongodump --uri="mongodb://localhost:27017/stormforge" --collection=projects --out=/backup/projects-$(date +%Y%m%d)

# Restore
mongorestore --uri="mongodb://localhost:27017/stormforge" /backup/stormforge-20251209/
```

**Automated Backup Script**:
```bash
#!/bin/bash
# /usr/local/bin/backup-stormforge.sh

BACKUP_DIR="/backup/stormforge"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MONGO_URI="mongodb://localhost:27017/stormforge"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
mongodump --uri="$MONGO_URI" --out="$BACKUP_DIR/backup-$TIMESTAMP"

# Compress
tar -czf "$BACKUP_DIR/backup-$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" "backup-$TIMESTAMP"
rm -rf "$BACKUP_DIR/backup-$TIMESTAMP"

# Keep only last 7 days
find $BACKUP_DIR -name "backup-*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/backup-$TIMESTAMP.tar.gz"
```

**Cron Job** (daily at 2 AM):
```bash
0 2 * * * /usr/local/bin/backup-stormforge.sh >> /var/log/stormforge-backup.log 2>&1
```

#### MongoDB Monitoring

```javascript
// Check database stats
db.stats();

// Check collection stats
db.projects.stats();

// Monitor active operations
db.currentOp();

// Check slow queries
db.system.profile.find().limit(10).sort({ ts: -1 });

// Enable profiling (captures slow queries > 100ms)
db.setProfilingLevel(1, { slowms: 100 });
```

### SQLite Administration

#### Location

Default: `./stormforge.db` (configurable via `SQLITE_PATH`)

#### Backup SQLite

```bash
# Copy file backup
cp stormforge.db stormforge-$(date +%Y%m%d).db

# Or use sqlite3 backup command
sqlite3 stormforge.db ".backup 'stormforge-backup.db'"
```

#### Maintenance

```bash
# Open database
sqlite3 stormforge.db

# Check integrity
PRAGMA integrity_check;

# Optimize database
VACUUM;

# Analyze tables for query optimization
ANALYZE;

# View table schema
.schema projects
```

#### SQLite Sync Queue

SQLite maintains a sync queue for offline-first operation:

```sql
-- View pending sync operations
SELECT * FROM sync_queue WHERE synced = 0;

-- Count pending operations
SELECT COUNT(*) FROM sync_queue WHERE synced = 0;

-- Clear synced operations (older than 7 days)
DELETE FROM sync_queue 
WHERE synced = 1 
  AND synced_at < datetime('now', '-7 days');
```

---

## User Management

### Creating Admin User

**Via Backend API**:

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@company.com",
    "displayName": "System Administrator",
    "password": "SecurePassword123!",
    "role": "admin"
  }'
```

**Via MongoDB**:

```javascript
use stormforge;

db.users.insertOne({
  "id": "user-" + new Date().getTime(),
  "username": "admin",
  "email": "admin@company.com",
  "displayName": "System Administrator",
  "passwordHash": "$2b$12$HASHED_PASSWORD",  // Use bcrypt to hash
  "role": "admin",
  "createdAt": new Date(),
  "updatedAt": new Date()
});
```

### User Roles and Permissions

#### Global Roles

| Role | Permissions |
|------|-------------|
| **admin** | Full system access, user management, system settings |
| **manager** | Create projects, manage own teams, view all projects |
| **developer** | Create and edit own projects, collaborate on team projects |
| **viewer** | Read-only access to permitted projects |

#### Changing User Role

```bash
# Via API (requires admin token)
curl -X PUT http://localhost:3000/api/users/{user_id} \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "manager"}'
```

```javascript
// Via MongoDB
db.users.updateOne(
  { "username": "john.doe" },
  { $set: { "role": "manager", "updatedAt": new Date() } }
);
```

### Disabling User Accounts

```javascript
// Add 'disabled' field to user document
db.users.updateOne(
  { "username": "inactive.user" },
  { $set: { "disabled": true, "disabledAt": new Date() } }
);

// Re-enable
db.users.updateOne(
  { "username": "inactive.user" },
  { $unset: { "disabled": "", "disabledAt": "" } }
);
```

### Password Reset

```bash
# Generate password reset token (implement in backend)
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'

# User receives email with reset link
# User submits new password with token
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "reset-token-here",
    "newPassword": "NewSecurePassword123!"
  }'
```

---

## Security Configuration

### JWT Configuration

#### Generating Secure JWT Secret

```bash
# Generate 256-bit random key
openssl rand -base64 32

# Example output:
# K7gNU3sdo+OL0wNhqoVWhr3g6s1xYv72ol/pe/Unols=
```

**Set in `.env`**:
```bash
JWT_SECRET=K7gNU3sdo+OL0wNhqoVWhr3g6s1xYv72ol/pe/Unols=
```

#### JWT Token Expiration

Default: 24 hours

**Configure in code** (`src/auth/jwt.rs`):
```rust
// Change token expiration
let expiration = Utc::now()
    .checked_add_signed(Duration::hours(24))  // Change to desired duration
    .unwrap();
```

### SSL/TLS Configuration

#### Using Nginx as Reverse Proxy

**Install Nginx**:
```bash
sudo apt install nginx
```

**Nginx Configuration** (`/etc/nginx/sites-available/stormforge`):
```nginx
server {
    listen 80;
    server_name stormforge.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name stormforge.yourdomain.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/stormforge.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/stormforge.yourdomain.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Proxy to backend
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend static files
    location / {
        root /var/www/stormforge;
        try_files $uri $uri/ /index.html;
    }
}
```

**Enable and restart**:
```bash
sudo ln -s /etc/nginx/sites-available/stormforge /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Obtaining SSL Certificate (Let's Encrypt)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d stormforge.yourdomain.com

# Auto-renewal (cron job added automatically)
sudo certbot renew --dry-run
```

### CORS Configuration

**Configure allowed origins** (`.env`):
```bash
CORS_ALLOWED_ORIGINS=https://stormforge.yourdomain.com,https://app.yourdomain.com
```

**Or in code** (`src/main.rs`):
```rust
let cors = CorsLayer::new()
    .allow_origin([
        "https://stormforge.yourdomain.com".parse().unwrap(),
        "https://app.yourdomain.com".parse().unwrap(),
    ])
    .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
    .allow_headers([CONTENT_TYPE, AUTHORIZATION]);
```

### Rate Limiting

**Using Nginx**:
```nginx
# Add to http block in nginx.conf
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

# Add to location block
location /api/ {
    limit_req zone=api burst=20 nodelay;
    # ... rest of proxy config
}
```

### Security Best Practices

1. **Always use HTTPS** in production
2. **Rotate JWT secrets** periodically (every 90 days)
3. **Use strong passwords**: Minimum 12 characters, mixed case, numbers, symbols
4. **Enable MongoDB authentication** in production
5. **Firewall**: Only expose necessary ports
6. **Regular updates**: Keep Rust, MongoDB, system packages updated
7. **Audit logs**: Enable and monitor authentication attempts
8. **Backup encryption**: Encrypt backup files

---

## Backup and Recovery

### Backup Strategy

#### What to Backup

1. **MongoDB Database**: All collections
2. **SQLite Database**: Local database file
3. **Configuration**: `.env` file, nginx configs
4. **Generated Code**: (optional, can be regenerated)

#### Backup Schedule

- **Daily**: Incremental MongoDB backup
- **Weekly**: Full system backup
- **Monthly**: Archive to off-site storage

### Automated Backup Script

**Full backup script** (`/usr/local/bin/stormforge-full-backup.sh`):

```bash
#!/bin/bash

# Configuration
BACKUP_ROOT="/backup/stormforge"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
S3_BUCKET="s3://your-backup-bucket/stormforge"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# 1. Backup MongoDB
echo "Backing up MongoDB..."
mongodump --uri="mongodb://localhost:27017/stormforge" \
  --out="$BACKUP_DIR/mongodb"

# 2. Backup SQLite
echo "Backing up SQLite..."
cp /path/to/stormforge.db "$BACKUP_DIR/stormforge.db"

# 3. Backup configurations
echo "Backing up configurations..."
mkdir -p "$BACKUP_DIR/config"
cp /path/to/stormforge_backend/.env "$BACKUP_DIR/config/"
cp -r /etc/nginx/sites-available/stormforge "$BACKUP_DIR/config/"

# 4. Compress
echo "Compressing backup..."
cd "$BACKUP_ROOT"
tar -czf "stormforge-backup-$TIMESTAMP.tar.gz" "$TIMESTAMP"
rm -rf "$TIMESTAMP"

# 5. Upload to S3 (optional)
if command -v aws &> /dev/null; then
    echo "Uploading to S3..."
    aws s3 cp "stormforge-backup-$TIMESTAMP.tar.gz" "$S3_BUCKET/"
fi

# 6. Cleanup old local backups (keep 30 days)
find "$BACKUP_ROOT" -name "stormforge-backup-*.tar.gz" -mtime +30 -delete

echo "Backup completed: stormforge-backup-$TIMESTAMP.tar.gz"
```

**Schedule with cron** (daily at 2 AM):
```bash
0 2 * * * /usr/local/bin/stormforge-full-backup.sh >> /var/log/stormforge-backup.log 2>&1
```

### Recovery Procedures

#### Recovering MongoDB

```bash
# Extract backup
cd /backup/stormforge
tar -xzf stormforge-backup-20251209_020000.tar.gz

# Restore database
mongorestore --uri="mongodb://localhost:27017/stormforge" \
  --drop \
  20251209_020000/mongodb/stormforge/

# Verify
mongosh mongodb://localhost:27017/stormforge
> db.users.count()
> db.projects.count()
```

#### Recovering SQLite

```bash
# Stop backend service
sudo systemctl stop stormforge-backend

# Restore database
cp /backup/stormforge/20251209_020000/stormforge.db /path/to/stormforge.db

# Start backend service
sudo systemctl start stormforge-backend
```

#### Disaster Recovery Plan

1. **Prepare**:
   - Document all configurations
   - Test restore procedures monthly
   - Maintain off-site backups

2. **Recovery Steps**:
   ```bash
   # 1. Provision new server
   # 2. Install dependencies
   # 3. Restore databases
   # 4. Restore configurations
   # 5. Start services
   # 6. Verify functionality
   # 7. Update DNS if needed
   ```

3. **Verification**:
   - Test user login
   - Open existing project
   - Create new project
   - Export IR
   - Generate code

---

## Monitoring and Logging

### Application Logs

#### Log Levels

Configure via `RUST_LOG` environment variable:

```bash
# All logs
RUST_LOG=trace

# Debug and above
RUST_LOG=debug

# Info and above (recommended for production)
RUST_LOG=info

# Warnings and errors only
RUST_LOG=warn

# Errors only
RUST_LOG=error
```

#### Viewing Logs

**Direct run**:
```bash
cargo run --release
```

**systemd service**:
```bash
sudo journalctl -u stormforge-backend -f
```

**Docker**:
```bash
docker logs -f stormforge-backend
```

### Structured Logging

Logs include:

- **Timestamp**: ISO 8601 format
- **Level**: TRACE, DEBUG, INFO, WARN, ERROR
- **Target**: Module path
- **Message**: Log message
- **Context**: Request ID, user ID, etc.

**Example**:
```
2025-12-09T10:30:45.123Z INFO stormforge_backend::api: User logged in user_id="user-123" ip="192.168.1.100"
2025-12-09T10:30:46.456Z INFO stormforge_backend::api: Project created project_id="proj-456" owner_id="user-123"
```

### Log Aggregation

#### Using ELK Stack (Elasticsearch, Logstash, Kibana)

**1. Filebeat configuration** (`/etc/filebeat/filebeat.yml`):
```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/stormforge/*.log
  fields:
    app: stormforge
    env: production

output.elasticsearch:
  hosts: ["localhost:9200"]
  index: "stormforge-%{+yyyy.MM.dd}"
```

**2. Logstash pipeline** (`/etc/logstash/conf.d/stormforge.conf`):
```ruby
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{DATA:target}: %{GREEDYDATA:message}" }
  }
  date {
    match => [ "timestamp", "ISO8601" ]
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "stormforge-%{+YYYY.MM.dd}"
  }
}
```

### Monitoring Metrics

#### Health Check Endpoint

```bash
curl http://localhost:3000/health

# Response:
{
  "status": "ok",
  "version": "1.0.0",
  "uptime": 86400,
  "database": {
    "mongodb": "connected",
    "sqlite": "ok"
  }
}
```

#### System Metrics

Monitor with tools like:

- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **Node Exporter**: System metrics

**Example Prometheus configuration** (`prometheus.yml`):
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'stormforge'
    static_configs:
      - targets: ['localhost:3000']
```

#### Key Metrics to Monitor

1. **Request Rate**: Requests per second
2. **Response Time**: p50, p95, p99 latencies
3. **Error Rate**: 4xx, 5xx responses
4. **Database Connections**: Active connections
5. **Memory Usage**: Heap usage, RSS
6. **CPU Usage**: CPU percentage
7. **Disk I/O**: Read/write rates

### Alerting

**Example Alertmanager rule** (`alerts.yml`):
```yaml
groups:
- name: stormforge
  interval: 30s
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
    for: 5m
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} requests/sec"
      
  - alert: DatabaseDown
    expr: up{job="mongodb"} == 0
    for: 1m
    annotations:
      summary: "MongoDB is down"
      
  - alert: HighMemoryUsage
    expr: process_resident_memory_bytes > 2e9
    for: 5m
    annotations:
      summary: "High memory usage"
      description: "Memory usage is {{ $value }} bytes"
```

---

## Performance Tuning

### MongoDB Optimization

#### Indexes

Ensure all critical indexes exist (see Database Administration section).

#### Connection Pooling

**Configure in code**:
```rust
let client_options = ClientOptions::parse(&mongo_uri).await?
    .with_min_pool_size(10)
    .with_max_pool_size(100)
    .with_connect_timeout(Duration::from_secs(10))
    .with_server_selection_timeout(Duration::from_secs(10));
```

#### Query Optimization

```javascript
// Use projection to return only needed fields
db.projects.find(
  { owner_id: "user-123" },
  { name: 1, namespace: 1, created_at: 1 }
);

// Use limit for large result sets
db.entities.find({ project_id: "proj-456" }).limit(100);

// Analyze slow queries
db.system.profile.find({ millis: { $gt: 100 } }).sort({ ts: -1 });
```

### Backend Optimization

#### Caching

Implement caching for frequent queries:

```rust
use cached::proc_macro::cached;

#[cached(time = 300, result = true)]  // Cache for 5 minutes
async fn get_project(project_id: String) -> Result<Project> {
    // Database query
}
```

#### Connection Pooling

```rust
// Configure Axum with appropriate thread pool
let app = Router::new()
    // ... routes
    .layer(Extension(db_pool))
    .layer(tower_http::limit::RequestBodyLimitLayer::new(10 * 1024 * 1024));  // 10MB limit

// Run with multiple worker threads
let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;
axum::serve(listener, app).await?;
```

#### Response Compression

Enable gzip compression:

```rust
use tower_http::compression::CompressionLayer;

let app = Router::new()
    // ... routes
    .layer(CompressionLayer::new());
```

### System-Level Tuning

#### File Descriptors

Increase limit for high concurrency:

```bash
# /etc/security/limits.conf
*  soft  nofile  65536
*  hard  nofile  65536
```

#### TCP Tuning

```bash
# /etc/sysctl.conf
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_fin_timeout = 30
```

Apply:
```bash
sudo sysctl -p
```

---

## Troubleshooting

### Common Issues

#### Issue: Backend won't start

**Symptoms**:
```
Error: failed to connect to MongoDB
```

**Solutions**:
1. Check MongoDB is running:
   ```bash
   sudo systemctl status mongod
   ```
2. Verify connection string in `.env`
3. Check network connectivity:
   ```bash
   telnet localhost 27017
   ```
4. Review MongoDB logs:
   ```bash
   sudo tail -f /var/log/mongodb/mongod.log
   ```

#### Issue: High memory usage

**Symptoms**:
- Backend process using > 2GB RAM
- OOM killer terminating process

**Solutions**:
1. Check for memory leaks with valgrind
2. Implement pagination for large queries
3. Increase server RAM
4. Add connection limits
5. Clear SQLite sync queue:
   ```sql
   DELETE FROM sync_queue WHERE synced = 1 AND synced_at < datetime('now', '-7 days');
   ```

#### Issue: Slow API responses

**Symptoms**:
- Requests taking > 1 second
- Timeout errors

**Solutions**:
1. Check MongoDB indexes:
   ```javascript
   db.projects.getIndexes();
   ```
2. Analyze slow queries:
   ```javascript
   db.setProfilingLevel(1, { slowms: 100 });
   db.system.profile.find().sort({ ts: -1 }).limit(10);
   ```
3. Add missing indexes
4. Enable caching
5. Optimize queries (use projection, limit)

#### Issue: JWT authentication fails

**Symptoms**:
```
Error: invalid token
Error: token expired
```

**Solutions**:
1. Verify JWT_SECRET matches across instances
2. Check token expiration time
3. Validate token format:
   ```bash
   echo "TOKEN" | jwt decode -
   ```
4. Check system time synchronization:
   ```bash
   timedatectl status
   ```

### Debug Mode

Enable detailed logging:

```bash
RUST_LOG=debug cargo run --release
```

Or in production:
```bash
RUST_LOG=debug systemctl restart stormforge-backend
```

### Health Checks

**Comprehensive health check script**:

```bash
#!/bin/bash
# /usr/local/bin/health-check.sh

echo "=== StormForge Health Check ==="

# 1. Backend API
echo -n "Backend API: "
if curl -sf http://localhost:3000/health > /dev/null; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

# 2. MongoDB
echo -n "MongoDB: "
if mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

# 3. SQLite
echo -n "SQLite: "
if [ -f ./stormforge.db ]; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

# 4. Disk space
echo -n "Disk space: "
USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $USAGE -lt 90 ]; then
    echo "✓ OK ($USAGE%)"
else
    echo "⚠ Warning ($USAGE%)"
fi

# 5. Memory
echo -n "Memory: "
MEM_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2*100}')
if [ $MEM_USAGE -lt 90 ]; then
    echo "✓ OK ($MEM_USAGE%)"
else
    echo "⚠ Warning ($MEM_USAGE%)"
fi

echo "=== End Health Check ==="
```

---

## Upgrade Procedures

### Upgrading Backend

#### Preparation

1. **Backup**: Full system backup
2. **Review**: Check release notes for breaking changes
3. **Test**: Test upgrade in staging environment
4. **Schedule**: Plan maintenance window

#### Upgrade Steps

**Method 1: Direct upgrade**:

```bash
# 1. Backup
/usr/local/bin/stormforge-full-backup.sh

# 2. Stop service
sudo systemctl stop stormforge-backend

# 3. Pull latest code
cd /path/to/StormForge
git pull origin main

# 4. Build new version
cd stormforge_backend
cargo build --release

# 5. Run migrations (if any)
./target/release/stormforge-backend migrate

# 6. Start service
sudo systemctl start stormforge-backend

# 7. Verify
curl http://localhost:3000/health
```

**Method 2: Blue-Green deployment**:

```bash
# 1. Deploy new version to port 3001
# 2. Test thoroughly
# 3. Update load balancer to point to 3001
# 4. Monitor for issues
# 5. Decommission old version (3000)
```

### Database Migrations

If schema changes are required:

```bash
# Run migration tool
./migration-tool upgrade

# Or manually via MongoDB
mongosh mongodb://localhost:27017/stormforge < migrations/v2.0.js
```

### Rollback Procedure

If upgrade fails:

```bash
# 1. Stop new version
sudo systemctl stop stormforge-backend

# 2. Restore database from backup
mongorestore --uri="mongodb://localhost:27017/stormforge" \
  --drop /backup/stormforge/latest/mongodb/

# 3. Restore old binary
cp /backup/stormforge-backend-old /path/to/stormforge-backend

# 4. Start old version
sudo systemctl start stormforge-backend

# 5. Verify
curl http://localhost:3000/health
```

---

## Appendix

### Useful Commands

#### System Management

```bash
# Check service status
sudo systemctl status stormforge-backend

# Start/stop/restart service
sudo systemctl start stormforge-backend
sudo systemctl stop stormforge-backend
sudo systemctl restart stormforge-backend

# View logs
sudo journalctl -u stormforge-backend -f

# Check resource usage
htop
docker stats
```

#### Database Management

```bash
# MongoDB shell
mongosh mongodb://localhost:27017/stormforge

# Database backup
mongodump --uri="mongodb://localhost:27017/stormforge" --out=/backup/

# Database restore
mongorestore --uri="mongodb://localhost:27017/stormforge" /backup/stormforge/

# SQLite backup
sqlite3 stormforge.db ".backup 'backup.db'"
```

#### Network Diagnostics

```bash
# Check ports
sudo netstat -tlnp | grep 3000
sudo ss -tlnp | grep 3000

# Test connectivity
curl -v http://localhost:3000/health
telnet localhost 3000

# Check firewall
sudo ufw status
sudo iptables -L
```

### Configuration Templates

See example configurations in:
- `/stormforge_backend/.env.example`
- `/docs/configs/nginx.conf.example`
- `/docs/configs/systemd.service.example`

### Support Resources

- **Documentation**: `/docs/`
- **API Reference**: `/docs/guides/api-reference.md`
- **User Guide**: `/docs/guides/user-guide.md`
- **GitHub Issues**: https://github.com/Genuineh/StormForge/issues

---

**Administrator Guide Version**: 2.0  
**Last Updated**: December 2025  
**Questions?** Refer to troubleshooting section or contact support.

