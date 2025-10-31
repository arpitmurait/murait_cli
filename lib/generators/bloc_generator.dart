import 'dart:io';
import 'utils.dart' show toPascalCase;

class BlocGenerator {
  void createBloc(String name, {bool withModel = false, bool withRepo = false}) {
    final folder = Directory('lib/app/bloc/$name');
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    final files = {
      '${name}_bloc.dart': _blocTemplate(name, withRepo: withRepo),
      '${name}_event.dart': _eventTemplate(name),
      '${name}_state.dart': _stateTemplate(name),
    };

    if (withModel) {
      files['${name}_model.dart'] = _modelTemplate(name);
    }
    if (withRepo) {
      files['${name}_repository.dart'] = _repoTemplate(name);
    }

    files.forEach((fileName, content) {
      File('${folder.path}/$fileName')
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
      print('✅ Created lib/app/bloc/$name/$fileName');
    });
  }

  String _blocTemplate(String name, {bool withRepo = false}) => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';
${withRepo ? "import '${name}_repository.dart';" : ""}

class ${toPascalCase(name)}Bloc extends Bloc<${toPascalCase(name)}Event, ${toPascalCase(name)}State> {
  ${withRepo ? "final ${toPascalCase(name)}Repository repository;\n  ${toPascalCase(name)}Bloc(this.repository)" : "${toPascalCase(name)}Bloc()"}
      : super(${toPascalCase(name)}Initial()) {
    on<${toPascalCase(name)}Started>((event, emit) async {
      ${withRepo ? "final data = await repository.fetchData();\n      emit(${toPascalCase(name)}Loaded(data));" : "// TODO: Add event handling"}
    });
  }
}
''';

  String _eventTemplate(String name) => '''
abstract class ${toPascalCase(name)}Event {}

class ${toPascalCase(name)}Started extends ${toPascalCase(name)}Event {}
''';

  String _stateTemplate(String name) => '''
abstract class ${toPascalCase(name)}State {}

class ${toPascalCase(name)}Initial extends ${toPascalCase(name)}State {}

class ${toPascalCase(name)}Loaded extends ${toPascalCase(name)}State {
  final dynamic data;
  ${toPascalCase(name)}Loaded(this.data);
}
''';

  String _modelTemplate(String name) => '''
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

  String _repoTemplate(String name) => '''
import '${name}_model.dart';

class ${toPascalCase(name)}Repository {
  Future<${toPascalCase(name)}Model> fetchData() async {
    // TODO: Replace with API/DB call
    await Future.delayed(const Duration(seconds: 1));
    return ${toPascalCase(name)}Model(id: 1, name: '${toPascalCase(name.replaceAll('_', ' '))} example');
  }
}
''';
}
