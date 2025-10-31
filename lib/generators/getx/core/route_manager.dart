import '../../utils.dart' show toPascalCase, toCamelCase, toKebabCase;
import 'file_manager.dart';

/// Manages route file updates for GetX
class GetXRouteManager {
  final GetXFileManager _fileManager;
  
  GetXRouteManager(this._fileManager);

  /// Update app_routes.dart with new route
  Future<void> updateAppRoutes(String name) async {
    final routesPath = 'lib/routes/app_routes.dart';
    
    if (!await _fileManager.fileExists(routesPath)) {
      print('❌ Error: lib/routes/app_routes.dart not found.');
      return;
    }

    final camelCaseName = toCamelCase(name);
    final kebabCasePath = toKebabCase(name);
    
    String content = await _fileManager.readFile(routesPath);
    
    // Check if route already exists
    if (content.contains("static const $camelCaseName =") || 
        content.contains("static const $name =")) {
      print('⚠️ Route for $name already exists in app_routes.dart.');
      return;
    }
    
    // Add the new route string just before the closing brace of the class
    final newRoute = "  static const $camelCaseName = '/$kebabCasePath';\n}";
    content = content.replaceAll(RegExp(r'}\s*$'), newRoute);

    await _fileManager.writeFile(routesPath, content);
    print('✅ Updated lib/routes/app_routes.dart');
  }

  /// Update app_pages.dart with new route page
  Future<void> updateAppPages(String name) async {
    final pagesPath = 'lib/routes/app_pages.dart';
    
    if (!await _fileManager.fileExists(pagesPath)) {
      print('❌ Error: lib/routes/app_pages.dart not found.');
      return;
    }

    List<String> lines = (await _fileManager.readFile(pagesPath)).split('\n');

    // 1. Handle Import Statement
    final camelCaseName = toCamelCase(name);
    final newImport = "import '../screens/$name/${name}_screen.dart';";
    bool importExists = lines.any((line) => line.trim() == newImport);

    if (!importExists) {
      int partIndex = lines.indexWhere((line) => line.contains("part 'app_routes.dart';"));
      if (partIndex != -1) {
        lines.insert(partIndex, newImport);
      } else {
        int lastImportIndex = lines.lastIndexWhere((line) => line.trim().startsWith("import '"));
        if (lastImportIndex != -1) {
          lines.insert(lastImportIndex + 1, newImport);
        } else {
          lines.insert(0, newImport);
        }
      }
    } else {
      print('⚠️ Import for $name already exists in app_pages.dart.');
    }

    // 2. Handle GetPage Entry
    final newPageEntry = '''
    GetPage(
      name: AppRoutes.$camelCaseName,
      page: () => ${toPascalCase(name)}Screen(),
    ),''';
    
    bool pageExists = lines.any((line) => 
        line.contains("name: AppRoutes.$camelCaseName,") || 
        line.contains("name: AppRoutes.$name,"));

    if (!pageExists) {
      int routesListEndIndex = lines.lastIndexWhere((line) => line.trim() == '];');
      if (routesListEndIndex != -1) {
        lines.insert(routesListEndIndex, newPageEntry);
      } else {
        print('❌ Error: Could not find the closing `];` of the routes list in app_pages.dart.');
        return;
      }
    } else {
      print('⚠️ GetPage for $name already exists in app_pages.dart.');
    }

    // 3. Write Updated Content Back to File
    await _fileManager.writeFile(pagesPath, lines.join('\n'));
    print('✅ Updated lib/routes/app_pages.dart successfully.');
  }

  /// Update both route files
  Future<void> updateRoutes(String name) async {
    await updateAppRoutes(name);
    await updateAppPages(name);
  }
}

