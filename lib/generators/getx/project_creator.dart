import 'dart:io';
import 'dart:isolate';
import 'package:murait_cli/generators/getx/core/project_templates.dart';
import 'package:path/path.dart' as p;
import 'package:process/process.dart';

class ProjectGenerator {
  // The path inside your CLI tool where the boilerplate 'lib' folder should be located.
  final templateLibPath = 'lib/template_lib';
  final templateAssetsPath = 'lib/assets';
  String? _packageRoot;

  /// Finds the root directory of the installed murait_cli package.
  Future<String?> _findPackageRoot() async {
    if (_packageRoot != null) return _packageRoot;

    // Method 1: Try using Isolate.resolvePackageUri to find the package location
    // Resolve a file that definitely exists in the package
    try {
      final packageUri = await Isolate.resolvePackageUri(
        Uri.parse('package:murait_cli/generators/getx/project_creator.dart')
      );
      if (packageUri != null && packageUri.scheme == 'file') {
        // Convert package: URI to file path
        var packagePath = packageUri.toFilePath(windows: Platform.isWindows);
        // Navigate from lib/generators/getx/project_creator.dart to package root
        var getxDir = Directory(p.dirname(packagePath)); // lib/generators/getx
        var generatorsDir = getxDir.parent; // lib/generators
        var libDir = generatorsDir.parent; // lib
        var rootDir = libDir.parent; // package root
        
        final pubspecFile = File(p.join(rootDir.path, 'pubspec.yaml'));
        if (await pubspecFile.exists()) {
          final content = await pubspecFile.readAsString();
          if (content.contains('name: murait_cli')) {
            _packageRoot = rootDir.path;
            return _packageRoot;
          }
        }
      }
    } catch (e) {
      // Continue to other methods if this fails
    }

    // Method 2: Try using Platform.script to find the script location and traverse
    var scriptUri = Platform.script;
    var scriptPath = scriptUri.toFilePath(windows: Platform.isWindows);
    
    // Method 2a: Check if script is a snapshot or compiled, get source location
    // For globally activated packages from git, the script might point to .dart_tool or cache
    var scriptDir = Directory(p.dirname(scriptPath));
    
    // Traverse up from script location to find pubspec.yaml
    var currentDir = scriptDir;
    var lastPath = '';
    int maxIterations = 30; // Prevent infinite loops
    int iterations = 0;
    
    while (iterations < maxIterations) {
      if (currentDir.path == lastPath) break; // Reached root
      lastPath = currentDir.path;
      
      final pubspecFile = File(p.join(currentDir.path, 'pubspec.yaml'));
      if (await pubspecFile.exists()) {
        try {
          final content = await pubspecFile.readAsString();
          if (content.contains('name: murait_cli')) {
            _packageRoot = currentDir.path;
            return _packageRoot;
          }
        } catch (e) {
          // Continue searching if file read fails
        }
      }
      
      if (!await currentDir.parent.exists()) break;
      currentDir = currentDir.parent;
      iterations++;
    }

    // Method 3: Try the global_packages location (for globally activated packages)
    final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    if (homeDir.isNotEmpty) {
      final pubCachePath = Platform.isWindows 
          ? p.join(homeDir, 'AppData', 'Local', 'Pub', 'Cache')
          : p.join(homeDir, '.pub-cache');
      
      // Check global_packages
      final globalPackagesPath = p.join(pubCachePath, 'global_packages', 'murait_cli');
      final globalPackagesDir = Directory(globalPackagesPath);
      if (await globalPackagesDir.exists()) {
        final pubspecFile = File(p.join(globalPackagesDir.path, 'pubspec.yaml'));
        if (await pubspecFile.exists()) {
          final content = await pubspecFile.readAsString();
          if (content.contains('name: murait_cli')) {
            _packageRoot = globalPackagesDir.path;
            return _packageRoot;
          }
        }
      }
      
      // Check git cache location (for packages installed from git)
      // When installing from git, packages are in git/cache/
      final gitCachePath = p.join(pubCachePath, 'git', 'cache');
      final gitCacheDir = Directory(gitCachePath);
      if (await gitCacheDir.exists()) {
        // Look for directories that might contain murait_cli
        await for (var entity in gitCacheDir.list()) {
          if (entity is Directory) {
            final pubspecFile = File(p.join(entity.path, 'pubspec.yaml'));
            if (await pubspecFile.exists()) {
              try {
                final content = await pubspecFile.readAsString();
                if (content.contains('name: murait_cli')) {
                  _packageRoot = entity.path;
                  return _packageRoot;
                }
              } catch (e) {
                // Continue searching
              }
            }
          }
        }
      }
    }

    return null;
  }

  Future<void> createProject(String projectName) async {
    final packageRoot = await _findPackageRoot();
    if (packageRoot == null) {
      print('❌ Error: Could not determine the package root directory of the CLI tool.');
      print('➡️ This might happen if the CLI is not installed correctly. Try re-installing it.');
      return;
    }

    // Construct absolute paths to the template directories
    final templateLibPath = p.join(packageRoot, 'lib', 'template_lib');
    final templateAssetsPath = p.join(packageRoot, 'lib',  'assets');

    final projectDir = Directory(projectName);
    if (await projectDir.exists()) {
      print('❌ Error: Directory "$projectName" already exists.');
      return;
    }

    final templateLibDir = Directory(templateLibPath);
    if (!await templateLibDir.exists() || templateLibDir.listSync().isEmpty) {
      print('❌ Error: Template directory not found or is empty at "$templateLibPath".');
      print('➡️ Please ensure the "lib/template_lib" folder exists in your GitHub repository.');
      return;
    }

    print('🚀 Creating a new Flutter project "$projectName"... (This might take a moment)');
    const processManager = LocalProcessManager();
    var result = await processManager.run(['flutter', 'create', projectName]);

    if (result.exitCode != 0) {
      print('❌ Error creating Flutter project. See output below:');
      print(result.stdout);
      print(result.stderr);
      return;
    }
    print('✅ Flutter project created successfully.');

    // Delete the default lib folder generated by `flutter create`.
    final defaultLib = Directory('$projectName/lib');
    if (await defaultLib.exists()) {
      print('🗑️  Deleting default lib folder...');
      await defaultLib.delete(recursive: true);
    }

    // Copy your custom boilerplate lib folder.
    print('✨ Copying boilerplate from "$templateLibPath"...');
    final newLibDir = Directory('$projectName/lib');
    await newLibDir.create();
    await _copyDirectory(templateLibDir, newLibDir);

    // Copy your custom boilerplate assets folder.
    final templateAssetsDir = Directory(templateAssetsPath);
    if (await templateAssetsDir.exists() && templateAssetsDir.listSync().isNotEmpty) {
      print('✨ Copying boilerplate assets from "$templateAssetsPath"...');
      final newAssetsDir = Directory('$projectName/assets');
      await newAssetsDir.create();
      await _copyDirectory(templateAssetsDir, newAssetsDir);
    } else {
      print('⚠️  Warning: Template assets directory not found at "$templateAssetsPath". Skipping assets copy.');
    }
    print('✅ Boilerplate lib folder copied.');
    await ProjectTemplates.createPubspecFile(projectName);

    print('\n🎉 Success! Project "$projectName" is ready.');
    print('Next steps:');
    print('  cd $projectName');
    print('  flutter pub get');
    print('  flutter run');
  }

  /// Recursively copies a directory.
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory('${destination.path}/${entity.path.split(Platform.pathSeparator).last}');
        await newDirectory.create();
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy('${destination.path}/${entity.path.split(Platform.pathSeparator).last}');
      }
    }
  }
}
