# Linux Platform Files

This directory contains the Linux-specific build configuration for the StormForge Modeler Flutter application.

## Build Prerequisites

**CRITICAL:** Before building the Linux application, you MUST run `flutter pub get` from the `stormforge_modeler` directory. This generates the ephemeral `flutter/` subdirectory and `generated_plugins.cmake` file that are required by CMake.

If you see errors like:
- "The source directory .../linux/flutter does not contain a CMakeLists.txt file"
- "Unknown CMake command 'apply_standard_settings'"

This means you haven't run `flutter pub get` yet. Run it now:

```bash
cd stormforge_modeler
flutter pub get
```

## Storage Implementation

This application uses `shared_preferences` for local storage instead of `flutter_secure_storage` to ensure compatibility with Linux. The `flutter_secure_storage_linux` plugin previously caused build issues with newer Clang compilers due to deprecated literal operator syntax in its bundled `json.hpp` library.

## Regenerating These Files

If you need to regenerate the Linux platform files (e.g., after a Flutter upgrade), you can run:

```bash
cd stormforge_modeler
flutter create --platforms=linux .
```

## Files in This Directory

- `CMakeLists.txt` - Main build configuration
- `main.cc` - Application entry point
- `my_application.h` / `my_application.cc` - Application implementation
- `flutter/` - Flutter-managed build files (ignored by git)
- `.gitattributes` - Marks this directory as auto-generated
