import 'dart:io';
import 'package:murait_cli/generators/utils.dart' show toPascalCase, toCamelCase, toKebabCase;

import 'templates.dart';

class GetXGenerator {
  void createFeature(String name, {bool withRepo = false,bool withModel = false}) {
    // Create screen directory and widgets sub-directory
    final screenFolder = Directory('lib/screens/$name');
    if (!screenFolder.existsSync()) {
      screenFolder.createSync(recursive: true);
      print('✅ Created directory: ${screenFolder.path}');
    }
    final widgetsFolder = Directory('lib/screens/$name/widgets');
    if (!widgetsFolder.existsSync()) {
      widgetsFolder.createSync(recursive: true);
      print('✅ Created directory: ${widgetsFolder.path}');
    }

    // Create Screen and Controller files
    _createFile(
        path: '${screenFolder.path}/${name}_controller.dart',
        content: Templates.controllerTemplate(name, withRepo: withRepo));
    _createFile(
        path: '${screenFolder.path}/${name}_screen.dart',
        content: Templates.viewTemplate(name));

    // Conditionally create Model and Repository
    if (withRepo) {
      createModel(name);
      createRepository(name);
    }

    // Update route files
    _updateAppRoutes(name);
    _updateAppPages(name);
  }

  void createModel(String name) {
    _createFile(
        path: 'lib/data/model/${name}_model.dart',
        content: Templates.modelTemplate(name));
  }

  void createRepository(String name) {
    _createFile(
        path: 'lib/data/repository/${name}_repository.dart',
        content: Templates.repoTemplate(name));
  }

  void _createFile({required String path, required String content}) {
    final file = File(path);
    if (file.existsSync()) {
      print('⚠️ File already exists: $path');
      return;
    }
    file..createSync(recursive: true)..writeAsStringSync(content);
    print('✅ Created file: $path');
  }

  void _updateAppRoutes(String name) {
    final file = File('lib/routes/app_routes.dart');
    if (!file.existsSync()) {
      print('❌ Error: lib/routes/app_routes.dart not found.');
      return;
    }

    final camelCaseName = toCamelCase(name);
    final kebabCasePath = toKebabCase(name);
    
    String content = file.readAsStringSync();
    if (content.contains("static const $camelCaseName =") || 
        content.contains("static const $name =")) {
      print('⚠️ Route for $name already exists in app_routes.dart.');
      return;
    }
    // Add the new route string just before the closing brace of the class.
    final newRoute = "  static const $camelCaseName = '/$kebabCasePath';\n}";
    content = content.replaceAll(RegExp(r'}\s*$'), newRoute);

    file.writeAsStringSync(content);
    print('✅ Updated lib/routes/app_routes.dart');
  }

  void _updateAppPages(String name) {
    final file = File('lib/routes/app_pages.dart');
    if (!file.existsSync()) {
      print('❌ Error: lib/routes/app_pages.dart not found.');
      return;
    }

    List<String> lines = file.readAsLinesSync();

    // --- 1. Handle Import Statement ---
    final newImport = "import '../screens/$name/${name}_screen.dart';";
    bool importExists = lines.any((line) => line.trim() == newImport);

    if (!importExists) {
      int partIndex = lines.indexWhere((line) => line.contains("part 'app_routes.dart';"));
      if (partIndex != -1) {
        // Insert the import right before the 'part' directive.
        lines.insert(partIndex, newImport);
      } else {
        // Fallback: find the last import and insert after it.
        int lastImportIndex = lines.lastIndexWhere((line) => line.trim().startsWith("import '"));
        if (lastImportIndex != -1) {
          lines.insert(lastImportIndex + 1, newImport);
        } else {
          // Absolute fallback: insert at the top.
          lines.insert(0, newImport);
        }
      }
    } else {
      print('⚠️ Import for $name already exists in app_pages.dart.');
    }

    // --- 2. Handle GetPage Entry ---
    final camelCaseName = toCamelCase(name);
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
        // Insert the new GetPage block before the closing bracket of the list.
        lines.insert(routesListEndIndex, newPageEntry);
      } else {
        print('❌ Error: Could not find the closing `];` of the routes list in app_pages.dart.');
        return; // Stop if we can't find the insertion point
      }
    } else {
      print('⚠️ GetPage for $name already exists in app_pages.dart.');
    }

    // --- 3. Write Updated Content Back to File ---
    file.writeAsStringSync(lines.join('\n'));
    print('✅ Updated lib/routes/app_pages.dart successfully.');
  }
}
