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

Before running the application for the first time, you need to generate platform-specific files:

```bash
cd stormforge_modeler

# Generate platform directories for all supported platforms
flutter create --platforms=web,windows,macos,linux,ios,android .

# Install dependencies
flutter pub get
```

### Running the Application

```bash
cd stormforge_modeler
flutter pub get
flutter run
```

For specific platforms:
```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d macos       # macOS
flutter run -d linux       # Linux
```

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
