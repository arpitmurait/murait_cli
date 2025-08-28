import 'dart:io';
import 'utils.dart';

class GetXGenerator {
  void createFeature(String name, {bool withModel = false, bool withRepo = false}) {
    final folder = Directory('lib/screens/$name');
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    final folder2 = Directory('lib/screens/$name/widgets');
    if (!folder2.existsSync()) {
      folder2.createSync(recursive: true);
    }

    final files = {
      '${name}_controller.dart': _controllerTemplate(name),
      '${name}_screen.dart': _viewTemplate(name),
    };

    if (withModel) {
      files['data/model/${name}_model.dart'] = _modelTemplate(name);
    }
    if (withRepo) {
      files['data/repository/${name}_repository.dart'] = _repoTemplate(name);
    }

    files.forEach((path, content) {
      File('${folder.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
      print('✅ Created lib/app/modules/$name/$path');
    });
  }

  String _controllerTemplate(String name) => '''
import 'package:get/get.dart';
${_importIfRepo(name)}

class ${capitalize(name)}Controller extends GetxController {
  // TODO: Implement ${capitalize(name)}Controller
  ${_repoField(name)}
}
''';

  String _viewTemplate(String name) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../${name}_controller.dart';

class ${capitalize(name)}View extends GetView<${capitalize(name)}Controller> {
  const ${capitalize(name)}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${capitalize(name)}')),
      body: const Center(child: Text('${capitalize(name)}View')),
    );
  }
}
''';

  String _modelTemplate(String name) => '''
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

  String _repoTemplate(String name) => '''
import '../models/${name}_model.dart';

abstract class ${capitalize(name)}Repository {
  Future<${capitalize(name)}Model> fetchData();
}

class ${capitalize(name)}RepositoryImpl implements ${capitalize(name)}Repository {

  @override
  Future<${capitalize(name)}Model> fetchData() async {
    // TODO: Replace with API/DB call
    await Future.delayed(const Duration(seconds: 1));
    return ${capitalize(name)}Model(id: 1, name: '${capitalize(name)} example');
  }
}
''';

  String _importIfRepo(String name) => '''
import '/data/repository/${name}_repository.dart';
''';

  String _repoField(String name) => '''
final ${capitalize(name)}Repository repository;
${capitalize(name)}Controller(this.repository);
''';

}
