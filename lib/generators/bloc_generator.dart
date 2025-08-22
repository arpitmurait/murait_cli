import 'dart:io';
import 'utils.dart';

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

class ${capitalize(name)}Bloc extends Bloc<${capitalize(name)}Event, ${capitalize(name)}State> {
  ${withRepo ? "final ${capitalize(name)}Repository repository;\n  ${capitalize(name)}Bloc(this.repository)" : "${capitalize(name)}Bloc()"}
      : super(${capitalize(name)}Initial()) {
    on<${capitalize(name)}Started>((event, emit) async {
      ${withRepo ? "final data = await repository.fetchData();\n      emit(${capitalize(name)}Loaded(data));" : "// TODO: Add event handling"}
    });
  }
}
''';

  String _eventTemplate(String name) => '''
abstract class ${capitalize(name)}Event {}

class ${capitalize(name)}Started extends ${capitalize(name)}Event {}
''';

  String _stateTemplate(String name) => '''
abstract class ${capitalize(name)}State {}

class ${capitalize(name)}Initial extends ${capitalize(name)}State {}

class ${capitalize(name)}Loaded extends ${capitalize(name)}State {
  final dynamic data;
  ${capitalize(name)}Loaded(this.data);
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
import '${name}_model.dart';

class ${capitalize(name)}Repository {
  Future<${capitalize(name)}Model> fetchData() async {
    // TODO: Replace with API/DB call
    await Future.delayed(const Duration(seconds: 1));
    return ${capitalize(name)}Model(id: 1, name: '${capitalize(name)} example');
  }
}
''';
}
