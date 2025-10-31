import 'dart:io';
import 'package:args/command_runner.dart';

import 'getx_generator.dart';
import 'project_creator.dart';
import 'util_generator.dart';
import 'firebase_commands.dart';

class AddCommand extends Command<void> {
  @override
  final name = 'add';
  @override
  final description = 'Adds a new feature or component to your project.';

  AddCommand() {
    addSubcommand(ShareAppCommand());
    addSubcommand(AddScreenCommand());
    addSubcommand(AddModelCommand());
    addSubcommand(AddRepositoryCommand());
    addSubcommand(FirebaseCommand());
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
        help: 'Creates the screen with a corresponding repository.');
    argParser.addFlag('with-model',
        abbr: 'm',
        negatable: false,
        help: 'Creates the screen with a corresponding model.');
  }

  @override
  void run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Screen name must be specified.', usage);
    }

    final screenName = argResults!.rest.first;
    final withRepo = argResults!['with-repo'] as bool;
    final withModel = argResults!['with-model'] as bool;

    await GetXGenerator().createFeature(
      screenName,
      withModel: withModel,
      withRepo: withRepo,
    );

    print('✅ Created screen "$screenName" successfully.');
    if (withModel || withRepo) {
      final parts = <String>[];
      if (withModel) parts.add('model');
      if (withRepo) parts.add('repository');
      print('   → ${parts.join(' and ')} also created.');
    }
  }
}

class ShareAppCommand extends Command<void> {
  @override
  final name = 'share';
  @override
  final description = 'Adds a share app functionality.';

  @override
  void run() {
    UtilGenerator().addShareFeature();
  }
}

class AddModelCommand extends Command<void> {
  @override
  final name = 'model';
  @override
  final description = 'Adds a new model file.';

  @override
  void run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Model name must be specified.', usage);
    }
    final name = argResults!.rest.first;
    await GetXGenerator().createModel(name);
  }
}

class AddRepositoryCommand extends Command<void> {
  @override
  final name = 'repository';
  @override
  final description = 'Adds a new repository file.';

  @override
  void run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Repository name must be specified.', usage);
    }
    final name = argResults!.rest.first;
    await GetXGenerator().createRepository(name);
  }
}

class CreateCommand extends Command<void> {
  @override
  final name = 'create';
  @override
  final description = 'Creates a new Flutter project from the Murait boilerplate.';

  @override
  void run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Project name must be specified.', usage);
    }
    final projectName = argResults!.rest.first;
    await ProjectGenerator().createProject(projectName);
    exit(0);
  }
}
