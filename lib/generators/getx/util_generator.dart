import 'dart:io';

class UtilGenerator {
  Future<void> addShareFeature() async {
    print('🚀 Adding App Share feature...');

    // 1. Add share_plus dependency
    await _addShareDependency();

    // 2. Modify utils.dart
    await _updateUtilsFile();

    print('\n✅ App Share feature added successfully!');
    print('   -> You can now call `Utils.shareApp()` anywhere in your code.');
  }

  Future<void> _addShareDependency() async {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('❌ Error: pubspec.yaml not found. Make sure you are in the root of a Flutter project.');
      return;
    }

    print('   -> Adding `share_plus` dependency...');

    List<String> lines = pubspecFile.readAsLinesSync();
    int dependenciesIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
    if (dependenciesIndex == -1) {
      print('❌ Error: Could not find "dependencies:" section in pubspec.yaml.');
      return;
    }
    String dep = 'share_plus: ^11.1.0';
    final packageName = dep.trim().split(':').first;
    if (!lines.any((line) => line.trim().startsWith(packageName))) {
      lines.insert(dependenciesIndex + 1, '  $dep');
      pubspecFile.writeAsStringSync(lines.join('\n'));
      print('✅ Added $dep new dependencies.');
    }
  }

  Future<void> _updateUtilsFile() async {
    final utilsFile = File('lib/core/utils/utils.dart');
    if (!await utilsFile.exists()) {
      print('⚠️ Warning: lib/core/utils/utils.dart not found. Could not add shareApp method.');
      return;
    }
    print('   -> Modifying lib/core/utils/utils.dart...');

    var lines = await utilsFile.readAsLines();
    bool contentModified = false;

    // --- 1. Add Import ---
    const shareImport = "import 'package:share_plus/share_plus.dart';";
    if (!lines.any((line) => line.contains(shareImport))) {
      // Find the last import and add it after
      int lastImportIndex = lines.lastIndexWhere((line) => line.trim().startsWith('import '));
      if (lastImportIndex != -1) {
        lines.insert(lastImportIndex + 1, shareImport);
      } else {
        lines.insert(0, shareImport); // Fallback if no imports exist
      }
      contentModified = true;
    }

    // --- 2. Add shareApp method into the Utils class ---
    final classStartIndex = lines.indexWhere((line) => line.trim().startsWith('class Utils {'));
    if (classStartIndex != -1) {
      final classEndIndex = lines.indexWhere((line) => line == '}', classStartIndex);
      if (classEndIndex != -1 && !lines.any((line) => line.contains('static void shareApp()'))) {
        // NOTE: The `Share.share` method is used as per the latest `share_plus` package.
        // The text is taken from your example.
        final shareMethod = '''

  static void shareApp(){
     SharePlus.instance.share(ShareParams(text: "Demo app  Download now: Android: https://play.google.com/store/apps/details?id=com.example.app  iOS: https://apps.apple.com/us/app/id6751324205"));
  }
''';
        lines.insert(classEndIndex, shareMethod);
        contentModified = true;
      }
    }

    if (contentModified) {
      await utilsFile.writeAsString(lines.join('\n'));
      print('   -> Successfully added shareApp() method to Utils class.');
    } else {
      print('   -> Utils class already seems to have the shareApp method or the required import.');
    }
  }
}
