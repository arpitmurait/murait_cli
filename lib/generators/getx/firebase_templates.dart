import 'dart:io';

import '../utils.dart';

class FirebaseTemplates {

  static void updateMain(List<String> services) {
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('⚠️ Warning: lib/main.dart not found.');
      return;
    }

    print('✏️  Updating lib/main.dart for Firebase services: ${services.join(', ')}...');

    String content = mainFile.readAsStringSync();

    // --- 1. Intelligently Prepare Code Blocks ---

    final List<String> mainFunctionCode = [];
    final Set<String> importsToAdd = {};
    final List<String> topLevelCode = [];

    // This must be the first line in an async main, so we add it unconditionally
    // to our injection block. We will remove any other instances later.
    importsToAdd.add("import 'package:flutter/widgets.dart';");
    mainFunctionCode.add('  WidgetsFlutterBinding.ensureInitialized();');


    // Add initializeApp() if it's missing.
    if (!content.contains('Firebase.initializeApp')) {
      importsToAdd.add("import 'package:firebase_core/firebase_core.dart';");
      importsToAdd.add("import 'firebase_options.dart';");
      mainFunctionCode.add('  await Firebase.initializeApp(');
      mainFunctionCode.add('    options: DefaultFirebaseOptions.currentPlatform,');
      mainFunctionCode.add('  );');
    }

    if (mainFunctionCode.length > 1) { // More than just ensureInitialized was added
      mainFunctionCode.add(''); // Add a newline for readability
    }


    // Add service-specific code if it's missing.
    if (services.contains(FirebaseServiceType.analytics)) {
      importsToAdd.add("import 'package:firebase_analytics/firebase_analytics.dart';");
      if (!content.contains('final FirebaseAnalytics firebaseAnalytics')) {
        topLevelCode.add('final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;');
      }
    }

    // --- 4. NEW: Inject Navigator Observer for Analytics ---
    if (services.contains(FirebaseServiceType.analytics) && !content.contains('FirebaseAnalyticsObserver')) {
      // This regex finds MaterialApp( or GetMaterialApp(
      final appWidgetRegex = RegExp(r'(MaterialApp|GetMaterialApp)\s*\(');
      if (content.contains(appWidgetRegex)) {
        print('✏️  Injecting FirebaseAnalyticsObserver into MaterialApp...');
        content = content.replaceFirstMapped(appWidgetRegex, (match) {
          final originalMatch = match.group(0)!; // This is "MaterialApp(" or "GetMaterialApp("
          const observerCode = '''
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
        ''';
          // Add the observer right after the opening parenthesis
          return '$originalMatch\n$observerCode';
        });
      } else {
        print('⚠️ Warning: Could not find MaterialApp or GetMaterialApp to inject FirebaseAnalyticsObserver.');
      }
    }
    if (services.contains(FirebaseServiceType.crashlytics) && !content.contains('FirebaseCrashlytics.instance')) {
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

    if (services.contains(FirebaseServiceType.messaging) && !content.contains('_firebaseMessagingBackgroundHandler')) {
      importsToAdd.add("import 'package:firebase_messaging/firebase_messaging.dart';");
      topLevelCode.add('');
      topLevelCode.add("@pragma('vm:entry-point')");
      topLevelCode.add('Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {');
      topLevelCode.add('  await Firebase.initializeApp();');
      topLevelCode.add('  print("Handling a background message: \${message.messageId}");');
      topLevelCode.add('}');
      mainFunctionCode.add('  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);');
      mainFunctionCode.add('');
    }

    // --- 2. Inject and Clean ---

    // FINAL FIX: Remove any old instance of ensureInitialized() to prevent duplicates.
    // We use a regex to catch different spacings and the semicolon.
    content = content.replaceAll(RegExp(r'\s*WidgetsFlutterBinding.ensureInitialized\(\);'), '');

    // Inject Headers (Imports and Top-Level Code)
    String combinedHeaderCode = importsToAdd.where((imp) => !content.contains(imp)).join('\n');
    if (topLevelCode.isNotEmpty && !content.contains(topLevelCode.firstWhere((line) => line.isNotEmpty, orElse: () => ''))){
      combinedHeaderCode += '\n\n' + topLevelCode.join('\n');
    }

    if (combinedHeaderCode.isNotEmpty) {
      final lastImportIndex = content.lastIndexOf(RegExp(r"import\s*'.+';"));
      if (lastImportIndex != -1) {
        final endOfLineIndex = content.indexOf('\n', lastImportIndex);
        content = content.substring(0, endOfLineIndex + 1) +
            combinedHeaderCode + '\n' +
            content.substring(endOfLineIndex + 1);
      } else { content = '$combinedHeaderCode\n$content'; }
    }

    // Inject Main Function Code
    final mainRegex = RegExp(r'void\s+main\s*\(\s*\)\s*(async\s*)?({)');
    if (content.contains(mainRegex)) {
      content = content.replaceFirstMapped(mainRegex, (match) {
        final openingBrace = match.group(2)!;
        final allMainCode = mainFunctionCode.join('\n');
        final newSignature = 'void main() async $openingBrace';
        return '$newSignature\n$allMainCode';
      });
    }

    // --- 3. Write Changes to File ---
    mainFile.writeAsStringSync(content);
    print('✅ lib/main.dart updated successfully.');
  }
}