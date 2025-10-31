import 'dart:io';
import '../../../utils.dart';

/// Updates main.dart file for Firebase services
class FirebaseMainFileUpdater {
  final File _mainFile;

  FirebaseMainFileUpdater() : _mainFile = File('lib/main.dart');

  /// Update main.dart with Firebase initialization code
  Future<void> updateMain(List<String> services) async {
    if (!await _mainFile.exists()) {
      print('⚠️ Warning: lib/main.dart not found.');
      return;
    }

    print('✏️  Updating lib/main.dart for Firebase services: ${services.join(', ')}...');

    String content = await _mainFile.readAsString();
    final List<String> mainFunctionCode = [];
    final Set<String> importsToAdd = {};

    // Add WidgetsFlutterBinding
    importsToAdd.add("import 'package:flutter/widgets.dart';");
    mainFunctionCode.add('  WidgetsFlutterBinding.ensureInitialized();');

    // Add Firebase initialization if core is included
    if (services.contains(FirebaseServiceType.core) && !content.contains('Firebase.initializeApp')) {
      importsToAdd.add("import 'package:firebase_core/firebase_core.dart';");
      importsToAdd.add("import 'firebase_options.dart';");
      mainFunctionCode.add('  await Firebase.initializeApp(');
      mainFunctionCode.add('    options: DefaultFirebaseOptions.currentPlatform,');
      mainFunctionCode.add('  );');
      mainFunctionCode.add('');
    }

    // Add service-specific code
    if (services.contains(FirebaseServiceType.crashlytics) && 
        !content.contains('FirebaseCrashlytics.instance')) {
      importsToAdd.add("import 'package:firebase_crashlytics/firebase_crashlytics.dart';");
      importsToAdd.add("import 'package:flutter/foundation.dart';");
      mainFunctionCode.add('  // Pass all uncaught errors to Crashlytics.');
      mainFunctionCode.add('  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;');
      mainFunctionCode.add('  PlatformDispatcher.instance.onError = (error, stack) {');
      mainFunctionCode.add('    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);');
      mainFunctionCode.add('    return true;');
      mainFunctionCode.add('  };');
      mainFunctionCode.add('');
    }

    if (services.contains(FirebaseServiceType.messaging) && 
        !content.contains('_firebaseMessagingBackgroundHandler')) {
      importsToAdd.add("import 'package:firebase_messaging/firebase_messaging.dart';");
      importsToAdd.add("import 'core/utils/notification_service.dart';");
      mainFunctionCode.add('  await NotificationService().initialize();');
      mainFunctionCode.add('');
    }

    if (services.contains(FirebaseServiceType.ads) && !content.contains('AdConfig.init()')) {
      importsToAdd.add("import 'package:flutter_native_ad/flutter_native_ad.dart';");
      importsToAdd.add("import 'core/utils/ad_config.dart';");
      mainFunctionCode.add('  await AdConfig.init();');
      mainFunctionCode.add('  try{');
      mainFunctionCode.add('    await FlutterNativeAd.init();');
      mainFunctionCode.add('  } catch (e) {}');
      mainFunctionCode.add('');
    }

    // Remove duplicate ensureInitialized
    content = content.replaceAll(RegExp(r'\s*WidgetsFlutterBinding.ensureInitialized\(\);'), '');

    // Inject imports
    String combinedHeaderCode = importsToAdd
        .where((imp) => !content.contains(imp))
        .join('\n');

    if (combinedHeaderCode.isNotEmpty) {
      final lastImportIndex = content.lastIndexOf(RegExp(r"import\s*'.+';"));
      if (lastImportIndex != -1) {
        final endOfLineIndex = content.indexOf('\n', lastImportIndex);
        content = content.substring(0, endOfLineIndex + 1) +
            '\n' + combinedHeaderCode +
            content.substring(endOfLineIndex + 1);
      } else {
        content = '$combinedHeaderCode\n$content';
      }
    }

    // Inject main function code
    final mainRegex = RegExp(r'void\s+main\s*\(\s*\)\s*(async\s*)?({)');
    if (mainRegex.hasMatch(content)) {
      content = content.replaceFirstMapped(mainRegex, (match) {
        final openingBrace = match.group(2)!;
        final allMainCode = mainFunctionCode.join('\n');
        final newSignature = 'void main() async $openingBrace';
        return '$newSignature\n$allMainCode';
      });
    }

    await _mainFile.writeAsString(content);
    print('✅ lib/main.dart updated successfully.');
  }
}

