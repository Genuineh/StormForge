# StormForge Backend

Backend service for StormForge project management system, implementing Sprint M1 requirements.

## Features

- **User Authentication**: JWT-based authentication with bcrypt password hashing
- **User Management**: Complete CRUD operations for users with role-based permissions
- **Project Management**: Create, read, update, and delete projects with settings
- **Team Management**: Add, update, and remove team members with role-based access control
- **Dual Storage**: SQLite for offline-first local storage and MongoDB for cloud synchronization
- **API Documentation**: Swagger UI for interactive API documentation

## Architecture

- **Framework**: Axum (Rust async web framework)
- **Databases**: 
  - MongoDB for cloud storage and team collaboration
  - SQLite for local offline-first development
- **Authentication**: JWT tokens with bcrypt password hashing
- **Documentation**: OpenAPI/Swagger UI

## Getting Started

### Prerequisites

- Rust 1.70 or later
- MongoDB (for cloud storage)
- SQLite (bundled)

### Installation

1. Clone the repository
2. Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

3. Install dependencies and build:

```bash
cargo build
```

### Running the Server

```bash
cargo run
```

The server will start on `http://localhost:3000` by default.

### API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:3000/swagger-ui`
- OpenAPI JSON: `http://localhost:3000/api-docs/openapi.json`

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login and get JWT token

### Users

- `GET /api/users` - List all users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user

### Projects

- `POST /api/projects` - Create a new project
- `GET /api/projects/:id` - Get project by ID
- `GET /api/projects/owner/:owner_id` - List projects by owner
- `PUT /api/projects/:id` - Update project
- `DELETE /api/projects/:id` - Delete project

### Team Members

- `POST /api/projects/:project_id/members` - Add team member
- `GET /api/projects/:project_id/members` - List team members
- `PUT /api/projects/:project_id/members/:user_id` - Update member role
- `DELETE /api/projects/:project_id/members/:user_id` - Remove team member

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGODB_URI` | MongoDB connection string | `mongodb://localhost:27017` |
| `DATABASE_NAME` | MongoDB database name | `stormforge` |
| `SQLITE_PATH` | Path to SQLite database file | `./stormforge.db` |
| `JWT_SECRET` | Secret key for JWT token generation | `your-secret-key-change-in-production` |
| `PORT` | Server port | `3000` |

## Database Schema

### MongoDB Collections

1. **users** - User accounts and global roles
2. **projects** - Project metadata and settings
3. **project_members** - Team membership and roles
4. **project_models** - Model data storage
5. **model_versions** - Version history
6. **project_activities** - Activity timeline

### SQLite Tables

Mirrors MongoDB schema for offline-first operations with additional sync queue table.

See [DATABASE_SCHEMA.md](../docs/DATABASE_SCHEMA.md) for detailed schema documentation.

## Development

### Running Tests

```bash
cargo test
```

### Code Formatting

```bash
cargo fmt
```

### Linting

```bash
cargo clippy
```

## Security Considerations

- Passwords are hashed using bcrypt with default cost factor
- JWT tokens expire after 24 hours
- CORS is enabled for all origins (configure for production)
- Use HTTPS in production
- Change JWT_SECRET in production

## Sprint M1 Completion

This backend implements the following Sprint M1 tasks:

- ✅ Data persistence layer (SQLite + MongoDB)
- ✅ User authentication service (JWT)
- ✅ User management operations
- ✅ Project CRUD operations
- ✅ Team member management

## TODO

- [ ] Implement authentication middleware for protected routes
- [ ] Add pagination for list endpoints
- [ ] Implement model storage and versioning
- [ ] Add activity logging
- [ ] Implement sync queue processing
- [ ] Add comprehensive integration tests
- [ ] Add rate limiting
- [ ] Improve error handling and validation

## License

See main repository LICENSE file.
