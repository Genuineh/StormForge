#!/bin/bash
# StormForge Backend Toolchain launcher script
# This script provides a convenient way to run the toolchain tool

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if binary exists, if not build it
if [ ! -f "target/release/stormforge_backend_toolchain" ]; then
    echo "Building stormforge_backend_toolchain..."
    cargo build --release
    echo "Build complete!"
fi

# Run the tool
exec ./target/release/stormforge_backend_toolchain "$@"
