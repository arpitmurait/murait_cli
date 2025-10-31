import 'dart:io';
import '../../../utils.dart';

/// Manages pubspec.yaml updates for Firebase dependencies
class FirebasePubspecManager {
  final File _pubspecFile;

  FirebasePubspecManager() : _pubspecFile = File('pubspec.yaml');

  /// Map of Firebase service types to their dependencies
  static final Map<String, List<String>> _serviceDependencies = {
    FirebaseServiceType.core: [PackageType.core],
    FirebaseServiceType.auth: [
      PackageType.auth,
      PackageType.googleSignIn,
      PackageType.appleSignIn,
    ],
    FirebaseServiceType.firestore: [PackageType.firestore],
    FirebaseServiceType.messaging: [
      PackageType.messaging,
      PackageType.localNotifications,
    ],
    FirebaseServiceType.analytics: [PackageType.analytics],
    FirebaseServiceType.crashlytics: [PackageType.crashlytics],
    FirebaseServiceType.ads: [
      PackageType.ads,
      PackageType.remoteConfig,
    ],
  };

  /// Get dependencies for a list of services
  List<String> getDependenciesForServices(List<String> services) {
    final dependencies = <String>{};
    
    for (final service in services) {
      final serviceDeps = _serviceDependencies[service] ?? [];
      dependencies.addAll(serviceDeps);
    }
    
    return dependencies.toList();
  }

  /// Update pubspec.yaml with Firebase dependencies
  Future<int> updatePubspec(List<String> services) async {
    if (!await _pubspecFile.exists()) {
      print('❌ Error: pubspec.yaml not found. Are you in the root of a Flutter project?');
      return 0;
    }

    print('✏️  Adding Firebase dependencies to pubspec.yaml...');

    List<String> lines = await _pubspecFile.readAsLines();
    int dependenciesIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
    
    if (dependenciesIndex == -1) {
      print('❌ Error: Could not find "dependencies:" section in pubspec.yaml.');
      return 0;
    }

    final dependenciesToAdd = getDependenciesForServices(services);
    int addedCount = 0;

    for (var dep in dependenciesToAdd) {
      final packageName = dep.trim().split(':').first.split('\n').first.trim();
      final packageMatch = RegExp(r'^[a-zA-Z0-9_-]+').firstMatch(packageName);
      final actualPackageName = packageMatch?.group(0) ?? packageName;
      
      if (!lines.any((line) {
        final trimmed = line.trim();
        return trimmed.startsWith(actualPackageName) || 
               trimmed.startsWith(packageName.split(' ').first);
      })) {
        // Handle multiline dependencies (like git dependencies)
        if (dep.contains('\n')) {
          // Format multiline dependency with proper indentation
          final depLines = dep.split('\n');
          final formattedDep = depLines.asMap().entries.map((entry) {
            if (entry.key == 0) {
              return '  ${entry.value}'; // First line: package name with 2 spaces
            } else {
              return '    ${entry.value}'; // Subsequent lines: with 4 spaces
            }
          }).join('\n');
          lines.insert(dependenciesIndex + 1, formattedDep);
        } else {
          lines.insert(dependenciesIndex + 1, '  $dep');
        }
        addedCount++;
      }
    }

    if (addedCount > 0) {
      await _pubspecFile.writeAsString(lines.join('\n'));
      print('✅ Added $addedCount new dependencies.');
    } else {
      print('👍 All required Firebase dependencies are already in pubspec.yaml.');
    }

    return addedCount;
  }
}

