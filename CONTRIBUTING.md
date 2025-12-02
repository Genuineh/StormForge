# Contributing to StormForge

First off, thank you for considering contributing to StormForge! It's people like you that make StormForge such a great tool.

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## 🤔 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Bug Report Template:**

```markdown
## Bug Description
A clear and concise description of what the bug is.

## Steps To Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- OS: [e.g., Windows 11, macOS Ventura, Ubuntu 22.04]
- Flutter Version: [e.g., 3.24.0]
- Rust Version: [e.g., 1.75.0]
- StormForge Version: [e.g., 0.1.0]

## Additional Context
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK 3.24+
- Rust 1.75+
- Git
- Visual Studio Code (recommended) or your preferred IDE

### Setting Up Your Development Environment

1. **Clone the repository**
   ```bash
   git clone https://github.com/Genuineh/StormForge.git
   cd StormForge
   ```

2. **Flutter Modeler Setup**
   ```bash
   cd stormforge_modeler
   flutter pub get
   flutter run -d chrome  # or your preferred device
   ```

3. **Rust Generator Setup**
   ```bash
   cd stormforge_generator
   cargo build
   cargo test
   ```

4. **Dart Generator Setup**
   ```bash
   cd stormforge_dart_generator
   dart pub get
   dart test
   ```

### Running Tests

```bash
# Flutter tests
cd stormforge_modeler
flutter test

# Rust tests
cd stormforge_generator
cargo test

# Dart tests
cd stormforge_dart_generator
dart test
```

## 📝 Style Guides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

**Commit Message Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests
- `chore`: Changes to the build process or auxiliary tools

**Example:**
```
feat(canvas): add zoom and pan functionality

Implement zoom with mouse wheel and pan with middle mouse button.
Canvas now supports up to 1000 elements with smooth performance.

Closes #123
```

### Flutter/Dart Style Guide

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Run `flutter analyze` and fix all issues
- Prefer `const` constructors when possible
- Document public APIs with DartDoc comments

```dart
/// Creates a new domain event element on the canvas.
/// 
/// The [position] parameter specifies the initial location.
/// The [name] parameter specifies the event name.
/// 
/// Example:
/// ```dart
/// final event = DomainEvent(
///   position: Offset(100, 200),
///   name: 'OrderCreated',
/// );
/// ```
class DomainEvent extends CanvasElement {
  // ...
}
```

### Rust Style Guide

- Follow the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Use `cargo fmt` before committing
- Run `cargo clippy` and address all warnings
- Document public APIs with doc comments

```rust
/// Generates a Rust microservice from the given IR model.
///
/// # Arguments
///
/// * `ir_model` - The intermediate representation of the domain model
/// * `output_path` - The path where the generated code will be written
///
/// # Returns
///
/// * `Result<(), GeneratorError>` - Ok on success, Err on failure
///
/// # Example
///
/// ```rust
/// let generator = RustGenerator::new();
/// generator.generate(&model, &output_path)?;
/// ```
pub fn generate(&self, ir_model: &IrModel, output_path: &Path) -> Result<(), GeneratorError> {
    // ...
}
```

## 📁 Project Structure

When adding new features, please follow the existing project structure:

- `stormforge_modeler/` - Flutter modeling application
- `stormforge_generator/` - Rust code generator
- `stormforge_dart_generator/` - Dart package generator
- `ir_schema/` - IR schema definitions
- `docs/` - Documentation
- `examples/` - Example projects

## 🧪 Testing Guidelines

### Unit Tests

- Test individual functions and methods
- Mock external dependencies
- Aim for > 80% code coverage

### Integration Tests

- Test interaction between components
- Use real dependencies where practical
- Test full workflows

### End-to-End Tests

- Test complete user scenarios
- Include both success and failure paths

## 📋 Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the documentation for any new features
3. Add tests for any new functionality
4. The PR will be merged once you have the sign-off of at least one maintainer

## 🏷️ Issue Labels

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working |
| `enhancement` | New feature or request |
| `documentation` | Improvements or additions to documentation |
| `good first issue` | Good for newcomers |
| `help wanted` | Extra attention is needed |
| `priority: high` | High priority issue |
| `priority: low` | Low priority issue |

## 📞 Getting Help

- Check the [documentation](docs/)
- Search existing [issues](https://github.com/Genuineh/StormForge/issues)
- Create a new issue with the `question` label

## 🙏 Recognition

Contributors will be recognized in the following ways:
- Listed in the CONTRIBUTORS.md file
- Mentioned in release notes for significant contributions
- Given collaborator access for sustained contributions

---

Thank you for contributing to StormForge! 🚀
