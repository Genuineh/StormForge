# StormForge Backend Toolchain

A visual TUI (Terminal User Interface) tool for managing the StormForge backend lifecycle. Built with Rust and ratatui, this tool provides an interactive way to setup, start, monitor, and cleanup the backend services.

## Screenshot

```
┌────────────────────────────────────────────────────────────────────┐
│              StormForge Backend Toolchain                          │
├──────────────────────┬─────────────────────────────────────────────┤
│ Menu                 │ Recent Activity                             │
│                      │                                             │
│ 1. Setup Environment │ [10:23:45] MongoDB started successfully     │
│ 2. Start MongoDB     │ [10:23:40] ✓ Created .env from .env.example │
│ 3. Build Backend     │ [10:23:35] Building backend...             │
│ 4. Start Backend     │                                             │
│ 5. View Status       │                                             │
│ 6. View Logs         │                                             │
│ 7. Stop Backend      │                                             │
│ 8. Stop MongoDB      │                                             │
│ 9. Cleanup All       │                                             │
│ 10. Configuration    │                                             │
│ Q. Quit              │                                             │
│                      │                                             │
├──────────────────────┴─────────────────────────────────────────────┤
│ ↑/↓: Navigate | Enter: Select | Q/Esc: Quit                       │
└────────────────────────────────────────────────────────────────────┘
```

## Features

- 🚀 **One-command setup**: Initialize environment and start all services
- 📊 **Visual dashboard**: Monitor service status in real-time
- 📝 **Log viewer**: View and navigate through service logs
- ⚙️ **Configuration viewer**: Quick access to .env configuration
- 🧹 **Complete cleanup**: Stop and remove all services with one command
- 🎨 **User-friendly TUI**: Intuitive keyboard navigation

## Prerequisites

- Rust 1.70 or later
- Docker (for MongoDB)
- cargo (Rust package manager)

## Installation

### Build from source

```bash
cd stormforge_backend_toolchain
cargo build --release
```

The binary will be available at `target/release/stormforge_backend_toolchain`.

## Usage

### Starting the tool

```bash
# From the stormforge_backend_toolchain directory

# Option 1: Using the convenience script (auto-builds if needed)
./run.sh

# Option 2: Using cargo run
cargo run

# Option 3: Use the compiled binary directly
./target/release/stormforge_backend_toolchain
```

### Navigation

The tool uses an intuitive menu-based interface:

**Main Menu:**
- `↑`/`↓` or `k`/`j`: Navigate menu items
- `Enter`: Select menu item
- `Q` or `Esc`: Quit

**Status View:**
- `r`: Refresh status
- `Q` or `Esc`: Back to menu

**Log Viewer:**
- `↑`/`↓` or `k`/`j`: Scroll logs
- `c`: Clear logs
- `Q` or `Esc`: Back to menu

## Menu Options

### 1. Setup Environment
Creates `.env` file from `.env.example` if it doesn't exist. This is the first step before starting services.

### 2. Start MongoDB
Starts MongoDB using Docker:
```bash
docker run -d -p 27017:27017 --name stormforge_mongodb --rm mongo:latest
```

### 3. Build Backend
Builds the backend in release mode:
```bash
cargo build --release
```

### 4. Start Backend
Starts the backend server. The server will be available at `http://localhost:3000`.

### 5. View Status
Shows the current status of all services:
- MongoDB status
- Backend status
- Backend path
- Health check status

### 6. View Logs
View all activity logs with scrolling support.

### 7. Stop Backend
Gracefully stops the backend server.

### 8. Stop MongoDB
Stops the MongoDB Docker container.

### 9. Cleanup All
Stops all services and removes MongoDB container. Requires confirmation.

### 10. Configuration
View the current `.env` configuration file.

## Quick Start Workflow

1. Start the tool: `cargo run`
2. Select "1. Setup Environment" - Creates .env file
3. Select "2. Start MongoDB" - Starts database
4. Select "3. Build Backend" - Builds the server (first time only)
5. Select "4. Start Backend" - Starts the server
6. Select "5. View Status" - Verify everything is running
7. Access the API at `http://localhost:3000`

When done:
1. Select "9. Cleanup All" - Stops everything
2. Confirm with 'Y'
3. Quit with 'Q'

## Endpoints

Once the backend is running, you can access:

- **API Base**: http://localhost:3000/api
- **Swagger UI**: http://localhost:3000/swagger-ui
- **Health Check**: http://localhost:3000/health

## Troubleshooting

### MongoDB fails to start
- Ensure Docker is installed and running
- Check if port 27017 is available
- Try starting MongoDB manually: `docker run -d -p 27017:27017 --name stormforge_mongodb mongo`

### Backend fails to build
- Ensure you're in the correct directory
- Try cleaning the build: `cargo clean && cargo build`
- Check the logs for specific error messages

### Port 3000 already in use
- Edit the `.env` file and change the PORT value
- Or stop the process using port 3000

## Development

### Project Structure

```
stormforge_backend_toolchain/
├── src/
│   ├── main.rs       # Entry point and event handling
│   ├── backend.rs    # Backend management logic
│   └── ui.rs         # TUI rendering and state management
├── Cargo.toml
└── README.md
```

### Building

```bash
# Debug build
cargo build

# Release build (optimized)
cargo build --release

# Run with cargo
cargo run

# Run tests (if any)
cargo test
```

### Code Quality

```bash
# Format code
cargo fmt

# Run linter
cargo clippy

# Check for errors
cargo check
```

## Architecture

The tool consists of three main components:

1. **Main (`main.rs`)**: 
   - Terminal setup and event loop
   - Keyboard event handling
   - State transitions

2. **Backend Manager (`backend.rs`)**:
   - Service lifecycle management
   - Process spawning and monitoring
   - Docker container management
   - Status checking

3. **UI (`ui.rs`)**:
   - TUI rendering with ratatui
   - Multiple views (menu, status, logs, config)
   - Visual feedback and styling

## Dependencies

- **ratatui**: TUI framework for rendering
- **crossterm**: Terminal manipulation
- **tokio**: Async runtime (for future enhancements)
- **anyhow**: Error handling
- **chrono**: Timestamp generation
- **serde/serde_json**: Configuration parsing

## License

This project is part of StormForge and follows the same MIT license.

## Contributing

Contributions are welcome! Please ensure:
- Code follows Rust conventions
- Run `cargo fmt` and `cargo clippy` before submitting
- Test the tool thoroughly with various scenarios

## Support

For issues or questions:
- Check the main StormForge documentation
- Review the backend QUICKSTART guide
- Open an issue on GitHub

---

**Happy coding!** 🚀
