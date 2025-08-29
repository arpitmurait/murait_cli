import 'dart:io';

import '../utils.dart';

class Templates {
  static String controllerTemplate(String name, {bool withRepo = false}) => '''
import 'package:get/get.dart';
${withRepo ? _importIfRepo(name) : ''}

class ${capitalize(name)}Controller extends GetxController {
  // TODO: Implement ${capitalize(name)}Controller
  ${withRepo ? _repoField(name) : ''}
}
''';

  static String viewTemplate(String name) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '${name}_controller.dart';

class ${capitalize(name)}Screen extends StatelessWidget {
  const ${capitalize(name)}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(${capitalize(name)}Controller());
    return Scaffold(
      appBar: AppBar(title: const Text('${capitalize(name)}')),
      body: const Center(child: Text('${capitalize(name)} Screen is working')),
    );
  }
}
''';

  static String modelTemplate(String name) => '''
class ${capitalize(name)}Model {
  final int id;
  final String name;

  ${capitalize(name)}Model({required this.id, required this.name});

  factory ${capitalize(name)}Model.fromJson(Map<String, dynamic> json) {
    return ${capitalize(name)}Model(
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

abstract class ${capitalize(name)}Repository {
  Future<${capitalize(name)}Model> fetchData();
}

class ${capitalize(name)}RepositoryImpl implements ${capitalize(name)}Repository {
  final ApiService apiService;
  ${capitalize(name)}RepositoryImpl({required this.apiService});

  @override
  Future<${capitalize(name)}Model> fetchData() async {
    // TODO: Replace with API/DB call
    await Future.delayed(const Duration(seconds: 1));
    return ${capitalize(name)}Model(id: 1, name: '${capitalize(name)} example');
  }
}
''';

  static String _importIfRepo(String name) =>
      "import '../../data/repository/${name}_repository.dart';";

  static String _repoField(String name) =>
      'final ${capitalize(name)}Repository _repository = Get.find(tag: (${capitalize(name)}Repository).toString());';


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
  cupertino_icons: ^1.0.8
  intl:
  get: ^4.7.2
  hive_flutter: ^2.0.0-dev
  flutter_screenutil: ^5.9.3
  cached_network_image: ^3.4.1
  flutter_svg: ^2.2.0
  fluttertoast: ^8.2.12
  flutter_easyloading: ^3.0.5
  connectivity_plus: ^6.1.5
  dio: ^5.9.0
  flutter_animate: ^4.5.2
  rflutter_alert: ^2.0.7
  h3m_shimmer_card: ^0.0.2
  image_cropper: ^8.1.0
  image_picker: ^1.2.0
  logger: ^2.6.1
  upgrader: ^11.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^5.0.0

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
