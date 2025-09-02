import 'dart:io';
import 'package:path/path.dart' as p;
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
      _injectAnalyticsIntoRoutes();
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
      importsToAdd.add("import 'core/utils/notification_service.dart';");
      mainFunctionCode.add('  await NotificationService().initialize();');
      mainFunctionCode.add('');
      _setupPushNotifications();
      _updateBuildGradle();
      _updateAndroidManifest();
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

  static Future<void> _injectAnalyticsIntoRoutes() async {
    final appPagesFile = File('lib/routes/app_pages.dart');
    if (!await appPagesFile.exists()) {
      print('⚠️ Warning: lib/routes/app_pages.dart not found. Could not inject analytics.');
      return;
    }
    print('   -> Injecting Analytics into app routes...');

    var lines = await appPagesFile.readAsLines();

    // 1. Add the analytics import and helper function if they don't exist
    const analyticsImport = "import 'package:firebase_analytics/firebase_analytics.dart';";
    const helperFunction = '''
void registerAnalyticsEvent({required String name}) {
  FirebaseAnalytics.instance.logEvent(name: name.replaceAll('/', ''), parameters: {'time': '\${DateTime.now()}'});
}
''';

    // Add import if it doesn't exist, placing it before 'part' directives.
    if (!lines.any((line) => line.contains(analyticsImport))) {
      int insertIndex = lines.indexWhere((line) => line.trim().startsWith('part '));
      if (insertIndex == -1) { // Fallback if no 'part' directive
        insertIndex = lines.indexWhere((line) => line.trim().startsWith('class '));
      }
      if (insertIndex == -1) { // Fallback if no class either
        insertIndex = 1;
      }
      lines.insert(insertIndex, analyticsImport);
    }

    // Add helper function if it doesn't exist
    if (!lines.any((line) => line.contains('void registerAnalyticsEvent'))) {
      final classDefIndex = lines.indexWhere((line) => line.contains('class AppPages {'));
      if (classDefIndex != -1) {
        lines.insert(classDefIndex, '\n$helperFunction');
      }
    }

    var content = lines.join('\n');

    // 2. Use a robust regex to find and replace page builders that haven't been converted yet.
    // This specifically targets the simple arrow function syntax: `page: () => Widget()`
    final pageRegex = RegExp(
      r'(name:\s*(AppRoutes\.[a-zA-Z_]+),[\s\n\r]*page:\s*\(\)\s*=>\s*([a-zA-Z0-9_<>]+)\(\))',
      multiLine: true,
    );

    if (!pageRegex.hasMatch(content)) {
      print('   -> No routes to update, or they are already configured for analytics.');
      await appPagesFile.writeAsString(content); // Write back content with potential import/helper changes
      return;
    }

    content = content.replaceAllMapped(pageRegex, (match) {
      // The regex captures the route name (group 2) and widget name (group 3) together.
      final routeName = match.group(2);
      final widgetName = match.group(3);

      if (routeName == null || widgetName == null) {
        return match.group(0)!; // Return original if something unexpected happens
      }

      // Construct the new page block with the correct analytics call
      return '''name: $routeName,
      page: () {
        registerAnalyticsEvent(name: $routeName);
        return $widgetName();
      }''';
    });

    await appPagesFile.writeAsString(content);
    print('   -> Successfully injected analytics logging into GetPage routes.');
  }

  static Future<void> _setupPushNotifications() async {
    // 1. Copy the utility file from templates to the project
    final scriptPath = Platform.script.toFilePath();
    final templatePath = p.normalize(p.join(p.dirname(scriptPath), '..', 'lib', 'templates', 'core', 'notification_service.dart'));
    final templateFile = File(templatePath);

    final targetDir = Directory('lib/core/utils');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final targetFile = File('lib/core/utils/notification_service.dart');
    targetFile..createSync(recursive: true)..writeAsStringSync(await templateFile.readAsString());
    print('   -> Updated lib/main.dart to initialize NotificationService.');
  }

  static Future<void> _updateAndroidManifest() async {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (!await manifestFile.exists()) {
      print('⚠️ Warning: AndroidManifest.xml not found. Could not add notification meta-data.');
      return;
    }
    print('   -> Updating AndroidManifest.xml for push notifications...');

    var lines = await manifestFile.readAsLines();

    const channelIdMetaData = '        <meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" android:value="primary_channel" />';
    const iconMetaData = '        <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@mipmap/ic_launcher" />';

    if (lines.any((line) => line.contains('com.google.firebase.messaging.default_notification_channel_id'))) {
      print('   -> Notification meta-data already exists in AndroidManifest.xml.');
      return;
    }

    final activityEndIndex = lines.lastIndexWhere((line) => line.trim().startsWith('</activity>'));

    if (activityEndIndex != -1) {
      lines.insert(activityEndIndex, iconMetaData);
      lines.insert(activityEndIndex, channelIdMetaData);
      await manifestFile.writeAsString(lines.join('\n'));
      print('   -> Added notification meta-data to AndroidManifest.xml.');
    } else {
      print('⚠️ Warning: Could not find a suitable location in AndroidManifest.xml to add meta-data.');
    }
  }

  static Future<void> _updateBuildGradle() async {
    final buildGradleFile = File('android/app/build.gradle.kts');
    if (!await buildGradleFile.exists()) {
      print('⚠️ Warning: android/app/build.gradle not found. Could not apply required settings.');
      return;
    }
    print('   -> Updating android/app/build.gradle for Firebase compatibility...');

    var lines = await buildGradleFile.readAsLines();
    var contentModified = false;

    // --- Update minSdkVersion and add multiDexEnabled ---
    final defaultConfigIndex = lines.indexWhere((line) => line.trim().startsWith('defaultConfig'));
    if (defaultConfigIndex != -1) {
      final defaultConfigEndIndex = lines.indexWhere((line) => line.trim() == '}', defaultConfigIndex);
      if (defaultConfigEndIndex != -1) {
        // Update minSdkVersion within the block
        for (int i = defaultConfigIndex; i < defaultConfigEndIndex; i++) {
          if (lines[i].trim().startsWith('minSdk')) {
            if (!lines[i].contains('23')) {
              lines[i] = '        minSdk = 23';
              print('   -> Set minSdk to 23.');
              contentModified = true;
            }
            break;
          }
        }
        // Add multiDexEnabled if not present
        if (!lines.any((line) => line.contains('multiDexEnabled'))) {
          lines.insert(defaultConfigEndIndex, '        multiDexEnabled = true');
          print('   -> Enabled multiDex.');
          contentModified = true;
        }
      }
    }

    // --- Enable coreLibraryDesugaring ---
    final compileOptionsIndex = lines.indexWhere((line) => line.trim().startsWith('compileOptions'));
    if (compileOptionsIndex != -1) {
      final compileOptionsEndIndex = lines.indexWhere((line) => line.trim() == '}', compileOptionsIndex);
      if (compileOptionsEndIndex != -1 && !lines.any((line) => line.contains('coreLibraryDesugaringEnabled'))) {
        lines.insert(compileOptionsEndIndex, '        coreLibraryDesugaringEnabled = true');
        print('   -> Enabled coreLibraryDesugaring.');
        contentModified = true;
      }
    }

    // --- Add desugaring dependency ---
    final dependenciesIndex = lines.indexWhere((line) => line.trim().startsWith('dependencies'));
    if (dependenciesIndex != -1) {
      if (!lines.any((line) => line.contains('desugar_jdk_libs'))) {
        lines.insert(dependenciesIndex + 1, '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")');
        print('   -> Added desugar_jdk_libs dependency.');
        contentModified = true;
      }
    } else {
      // If dependencies block does not exist, add it at the end of the file.
      lines.add('');
      lines.add('dependencies {');
      lines.add('    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")');
      lines.add('}');
      print('   -> Created dependencies block and added desugar_jdk_libs.');
      contentModified = true;
    }

    if (contentModified) {
      await buildGradleFile.writeAsString(lines.join('\n'));
      print('   -> build.gradle updated successfully.');
    } else {
      print('   -> build.gradle already contains the required settings.');
    }
  }

}