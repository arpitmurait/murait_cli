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
}
