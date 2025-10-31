import 'core/file_manager.dart';
import 'core/route_manager.dart';
import 'core/component_registry.dart';
import 'core/path_config.dart';
import 'templates/template_manager.dart';
import 'components/feature_component.dart';

/// Main GetX code generator
/// 
/// This generator creates GetX-based features including screens, controllers,
/// models, and repositories with a modular, extensible architecture.
class GetXGenerator {
  final GetXFileManager _fileManager;
  final GetXRouteManager _routeManager;
  final GetXTemplateProvider _templateProvider;
  final ComponentRegistry _componentRegistry;

  /// Create a new GetXGenerator with optional custom dependencies
  GetXGenerator({
    GetXFileManager? fileManager,
    GetXRouteManager? routeManager,
    GetXTemplateProvider? templateProvider,
    ComponentRegistry? componentRegistry,
  })  : _fileManager = fileManager ?? GetXFileManager(),
        _routeManager = routeManager ?? GetXRouteManager(fileManager ?? GetXFileManager()),
        _templateProvider = templateProvider ?? DefaultGetXTemplateProvider(),
        _componentRegistry = componentRegistry ?? ComponentRegistry() {
    // Initialize default components if registry is new
    if (componentRegistry == null) {
      _componentRegistry.initializeDefaults();
    }
  }

  /// Create a complete feature (screen + controller + optional model/repository)
  Future<void> createFeature(
    String name, {
    bool withRepo = false,
    bool withModel = false,
  }) async {
    // Validate feature name
    _validateFeatureName(name);

    // Generate screen component
    final screenComponent = _componentRegistry.get('screen');
    if (screenComponent != null) {
      await screenComponent.generate(
        name,
        _fileManager,
        _templateProvider,
        options: {'withRepo': withRepo},
      );
    }

    // Generate model if requested
    if (withModel || withRepo) {
      await createModel(name);
    }

    // Generate repository if requested
    if (withRepo) {
      await createRepository(name);
    }

    // Update route files
    await _routeManager.updateRoutes(name);
  }

  /// Create a model file
  Future<void> createModel(String name) async {
    _validateFeatureName(name);

    final modelComponent = _componentRegistry.get('model');
    if (modelComponent != null) {
      await modelComponent.generate(name, _fileManager, _templateProvider);
      print('✅ Created model: ${GetXPathConfig.getModelPath(name)}');
    } else {
      throw StateError('Model component not registered');
    }
  }

  /// Create a repository file
  Future<void> createRepository(String name) async {
    _validateFeatureName(name);

    final repoComponent = _componentRegistry.get('repository');
    if (repoComponent != null) {
      await repoComponent.generate(name, _fileManager, _templateProvider);
      print('✅ Created repository: ${GetXPathConfig.getRepositoryPath(name)}');
    } else {
      throw StateError('Repository component not registered');
    }
  }

  /// Validate feature name format
  void _validateFeatureName(String name) {
    if (name.isEmpty) {
      throw ArgumentError('Feature name cannot be empty');
    }
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      throw ArgumentError(
        'Feature name must start with lowercase letter and contain only lowercase letters, numbers, and underscores. Got: "$name"',
      );
    }
  }

  /// Register a custom component
  void registerComponent(FeatureComponent component) {
    _componentRegistry.register(component);
  }

  /// Get a component by name
  FeatureComponent? getComponent(String name) {
    return _componentRegistry.get(name);
  }
}
