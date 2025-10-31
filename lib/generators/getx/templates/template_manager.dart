import '../../utils.dart' show toPascalCase;
import '../core/path_config.dart';

/// Interface for template providers
abstract class GetXTemplateProvider {
  String controllerTemplate(String name, {bool withRepo = false});
  String viewTemplate(String name);
  String modelTemplate(String name);
  String repoTemplate(String name);
}

/// Default GetX template provider
class DefaultGetXTemplateProvider implements GetXTemplateProvider {
  @override
  String controllerTemplate(String name, {bool withRepo = false}) {
    final className = toPascalCase(name);
    final repoImport = withRepo 
        ? "import '${GetXPathConfig.getRepositoryPath(name).replaceAll('lib/', '../')}';"
        : '';
    final repoField = withRepo 
        ? '  final ${className}Repository _repository = Get.find(tag: (${className}Repository).toString());\n'
        : '';
    
    return '''
import 'package:get/get.dart';
$repoImport

class ${className}Controller extends GetxController {
$repoField  // TODO: Implement ${className}Controller
  
  @override
  void onInit() {
    super.onInit();
    // Initialize controller
  }
  
  @override
  void onReady() {
    super.onReady();
    // Called after the widget is rendered on screen
  }
  
  @override
  void onClose() {
    super.onClose();
    // Called just before the controller is deleted
  }
}
''';
  }

  @override
  String viewTemplate(String name) {
    final className = toPascalCase(name);
    final displayName = className.replaceAll('_', ' ');
    
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '${name}_controller.dart';

class ${className}Screen extends StatelessWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(${className}Controller());
    return Scaffold(
      appBar: AppBar(
        title: Text('$displayName'),
      ),
      body: const Center(
        child: Text('$displayName Screen is working'),
      ),
    );
  }
}
''';
  }

  @override
  String modelTemplate(String name) {
    final className = toPascalCase(name);
    
    return '''
class ${className}Model {
  final int id;
  final String name;

  ${className}Model({
    required this.id,
    required this.name,
  });

  factory ${className}Model.fromJson(Map<String, dynamic> json) {
    return ${className}Model(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  ${className}Model copyWith({
    int? id,
    String? name,
  }) {
    return ${className}Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
''';
  }

  @override
  String repoTemplate(String name) {
    final className = toPascalCase(name);
    final modelImport = GetXPathConfig.getModelPath(name).replaceAll('lib/', '../');
    
    return '''
import '$modelImport';
import '../../network/api_service.dart';

abstract class ${className}Repository {
  Future<${className}Model> fetchData();
}

class ${className}RepositoryImpl implements ${className}Repository {
  final ApiService apiService;
  
  ${className}RepositoryImpl({required this.apiService});

  @override
  Future<${className}Model> fetchData() async {
    // TODO: Replace with actual API/DB call
    await Future.delayed(const Duration(seconds: 1));
    return ${className}Model(
      id: 1,
      name: '${toPascalCase(name.replaceAll('_', ' '))} example',
    );
  }
}
''';
  }
}

