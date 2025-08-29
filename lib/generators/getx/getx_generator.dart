import 'dart:io';
import '../utils.dart';
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

    String content = file.readAsStringSync();
    if (content.contains("static const $name = '/$name';")) {
      print('⚠️ Route for $name already exists in app_routes.dart.');
      return;
    }
    final newRoute = "  static const $name = '/$name';\n}";
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

    String content = file.readAsStringSync();

    // Add import if not already present
    final newImport = "import '../screens/${name}/${name}_screen.dart';\n";
    if (!content.contains(newImport)) {
      content = content.replaceFirst(RegExp(r"part 'app_routes.dart';"), "part 'app_routes.dart';\n$newImport");
    }

    // Add GetPage if not already present
    if (content.contains("name: AppRoutes.$name,")) {
      print('⚠️ GetPage for $name already exists in app_pages.dart.');
      return;
    }
    final newPage = '''
    GetPage(
      name: AppRoutes.$name,
      page: () => ${capitalize(name)}Screen(),
    ),
  ];
''';
    content = content.replaceAll(RegExp(r'\];\s*$'), newPage);

    file.writeAsStringSync(content);
    print('✅ Updated lib/routes/app_pages.dart');
  }
}
