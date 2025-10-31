import 'dart:io';
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
    final scriptUri = Platform.script;
    final scriptPath = scriptUri.toFilePath(windows: Platform.isWindows);
    final templatesBasePath = p.normalize(
      p.join(
        p.dirname(p.dirname(p.dirname(p.dirname(scriptPath)))),
        'lib',
        'templates',
        'core',
      ),
    );

    final filesToCopy = ['ad_config.dart', 'ads_helper.dart'];
    
    for (final fileName in filesToCopy) {
      final templatePath = p.join(templatesBasePath, fileName);
      final templateFile = File(templatePath);
      
      if (!await templateFile.exists()) {
        print('⚠️ Warning: $fileName template not found.');
        continue;
      }

      final targetDir = Directory('lib/core/utils');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      
      final targetFile = File('lib/core/utils/$fileName');
      if (!await targetFile.exists()) {
        await targetFile.writeAsString(await templateFile.readAsString());
        print('   -> Created lib/core/utils/$fileName');
      }
    }
  }
}

