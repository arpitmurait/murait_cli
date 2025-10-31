import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import 'firebase_service_handler.dart';

/// Handles Firebase Messaging/Notifications setup
class MessagingHandler implements FirebaseServiceHandler {
  @override
  String get serviceType => 'messaging';

  @override
  Future<void> setup() async {
    await _copyNotificationService();
    await _updateAndroidManifest();
    await _updateBuildGradle();
    await _updateBuildGradleKts();
  }

  @override
  Future<bool> isConfigured() async {
    final notificationService = File('lib/core/utils/notification_service.dart');
    return await notificationService.exists();
  }

  Future<void> _copyNotificationService() async {
    // Find the package root using Isolate.resolvePackageUri (more reliable)
    String? templatePath;
    
    try {
      final packageUri = await Isolate.resolvePackageUri(
        Uri.parse('package:murait_cli/generators/getx/firebase/services/messaging_handler.dart')
      );
      if (packageUri != null && packageUri.scheme == 'file') {
        var packagePath = packageUri.toFilePath(windows: Platform.isWindows);
        var servicesDir = p.dirname(packagePath); // firebase/services
        var firebaseDir = p.dirname(servicesDir); // firebase
        var getxDir = p.dirname(firebaseDir); // getx
        var generatorsDir = p.dirname(getxDir); // generators
        var libDir = p.dirname(generatorsDir); // lib
        var rootDir = p.dirname(libDir); // package root
        
        templatePath = p.join(rootDir, 'lib', 'templates', 'core', 'notification_service.dart');
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
          'notification_service.dart',
        ),
      );
    }();

    // Check if template exists (templatePath is guaranteed to be non-null at this point)
    bool templateExists = await File(templatePath).exists();
    if (!templateExists) {
      final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
      if (homeDir.isNotEmpty) {
        final pubCachePath = Platform.isWindows
            ? p.join(homeDir, 'AppData', 'Local', 'Pub', 'Cache')
            : p.join(homeDir, '.pub-cache');
        
        final globalPackagesPath = p.join(pubCachePath, 'global_packages', 'murait_cli');
        if (await Directory(globalPackagesPath).exists()) {
          final testPath = p.join(globalPackagesPath, 'lib', 'templates', 'core', 'notification_service.dart');
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
                final testPath = p.join(entity.path, 'lib', 'templates', 'core', 'notification_service.dart');
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
      // If template not found, create a minimal version
      print('⚠️ Warning: notification_service.dart template not found. Creating minimal version.');
      await _createMinimalNotificationService();
      return;
    }
    
    final templateFile = File(templatePath);

    final targetDir = Directory('lib/core/utils');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    
    final targetFile = File('lib/core/utils/notification_service.dart');
    final exists = await targetFile.exists();
    await targetFile.writeAsString(await templateFile.readAsString());
    print('   -> ${exists ? 'Updated' : 'Created'} lib/core/utils/notification_service.dart');
  }

  Future<void> _createMinimalNotificationService() async {
    final targetDir = Directory('lib/core/utils');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    
    final minimalService = '''
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotificationsPlugin.initialize(initSettings);
    
    // Request permissions
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
''';
    
    final targetFile = File('lib/core/utils/notification_service.dart');
    await targetFile.writeAsString(minimalService);
    print('   -> Created minimal lib/core/utils/notification_service.dart');
  }

  Future<void> _updateAndroidManifest() async {
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

  Future<void> _updateBuildGradle() async {
    final buildGradleFile = File('android/app/build.gradle');
    if (!await buildGradleFile.exists()) {
      print('⚠️ Warning: android/app/build.gradle not found.');
      return;
    }
    print('   -> Updating android/app/build.gradle for Firebase compatibility...');

    var lines = await buildGradleFile.readAsLines();
    var contentModified = false;

    // Update minSdkVersion and add multiDexEnabled
    final defaultConfigIndex = lines.indexWhere((line) => line.trim().startsWith('defaultConfig'));
    if (defaultConfigIndex != -1) {
      final defaultConfigEndIndex = lines.indexWhere((line) => line.trim() == '}', defaultConfigIndex);
      if (defaultConfigEndIndex != -1) {
        for (int i = defaultConfigIndex; i < defaultConfigEndIndex; i++) {
          if (lines[i].trim().startsWith('minSdkVersion') && !lines[i].contains('23')) {
            lines[i] = '        minSdkVersion 23';
            contentModified = true;
          }
        }
        if (!lines.any((line) => line.contains('multiDexEnabled'))) {
          lines.insert(defaultConfigEndIndex, '        multiDexEnabled true');
          contentModified = true;
        }
      }
    }

    // Add coreLibraryDesugaringEnabled
    final compileOptionsIndex = lines.indexWhere((line) => line.trim().startsWith('compileOptions'));
    if (compileOptionsIndex != -1) {
      final compileOptionsEndIndex = lines.indexWhere((line) => line.trim() == '}', compileOptionsIndex);
      if (compileOptionsEndIndex != -1 && !lines.any((line) => line.contains('coreLibraryDesugaringEnabled'))) {
        lines.insert(compileOptionsEndIndex, '        coreLibraryDesugaringEnabled true');
        contentModified = true;
      }
    }

    // Add desugaring dependency
    final dependenciesIndex = lines.indexWhere((line) => line.trim().startsWith('dependencies'));
    if (dependenciesIndex != -1) {
      if (!lines.any((line) => line.contains('desugar_jdk_libs'))) {
        lines.insert(dependenciesIndex + 1, "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'");
        contentModified = true;
      }
    }

    if (contentModified) {
      await buildGradleFile.writeAsString(lines.join('\n'));
      print('   -> Updated build.gradle successfully.');
    }
  }

  Future<void> _updateBuildGradleKts() async {
    final buildGradleKtsFile = File('android/app/build.gradle.kts');
    if (!await buildGradleKtsFile.exists()) {
      return; // KTS file is optional
    }
    print('   -> Updating android/app/build.gradle.kts...');

    var lines = await buildGradleKtsFile.readAsLines();
    var contentModified = false;

    final defaultConfigIndex = lines.indexWhere((line) => line.contains('defaultConfig'));
    if (defaultConfigIndex != -1) {
      final defaultConfigEndIndex = lines.indexWhere((line) => line.trim() == '}', defaultConfigIndex);
      if (defaultConfigEndIndex != -1) {
        for (int i = defaultConfigIndex; i < defaultConfigEndIndex; i++) {
          if (lines[i].trim().startsWith('minSdk') && !lines[i].contains('23')) {
            lines[i] = lines[i].replaceAll(RegExp(r'minSdk\s*=?\s*\d+'), 'minSdk = 23');
            contentModified = true;
          }
        }
        if (!lines.any((line) => line.contains('multiDexEnabled'))) {
          lines.insert(defaultConfigEndIndex, '        multiDexEnabled = true');
          contentModified = true;
        }
      }
    }

    // Add coreLibraryDesugaringEnabled
    final compileOptionsIndex = lines.indexWhere((line) => line.trim().startsWith('compileOptions'));
    if (compileOptionsIndex != -1) {
      final compileOptionsEndIndex = lines.indexWhere((line) => line.trim() == '}', compileOptionsIndex);
      if (compileOptionsEndIndex != -1 && !lines.any((line) => line.contains('coreLibraryDesugaringEnabled'))) {
        lines.insert(compileOptionsEndIndex, '        isCoreLibraryDesugaringEnabled = true');
        contentModified = true;
      }
    }

    // Add desugaring dependency
    final dependenciesIndex = lines.indexWhere((line) => line.trim().startsWith('dependencies'));
    if (dependenciesIndex != -1) {
      if (!lines.any((line) => line.contains('desugar_jdk_libs'))) {
        lines.insert(dependenciesIndex + 1, '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")');
        contentModified = true;
      }
    }

    if (contentModified) {
      await buildGradleKtsFile.writeAsString(lines.join('\n'));
      print('   -> Updated build.gradle.kts successfully.');
    }
  }
}

