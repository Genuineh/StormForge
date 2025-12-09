# Troubleshooting Guide

This document covers common issues you might encounter when building or running the StormForge Modeler.

## Build Issues

### CMake Error: "does not contain a CMakeLists.txt file"

**Error Message:**
```
CMake Error at CMakeLists.txt:31 (add_subdirectory):
  The source directory
    /path/to/stormforge_modeler/linux/flutter
  does not contain a CMakeLists.txt file.
```

**Cause:** This error occurs when Flutter's ephemeral build files haven't been generated yet.

**Solution:**
```bash
cd stormforge_modeler
flutter pub get
```

This command will:
- Install all Flutter dependencies
- Generate the `linux/flutter/` directory
- Create the necessary CMake configuration files
- Set up plugin configurations

---

### CMake Error: "Unknown CMake command 'apply_standard_settings'"

**Error Message:**
```
CMake Error at flutter/ephemeral/.plugin_symlinks/flutter_secure_storage_linux/linux/CMakeLists.txt:14 (apply_standard_settings):
  Unknown CMake command "apply_standard_settings".
```

**Cause:** This error previously occurred with the `flutter_secure_storage_linux` plugin. The application now uses `shared_preferences` instead to ensure Linux compatibility.

**If you see this error:** Run `flutter pub get` to regenerate the plugin configuration:
```bash
cd stormforge_modeler
flutter pub get
```

---

### Error: "Unable to generate build files"

**Error Message:**
```
Building Linux application...                                           
Error: Unable to generate build files
```

**Cause:** This is typically caused by missing Flutter setup or incomplete dependency installation.

**Solution:**
1. Ensure Flutter is properly installed:
   ```bash
   flutter doctor
   ```
2. Install dependencies:
   ```bash
   cd stormforge_modeler
   flutter pub get
   ```
3. Try building again:
   ```bash
   flutter run -d linux
   ```

---

## Dependency Issues

### "36 packages have newer versions incompatible with dependency constraints"

**Warning Message:**
```
36 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

**Cause:** Some of your dependencies have newer versions available, but they may not be compatible with the current version constraints in `pubspec.yaml`.

**This is usually not a problem.** The warning is informational and doesn't prevent building or running the application.

**If you want to investigate:**
```bash
flutter pub outdated
```

**To upgrade compatible packages:**
```bash
flutter pub upgrade
```

---

## Setup Script

For a guided setup experience, you can use the provided setup script:

```bash
cd stormforge_modeler
./setup.sh
```

This script will:
- Check if Flutter is installed
- Verify Flutter version
- Run `flutter pub get`
- Verify that all necessary files were generated
- Provide helpful error messages if something goes wrong

---

## Platform-Specific Issues

### Linux

**CMake Version:** Ensure you have CMake 3.10 or higher:
```bash
cmake --version
```

**GTK+ 3.0:** The Linux build requires GTK+ 3.0 development libraries:
```bash
sudo apt-get install libgtk-3-dev  # Ubuntu/Debian
sudo dnf install gtk3-devel        # Fedora
```

**Storage:** The application uses `shared_preferences` for local storage, which is fully compatible with Linux.

### Windows

Make sure you have Visual Studio 2019 or later with the "Desktop development with C++" workload installed.

### macOS

Xcode 12.0 or later is required for building the macOS application.

---

## Getting Help

If you encounter an issue not covered in this guide:

1. Check the GitHub Issues page to see if someone else has reported it
2. Run `flutter doctor` to check your Flutter environment
3. Enable verbose logging: `flutter run -v`
4. Create a new issue with:
   - Full error message
   - Output of `flutter doctor -v`
   - Your operating system and version
   - Steps to reproduce the issue
