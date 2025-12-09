# StormForge Modeler

> Flutter cross-platform EventStorming modeling application

## Overview

The StormForge Modeler is a Flutter application that provides a visual canvas for domain-driven design using EventStorming methodology. It supports Web, Windows, macOS, and iPad platforms.

## Features (Planned)

- **EventStorming Canvas**: Visual modeling with drag-and-drop
- **Domain Elements**: Events, Commands, Aggregates, Policies, Read Models, External Systems
- **Multi-Context Support**: Model multiple Bounded Contexts
- **IR Export**: Export models as YAML for code generation
- **Git Integration**: Version control for models
- **AI Assistance**: Natural language to model conversion

## Project Structure

```
stormforge_modeler/
├── lib/
│   ├── canvas/           # EventStorming canvas components
│   │   ├── elements/     # Canvas element types
│   │   ├── interactions/ # User interaction handlers
│   │   └── rendering/    # Rendering engine
│   ├── models/           # Domain model definitions
│   ├── ir/               # Intermediate Representation handling
│   ├── services/         # Business services
│   └── widgets/          # Reusable UI widgets
└── test/                 # Test files
```

## Getting Started

> This project is in the initialization phase. Code implementation will follow.

### Prerequisites

- Flutter SDK 3.24+
- Dart SDK 3.5+

### Initial Setup

**IMPORTANT:** Before building or running the application, you must run `flutter pub get` to generate required build files. Skipping this step will cause CMake errors like "does not contain a CMakeLists.txt file" or "Unknown CMake command".

```bash
cd stormforge_modeler

# REQUIRED: Install dependencies and generate Flutter build files
flutter pub get

# Optional: Generate platform directories for other platforms (Linux is already configured)
flutter create --platforms=web,windows,macos,ios,android .
```

The Linux platform files are pre-configured with necessary build fixes. For other platforms, you can generate them as needed.

**Note:** The Linux platform includes a CMake configuration fix for the `flutter_secure_storage_linux` plugin. If you need to regenerate Linux files, see `linux/README.md` for important instructions.

### Running the Application

```bash
cd stormforge_modeler

# Generate Flutter build files (required before first run)
flutter pub get

# Run the application
flutter run
```

For specific platforms:
```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d macos       # macOS
flutter run -d linux       # Linux
```

### Troubleshooting

If you encounter build errors or other issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions to common problems.

## Development Status

- [x] Project structure defined
- [x] Basic canvas implementation
- [x] Element types implementation
- [x] Drag and drop functionality
- [x] YAML export/import
- [ ] Git integration
- [ ] AI integration

## License

MIT License - See [LICENSE](../LICENSE) for details.
