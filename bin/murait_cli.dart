import 'package:args/command_runner.dart';
import 'package:murait_cli/generators/getx/firebase_commands.dart';
import 'package:murait_cli/generators/getx/project_command.dart';

void main(List<String> arguments) {

  final runner = CommandRunner<void>(
    'murait_cli', // <-- CHANGE THIS to your CLI's name
    'A CLI for bootstrapping Flutter projects with useful features.',
  );

  try {
    // 2. Register your top-level command.
    //    This is the key step. You are "adding" your FirebaseCommand to the runner.
    //    The runner now knows about 'firebase' and all its subcommands.
    runner.addCommand(AddCommand());
    runner.addCommand(CreateCommand());
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
