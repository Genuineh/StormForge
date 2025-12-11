# StormForge Backend - Quick Start Guide

## Easy Start with Visual Toolchain 🚀

**NEW!** We now have a visual TUI tool that automates all the steps below. If you prefer an interactive terminal interface:

```bash
cd stormforge_backend_toolchain
cargo run
```

Follow the on-screen menu to:
- Setup environment
- Start MongoDB
- Build and start backend
- Monitor status
- View logs
- Cleanup everything

For more details, see [stormforge_backend_toolchain/README.md](../stormforge_backend_toolchain/README.md).

---

## Manual Setup (Traditional Way)

## Prerequisites

Before running the backend, ensure you have:

1. **Rust** (1.70 or later)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **MongoDB** (for cloud storage)
   - Install locally: https://www.mongodb.com/try/download/community
   - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas
   - Or use Docker: `docker run -d -p 27017:27017 --name mongodb mongo`

## Quick Start

### 1. Configuration

Copy the example environment file:
```bash
cd stormforge_backend
cp .env.example .env
```

Edit `.env` with your settings:
```bash
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017
DATABASE_NAME=stormforge

# SQLite Configuration (local storage)
SQLITE_PATH=./stormforge.db

# JWT Configuration (CHANGE IN PRODUCTION!)
JWT_SECRET=your-secret-key-change-in-production

# Server Configuration
PORT=3000

# Default Admin Account (optional)
# Set INIT_DEFAULT_ADMIN=true to auto-create an admin user on startup
INIT_DEFAULT_ADMIN=true
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_EMAIL=admin@stormforge.local
DEFAULT_ADMIN_DISPLAY_NAME=Administrator
DEFAULT_ADMIN_PASSWORD=admin123
```

**Note**: If `INIT_DEFAULT_ADMIN=true`, the server will create a default admin account on first startup. Change the password immediately after first login!

### 2. Build and Run

```bash
# Build the project
cargo build

# Run the server
cargo run

# Or build and run in release mode (faster)
cargo run --release
```

The server will start on `http://localhost:3000`

### 3. Access API Documentation

Once the server is running, open your browser:

- **Swagger UI**: http://localhost:3000/swagger-ui
- **Health Check**: http://localhost:3000/health

## Testing the API

### Using Swagger UI

1. Go to http://localhost:3000/swagger-ui
2. Try the endpoints interactively
3. Click "Try it out" on any endpoint
4. Fill in the parameters and click "Execute"

### Using cURL

#### Register a new user
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "displayName": "Test User",
    "password": "securepassword123",
    "role": "developer"
  }'
```

#### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "testuser",
    "password": "securepassword123"
  }'
```

Save the token from the response!

#### Create a project
```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My First Project",
    "namespace": "my-first-project",
    "description": "A test project",
    "visibility": "private"
  }'
```

#### List all users
```bash
curl http://localhost:3000/api/users
```

## Development

### Run in development mode with auto-reload
```bash
cargo install cargo-watch
cargo watch -x run
```

### Run tests
```bash
cargo test
```

### Check code quality
```bash
# Format code
cargo fmt

# Run linter
cargo clippy

# Check for errors
cargo check
```

## Troubleshooting

### MongoDB Connection Issues

If you see "failed to connect to MongoDB":
1. Check if MongoDB is running: `mongosh` or `mongo`
2. Check your MONGODB_URI in `.env`
3. If using Docker: `docker ps` to verify container is running

### Port Already in Use

If port 3000 is already in use:
1. Change PORT in `.env` to another port (e.g., 3001)
2. Or stop the process using port 3000

### Compilation Errors

If you encounter build errors:
```bash
# Clean build cache
cargo clean

# Update dependencies
cargo update

# Rebuild
cargo build
```

## Next Steps

1. **Explore the API**: Use Swagger UI to test all endpoints
2. **Integrate with Frontend**: Connect the Flutter Modeler to this backend
3. **Add Authentication Middleware**: Protect endpoints with JWT verification
4. **Implement Sync**: Connect SQLite sync queue to MongoDB
5. **Deploy**: Deploy to production with proper security settings

## Production Deployment

⚠️ **Before deploying to production**:

1. Change `JWT_SECRET` to a strong random value
2. Configure MongoDB authentication
3. Use HTTPS/TLS for all communication
4. Configure CORS for specific origins only
5. Set up monitoring and logging
6. Implement rate limiting
7. Use environment variables for all secrets
8. Enable MongoDB encryption at rest

## Support

For issues or questions:
- Check the main README: `stormforge_backend/README.md`
- Review the architecture docs: `docs/DATABASE_SCHEMA.md`
- See Sprint M1 completion: `docs/sprint_m1_backend_completion.md`

---

**Happy coding!** 🚀
