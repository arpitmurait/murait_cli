import '../core/file_manager.dart';
import '../core/path_config.dart';
import '../templates/template_manager.dart';

/// Interface for feature components
abstract class FeatureComponent {
  /// Component name/type
  String get name;

  /// Generate this component for a feature
  Future<void> generate(
    String featureName,
    GetXFileManager fileManager,
    GetXTemplateProvider templateProvider, {
    Map<String, dynamic>? options,
  });
}

/// Screen component generator
class ScreenComponent implements FeatureComponent {
  @override
  String get name => 'screen';

  @override
  Future<void> generate(
    String featureName,
    GetXFileManager fileManager,
    GetXTemplateProvider templateProvider, {
    Map<String, dynamic>? options,
  }) async {
    // Create screen directory
    await fileManager.createDirectory(GetXPathConfig.getScreenPath(featureName));
    
    // Create widgets directory
    await fileManager.createDirectory(GetXPathConfig.getWidgetsPath(featureName));
    
    // Create controller file
    final withRepo = options?['withRepo'] as bool? ?? false;
    await fileManager.createFile(
      path: GetXPathConfig.getControllerPath(featureName),
      content: templateProvider.controllerTemplate(featureName, withRepo: withRepo),
    );
    
    // Create screen file
    await fileManager.createFile(
      path: GetXPathConfig.getScreenFilePath(featureName),
      content: templateProvider.viewTemplate(featureName),
    );
  }
}

/// Model component generator
class ModelComponent implements FeatureComponent {
  @override
  String get name => 'model';

  @override
  Future<void> generate(
    String featureName,
    GetXFileManager fileManager,
    GetXTemplateProvider templateProvider, {
    Map<String, dynamic>? options,
  }) async {
    await fileManager.createFile(
      path: GetXPathConfig.getModelPath(featureName),
      content: templateProvider.modelTemplate(featureName),
    );
  }
}

/// Repository component generator
class RepositoryComponent implements FeatureComponent {
  @override
  String get name => 'repository';

  @override
  Future<void> generate(
    String featureName,
    GetXFileManager fileManager,
    GetXTemplateProvider templateProvider, {
    Map<String, dynamic>? options,
  }) async {
    await fileManager.createFile(
      path: GetXPathConfig.getRepositoryPath(featureName),
      content: templateProvider.repoTemplate(featureName),
    );
  }
}

