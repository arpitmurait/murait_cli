import 'dart:io';
import '../../utils.dart' show PackageType;

/// Templates and utilities for project creation
class ProjectTemplates {
  /// Create pubspec.yaml file for a new project
  static Future<void> createPubspecFile(String projectName) async {
    final content = _pubspecTemplate(projectName);
    final file = File('$projectName/pubspec.yaml');
    await file.writeAsString(content);
  }

  /// Generate pubspec.yaml template
  static String _pubspecTemplate(String name) => '''
name: ${name.toLowerCase().replaceAll(' ', '_')}
description: "A new Flutter project."
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  ${PackageType.cupertinoIcons}
  ${PackageType.intl}
  ${PackageType.get}
  ${PackageType.hiveFlutter}
  ${PackageType.screenUtil}
  ${PackageType.cachedNetworkImage}
  ${PackageType.svg}
  ${PackageType.toast}
  ${PackageType.easyLoading}
  ${PackageType.connectivityPlus}
  ${PackageType.dio}
  ${PackageType.animate}
  ${PackageType.alert}
  ${PackageType.shimmer}
  ${PackageType.imageCropper}
  ${PackageType.imagePicker}
  ${PackageType.logger}
  ${PackageType.upgrader}

dev_dependencies:
  flutter_test:
    sdk: flutter

  ${PackageType.lints}

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/
    
  # example:
  # fonts:
  #   - family: Poppins
  #     fonts:
  #       - asset: fonts/Poppins-Regular.ttf
  #       - asset: fonts/Poppins-Italic.ttf
  #         style: italic
  
''';
}

