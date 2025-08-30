import 'package:args/command_runner.dart';

import 'getx_generator.dart';
import 'project_creator.dart';

class AddCommand extends Command<void> {
  @override
  final name = 'add';
  @override
  final description = 'Adds a new feature or component to your project.';

  AddCommand() {
    addSubcommand(AddScreenCommand());
    addSubcommand(AddModelCommand());
    addSubcommand(AddRepositoryCommand());
  }
}

// --- Subcommands for "add" ---

class AddScreenCommand extends Command<void> {
  @override
  final name = 'screen';
  @override
  final description = 'Adds a new screen (view, controller, widgets folder).';

  AddScreenCommand() {
    argParser.addFlag('with-repo',
        abbr: 'r',
        negatable: false,
        help: 'Creates the screen with a corresponding model and repository.');
  }

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Screen name must be specified.', usage);
    }
    final name = argResults!.rest.first;
    final withRepo = argResults!['with-repo'] as bool;
    GetXGenerator().createFeature(name, withModel: withRepo, withRepo: withRepo);
  }
}

class AddModelCommand extends Command<void> {
  @override
  final name = 'model';
  @override
  final description = 'Adds a new model file.';

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Model name must be specified.', usage);
    }
    final name = argResults!.rest.first;
    GetXGenerator().createFeature(name, withModel: true, withRepo: false);
    print('✅ Created lib/data/model/${name}_model.dart');
  }
}

class AddRepositoryCommand extends Command<void> {
  @override
  final name = 'repository';
  @override
  final description = 'Adds a new repository file.';

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Repository name must be specified.', usage);
    }
    final name = argResults!.rest.first;
    GetXGenerator().createFeature(name, withModel: false, withRepo: true);
    print('✅ Created lib/data/repository/${name}_repository.dart');
  }
}

class CreateCommand extends Command<void> {
  @override
  final name = 'create';
  @override
  final description = 'Creates a new Flutter project from the Murait boilerplate.';

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Project name must be specified.', usage);
    }
    final projectName = argResults!.rest.first;
    ProjectGenerator().createProject(projectName);
  }
}
