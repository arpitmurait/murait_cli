import '../components/feature_component.dart' show FeatureComponent, ScreenComponent, ModelComponent, RepositoryComponent;

/// Registry for feature components
class ComponentRegistry {
  static final ComponentRegistry _instance = ComponentRegistry._internal();
  factory ComponentRegistry() => _instance;
  ComponentRegistry._internal();

  final Map<String, FeatureComponent> _components = {};

  /// Register a component
  void register(FeatureComponent component) {
    _components[component.name] = component;
  }

  /// Get a component by name
  FeatureComponent? get(String name) {
    return _components[name];
  }

  /// Get all registered components
  List<FeatureComponent> getAll() {
    return _components.values.toList();
  }

  /// Check if a component is registered
  bool has(String name) {
    return _components.containsKey(name);
  }

  /// Initialize default components
  void initializeDefaults() {
    register(ScreenComponent());
    register(ModelComponent());
    register(RepositoryComponent());
  }
}

