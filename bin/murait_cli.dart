import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:murait_cli/generators/getx/firebase_commands.dart';
import 'package:murait_cli/generators/getx/firebase_generator.dart';
import 'package:murait_cli/generators/getx/getx_generator.dart';
import 'package:murait_cli/generators/bloc_generator.dart';
import 'package:murait_cli/generators/getx/project_creator.dart';

void main(List<String> arguments) {
  final parser = ArgParser();

  parser.addCommand('make:getx')
    ..addFlag('with-model', negatable: false)
    ..addFlag('with-repo', negatable: false);

  parser.addCommand('create:getx');

  parser.addCommand('make:bloc')
    ..addFlag('with-model', negatable: false)
    ..addFlag('with-repo', negatable: false);

  parser.addCommand('make:firebase')
    ..addFlag('with-model', negatable: false)
    ..addFlag('with-repo', negatable: false);

  final results = parser.parse(arguments);

  switch (results.command?.name) {
    case 'create:getx':
      final feature = results.command?.rest.first;
      if (feature == null) {
        print('❌ Please provide a feature name');
        return;
      }
      ProjectGenerator().createProject(feature,);
      break;

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

  final runner = CommandRunner<void>(
    'murait_cli', // <-- CHANGE THIS to your CLI's name
    'A CLI for bootstrapping Flutter projects with useful features.',
  );

  try {

    // 2. Register your top-level command.
    //    This is the key step. You are "adding" your FirebaseCommand to the runner.
    //    The runner now knows about 'firebase' and all its subcommands.
    runner.addCommand(FirebaseCommand());
    runner.run(arguments);
  } on UsageException catch (e) {
    // This is how the args package signals a command was used incorrectly.
    print(e);
    // The exit code 64 indicates a command line usage error.
  } catch (e) {
    // Handle any other generic errors.
    print('An unexpected error occurred: $e');
  }
}
