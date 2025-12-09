#!/bin/bash
# Setup script for StormForge Modeler Flutter application
# This script checks prerequisites and sets up the development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "StormForge Modeler Setup"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ ERROR: Flutter is not installed or not in PATH"
    echo ""
    echo "Please install Flutter SDK 3.24+ from:"
    echo "  https://docs.flutter.dev/get-started/install"
    echo ""
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | head -n 1 | awk '{print $2}')
echo "✓ Flutter found: $FLUTTER_VERSION"

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ ERROR: pubspec.yaml not found"
    echo "Are you running this script from the stormforge_modeler directory?"
    exit 1
fi

echo ""
echo "Installing dependencies and generating build files..."
echo "This will create the following ephemeral directories:"
echo "  - .dart_tool/"
echo "  - linux/flutter/"
echo "  - and other platform-specific build files"
echo ""

# Run flutter pub get
if flutter pub get; then
    echo ""
    echo "✓ Dependencies installed successfully"
else
    echo ""
    echo "❌ ERROR: Failed to install dependencies"
    exit 1
fi

# Check if linux/flutter directory was created
if [ ! -d "linux/flutter" ]; then
    echo ""
    echo "⚠️  WARNING: linux/flutter directory was not created"
    echo "This might cause build issues on Linux"
else
    echo "✓ Linux build files generated"
fi

# Check if generated_plugins.cmake exists
if [ ! -f "linux/flutter/generated_plugins.cmake" ]; then
    echo ""
    echo "⚠️  WARNING: linux/flutter/generated_plugins.cmake not found"
    echo "This might cause CMake configuration errors"
else
    echo "✓ CMake plugin configuration generated"
fi

echo ""
echo "=========================================="
echo "Setup completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Run the application:"
echo "     flutter run"
echo ""
echo "  2. Or run on a specific platform:"
echo "     flutter run -d linux"
echo "     flutter run -d chrome"
echo "     flutter run -d windows"
echo ""
