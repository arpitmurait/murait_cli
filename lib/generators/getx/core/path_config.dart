/// Configuration for GetX generator paths
class GetXPathConfig {
  /// Base paths
  static const String screensPath = 'lib/screens';
  static const String modelsPath = 'lib/data/model';
  static const String repositoriesPath = 'lib/data/repository';
  static const String routesPath = 'lib/routes';
  static const String widgetsPath = 'widgets';

  /// Get screen directory path
  static String getScreenPath(String name) => '$screensPath/$name';

  /// Get widgets directory path for a screen
  static String getWidgetsPath(String screenName) => 
      '${getScreenPath(screenName)}/$widgetsPath';

  /// Get controller file path
  static String getControllerPath(String name) => 
      '${getScreenPath(name)}/${name}_controller.dart';

  /// Get screen file path
  static String getScreenFilePath(String name) => 
      '${getScreenPath(name)}/${name}_screen.dart';

  /// Get model file path
  static String getModelPath(String name) => 
      '$modelsPath/${name}_model.dart';

  /// Get repository file path
  static String getRepositoryPath(String name) => 
      '$repositoriesPath/${name}_repository.dart';

  /// Get routes file paths
  static String getAppRoutesPath() => '$routesPath/app_routes.dart';
  static String getAppPagesPath() => '$routesPath/app_pages.dart';
}

