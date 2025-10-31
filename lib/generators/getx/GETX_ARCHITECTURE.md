# GetX Generator Architecture

## Overview

The GetX generator has been refactored into a **modular, component-based architecture** that makes it easy to extend and add new features.

## Directory Structure

```
lib/generators/getx/
├── core/                    # Core infrastructure
│   ├── file_manager.dart   # File operations
│   ├── route_manager.dart  # Route file management
│   ├── path_config.dart    # Path configuration
│   ├── component_registry.dart  # Component registry
│   └── getx_core.dart      # Core exports
│
├── components/              # Feature components
│   └── feature_component.dart  # Component interfaces & implementations
│
├── templates/               # Template system
│   └── template_manager.dart   # Template providers
│
├── getx_generator.dart      # Main generator (orchestrator)
├── templates.dart           # Legacy templates (for project creation)
├── project_creator.dart     # Project creation logic
├── project_command.dart     # CLI commands
├── firebase_generator.dart  # Firebase integration
├── firebase_commands.dart   # Firebase commands
└── firebase_templates.dart  # Firebase templates
```

## Architecture Components

### 1. Core Infrastructure (`core/`)

#### FileManager (`file_manager.dart`)
- Handles all file I/O operations
- Creates files and directories
- Checks file/directory existence
- Provides clean abstraction for file operations

#### RouteManager (`route_manager.dart`)
- Manages route file updates
- Updates `app_routes.dart` and `app_pages.dart`
- Handles route naming conventions
- Prevents duplicate routes

#### PathConfig (`path_config.dart`)
- Centralized path configuration
- Easy to modify project structure
- Provides path helpers for all file types

#### ComponentRegistry (`component_registry.dart`)
- Registry pattern for components
- Allows dynamic component registration
- Easy to add new component types

### 2. Component System (`components/`)

Components are pluggable generators for different parts of a feature:

- **ScreenComponent**: Generates screen + controller + widgets folder
- **ModelComponent**: Generates model files
- **RepositoryComponent**: Generates repository files

#### Adding a New Component

```dart
class BindingComponent implements FeatureComponent {
  @override
  String get name => 'binding';

  @override
  Future<void> generate(
    String featureName,
    GetXFileManager fileManager,
    GetXTemplateProvider templateProvider, {
    Map<String, dynamic>? options,
  }) async {
    // Generate binding file
  }
}

// Register it
generator.registerComponent(BindingComponent());
```

### 3. Template System (`templates/`)

#### TemplateProvider Interface
- Abstraction for template generation
- Easy to swap template implementations
- Supports custom template providers

#### DefaultGetXTemplateProvider
- Default implementation
- Can be extended or replaced

#### Creating Custom Templates

```dart
class CustomTemplateProvider implements GetXTemplateProvider {
  @override
  String controllerTemplate(String name, {bool withRepo = false}) {
    // Custom controller template
  }
  
  // ... implement other methods
}

// Use it
final generator = GetXGenerator(
  templateProvider: CustomTemplateProvider(),
);
```

### 4. Main Generator (`getx_generator.dart`)

The main orchestrator that:
- Coordinates components
- Manages dependencies
- Provides public API
- Validates inputs

## Usage Examples

### Basic Usage (Default)

```dart
final generator = GetXGenerator();
await generator.createFeature('profile', withRepo: true);
```

### Custom Configuration

```dart
final generator = GetXGenerator(
  fileManager: CustomFileManager(),
  templateProvider: CustomTemplateProvider(),
);
```

### Adding Custom Components

```dart
final generator = GetXGenerator();
generator.registerComponent(MyCustomComponent());
await generator.createFeature('profile');
```

## Benefits

### ✅ Modularity
- Each component has a single responsibility
- Easy to test individual components
- Clear separation of concerns

### ✅ Extensibility
- Add new components without modifying existing code
- Swap implementations easily
- Plugin-ready architecture

### ✅ Maintainability
- Well-organized structure
- Clear dependencies
- Easy to understand and modify

### ✅ Testability
- Components can be mocked
- Dependencies are injectable
- Isolated unit tests possible

## Future Enhancements

### Easy to Add:
- **Widget Components**: Generate custom widgets
- **Binding Components**: Generate GetX bindings
- **Service Components**: Generate service classes
- **Provider Components**: Generate different state management
- **Test Components**: Generate test files
- **Localization Components**: Generate localization files

### Configuration Options:
- Custom paths per project
- Template customization
- Component selection per feature
- Code style preferences

## Migration Notes

✅ **Backward Compatible**: All existing functionality works the same.

The refactoring is **internal only** - the public API remains unchanged:
- `createFeature()` - Same signature
- `createModel()` - Same signature
- `createRepository()` - Same signature

Existing code continues to work without changes!

