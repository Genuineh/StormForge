# Linux Platform Files

This directory contains the Linux-specific build configuration for the StormForge Modeler Flutter application.

## Important Note

The main CMakeLists.txt file includes a fix for a build error that occurs with newer Clang compilers when using the `flutter_secure_storage_linux` plugin. The plugin includes an older version of `json.hpp` that uses deprecated literal operator syntax.

### The Fix

Lines 25-28 in `CMakeLists.txt` add compiler flags to suppress the deprecated literal operator warnings:

```cmake
# Add compiler flags to suppress deprecated literal operator warnings from third-party libraries
# This addresses the issue with flutter_secure_storage_linux's json.hpp
add_compile_options(-Wno-error=deprecated-literal-operator)
add_compile_options(-Wno-deprecated-literal-operator)
```

This prevents the build from failing with errors like:
```
error: identifier '_json' preceded by whitespace in a literal operator declaration is deprecated [-Werror,-Wdeprecated-literal-operator]
```

## Regenerating These Files

If you need to regenerate the Linux platform files (e.g., after a Flutter upgrade), you can run:

```bash
cd stormforge_modeler
flutter create --platforms=linux .
```

**Important:** After regenerating, you must add back the compiler flags mentioned above to the main CMakeLists.txt file, or the build will fail with the deprecated literal operator error.

## Files in This Directory

- `CMakeLists.txt` - Main build configuration with the compiler flag fix
- `main.cc` - Application entry point
- `my_application.h` / `my_application.cc` - Application implementation
- `flutter/` - Flutter-managed build files (ignored by git)
- `.gitattributes` - Marks this directory as auto-generated
