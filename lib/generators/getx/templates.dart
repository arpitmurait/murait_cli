import 'dart:io';

import '../utils.dart' show PackageType, toPascalCase;

class Templates {
  static String controllerTemplate(String name, {bool withRepo = false}) => '''
import 'package:get/get.dart';
${withRepo ? _importIfRepo(name) : ''}

class ${toPascalCase(name)}Controller extends GetxController {
  // TODO: Implement ${toPascalCase(name)}Controller
  ${withRepo ? _repoField(name) : ''}
}
''';

  static String viewTemplate(String name) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '${name}_controller.dart';

class ${toPascalCase(name)}Screen extends StatelessWidget {
  const ${toPascalCase(name)}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(${toPascalCase(name)}Controller());
    return Scaffold(
      appBar: AppBar(title: const Text('${toPascalCase(name.replaceAll('_', ' '))}')),
      body: const Center(child: Text('${toPascalCase(name.replaceAll('_', ' '))} Screen is working')),
    );
  }
}
''';

  static String modelTemplate(String name) => '''
class ${toPascalCase(name)}Model {
  final int id;
  final String name;

  ${toPascalCase(name)}Model({required this.id, required this.name});

  factory ${toPascalCase(name)}Model.fromJson(Map<String, dynamic> json) {
    return ${toPascalCase(name)}Model(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
''';

  static String repoTemplate(String name) => '''
import '../model/${name}_model.dart';
import '../../network/api_service.dart';

abstract class ${toPascalCase(name)}Repository {
  Future<${toPascalCase(name)}Model> fetchData();
}

class ${toPascalCase(name)}RepositoryImpl implements ${toPascalCase(name)}Repository {
  final ApiService apiService;
  ${toPascalCase(name)}RepositoryImpl({required this.apiService});

  @override
  Future<${toPascalCase(name)}Model> fetchData() async {
    // TODO: Replace with API/DB call
    await Future.delayed(const Duration(seconds: 1));
    return ${toPascalCase(name)}Model(id: 1, name: '${toPascalCase(name.replaceAll('_', ' '))} example');
  }
}
''';

  static String _importIfRepo(String name) =>
      "import '../../data/repository/${name}_repository.dart';";

  static String _repoField(String name) =>
      'final ${toPascalCase(name)}Repository _repository = Get.find(tag: (${toPascalCase(name)}Repository).toString());';


  static Future<void> createPubspecFile(String projectName) async {
    final content = _pubspecTemplate(projectName);
    final file = File('$projectName/pubspec.yaml');
    await file.writeAsString(content);
  }

  static String _pubspecTemplate(String name) => '''
name: ${name.toLowerCase().replaceAll(' ', '_')}
description: "A new Flutter project."
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0' # Updated SDK constraint for modern Dart

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
