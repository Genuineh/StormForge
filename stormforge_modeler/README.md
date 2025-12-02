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

### Running the Application

```bash
cd stormforge_modeler
flutter pub get
flutter run
```

## Development Status

- [x] Project structure defined
- [ ] Basic canvas implementation
- [ ] Element types implementation
- [ ] Drag and drop functionality
- [ ] YAML export/import
- [ ] Git integration
- [ ] AI integration

## License

MIT License - See [LICENSE](../LICENSE) for details.
