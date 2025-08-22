import 'package:args/args.dart';
import 'package:murait_cli/generators/getx_generator.dart';
import 'package:murait_cli/generators/bloc_generator.dart';

void main(List<String> arguments) {
  final parser = ArgParser();

  parser.addCommand('make:getx')
    ..addFlag('with-model', negatable: false)
    ..addFlag('with-repo', negatable: false);

  parser.addCommand('make:bloc')
    ..addFlag('with-model', negatable: false)
    ..addFlag('with-repo', negatable: false);

  final results = parser.parse(arguments);

  switch (results.command?.name) {
    case 'make:getx':
      final feature = results.command?.rest.first;
      if (feature == null) {
        print('❌ Please provide a feature name');
        return;
      }
      GetXGenerator().createFeature(
        feature,
        withModel: results.command!['with-model'],
        withRepo: results.command!['with-repo'],
      );
      break;

    case 'make:bloc':
      final feature = results.command?.rest.first;
      if (feature == null) {
        print('❌ Please provide a feature name');
        return;
      }
      BlocGenerator().createBloc(
        feature,
        withModel: results.command!['with-model'],
        withRepo: results.command!['with-repo'],
      );
      break;

    default:
      print('''
Usage:
  murait_cli make:getx <feature> [--with-model] [--with-repo]
  murait_cli make:bloc <feature> [--with-model] [--with-repo]
''');
  }
}
