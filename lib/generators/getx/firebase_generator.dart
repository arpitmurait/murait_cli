import 'dart:io';

import 'package:murait_cli/generators/getx/firebase_templates.dart';

import '../utils.dart';

class FirebaseGenerator {

  // A map of service keys to their pubspec dependencies.
  static final Map<String, String> _firebasePackages = {
    FirebaseServiceType.core: 'firebase_core: ^4.0.0',
    FirebaseServiceType.auth: 'firebase_auth: ^6.0.1',
    FirebaseServiceType.firestore: 'cloud_firestore: ^6.0.0',
    FirebaseServiceType.messaging: 'firebase_messaging: ^16.0.0', // For Notifications
    FirebaseServiceType.messaging: 'flutter_local_notifications: ^19.4.1', // For Notifications
    FirebaseServiceType.analytics: 'firebase_analytics: ^12.0.0',
    FirebaseServiceType.crashlytics: 'firebase_crashlytics: ^5.0.0',
  };

  void addServices(List<String> services) {
    updatePubspec(services);
    FirebaseTemplates.updateMain(services);

    print('\n✅ Firebase setup complete!');
    print('------------------------------------------');
    print('🔴 IMPORTANT NEXT STEPS:');
    print('1. Run `flutter pub get` in your project terminal.');
    print('2. Configure your project with the FlutterFire CLI.');
    print('   - If you don\'t have it, run: `dart pub global activate flutterfire_cli`');
    print('   - Then run: `flutterfire configure`');
    print('   - Follow the prompts to connect to your Firebase project.');
    print('------------------------------------------');
  }

  void updatePubspec(List<String> services) {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('❌ Error: pubspec.yaml not found. Are you in the root of a Flutter project?');
      return;
    }

    print('✏️  Adding Firebase dependencies to pubspec.yaml...');

    List<String> lines = pubspecFile.readAsLinesSync();
    int dependenciesIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
    if (dependenciesIndex == -1) {
      print('❌ Error: Could not find "dependencies:" section in pubspec.yaml.');
      return;
    }

    // Get the full dependency strings for the requested services.
    final dependenciesToAdd = services
        .map((key) => _firebasePackages[key])
        .where((item) => item != null)
        .cast<String>()
        .toList();

    // Check and add dependencies if they don't exist.
    int addedCount = 0;
    for (var dep in dependenciesToAdd) {
      final packageName = dep.trim().split(':').first;
      if (!lines.any((line) => line.trim().startsWith(packageName))) {
        lines.insert(dependenciesIndex + 1, '  $dep');
        addedCount++;
      }
    }

    if (addedCount > 0) {
      pubspecFile.writeAsStringSync(lines.join('\n'));
      print('✅ Added $addedCount new dependencies.');
    } else {
      print('👍 All required Firebase dependencies are already in pubspec.yaml.');
    }
  }
}
