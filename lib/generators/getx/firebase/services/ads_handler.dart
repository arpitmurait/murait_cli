import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import 'firebase_service_handler.dart';

/// Handles Firebase Ads setup
class AdsHandler implements FirebaseServiceHandler {
  @override
  String get serviceType => 'ads';

  @override
  Future<void> setup() async {
    await _copyAdFiles();
  }

  @override
  Future<bool> isConfigured() async {
    final adConfig = File('lib/core/utils/ad_config.dart');
    final adsHelper = File('lib/core/utils/ads_helper.dart');
    return await adConfig.exists() && await adsHelper.exists();
  }

  Future<void> _copyAdFiles() async {
    final filesToCopy = ['ad_config.dart', 'ads_helper.dart'];
    
    for (final fileName in filesToCopy) {
      await _copyFile(fileName);
    }
  }

  Future<void> _copyFile(String fileName) async {
    // Find the package root using Isolate.resolvePackageUri (more reliable)
    String? templatePath;
    
    try {
      final packageUri = await Isolate.resolvePackageUri(
        Uri.parse('package:murait_cli/generators/getx/firebase/services/ads_handler.dart')
      );
      if (packageUri != null && packageUri.scheme == 'file') {
        var packagePath = packageUri.toFilePath(windows: Platform.isWindows);
        var servicesDir = p.dirname(packagePath); // firebase/services
        var firebaseDir = p.dirname(servicesDir); // firebase
        var getxDir = p.dirname(firebaseDir); // getx
        var generatorsDir = p.dirname(getxDir); // generators
        var libDir = p.dirname(generatorsDir); // lib
        var rootDir = p.dirname(libDir); // package root
        
        templatePath = p.join(rootDir, 'lib', 'templates', 'core', fileName);
      }
    } catch (e) {
      // Fallback to script path method
    }

    // Fallback: Try using Platform.script if templatePath is null
    templatePath ??= () {
      final scriptUri = Platform.script;
      final scriptPath = scriptUri.toFilePath(windows: Platform.isWindows);
      return p.normalize(
        p.join(
          p.dirname(p.dirname(p.dirname(p.dirname(scriptPath)))),
          'lib',
          'templates',
          'core',
          fileName,
        ),
      );
    }();

    // Check if template exists and try pub cache locations as last resort
    bool templateExists = await File(templatePath).exists();
    if (!templateExists) {
      final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
      if (homeDir.isNotEmpty) {
        final pubCachePath = Platform.isWindows
            ? p.join(homeDir, 'AppData', 'Local', 'Pub', 'Cache')
            : p.join(homeDir, '.pub-cache');
        
        final globalPackagesPath = p.join(pubCachePath, 'global_packages', 'murait_cli');
        if (await Directory(globalPackagesPath).exists()) {
          final testPath = p.join(globalPackagesPath, 'lib', 'templates', 'core', fileName);
          if (await File(testPath).exists()) {
            templatePath = testPath;
            templateExists = true;
          }
        }
        
        if (!templateExists) {
          // Try git cache
          final gitCachePath = p.join(pubCachePath, 'git', 'cache');
          if (await Directory(gitCachePath).exists()) {
            await for (var entity in Directory(gitCachePath).list()) {
              if (entity is Directory) {
                final testPath = p.join(entity.path, 'lib', 'templates', 'core', fileName);
                if (await File(testPath).exists()) {
                  templatePath = testPath;
                  templateExists = true;
                  break;
                }
              }
            }
          }
        }
      }
    }
    
    if (!templateExists || templatePath == null) {
      print('⚠️ Warning: $fileName template not found. Skipping file creation.');
      return;
    }
    
    final templateFile = File(templatePath);
    
    final targetDir = Directory('lib/core/utils');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    
    final targetFile = File('lib/core/utils/$fileName');
    final exists = await targetFile.exists();
    await targetFile.writeAsString(await templateFile.readAsString());
    print('   -> ${exists ? 'Updated' : 'Created'} lib/core/utils/$fileName');
  }
}

