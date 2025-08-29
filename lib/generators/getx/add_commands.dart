import 'package:args/command_runner.dart';
import 'getx_generator.dart';

class AddCommand extends Command<void> {
  @override
  final name = 'add';
  @override
  final description = 'Add a new component (screen, model, repository).';

  final GetXGenerator _generator;

  AddCommand() : _generator = GetXGenerator() {
    addSubcommand(AddScreenCommand(_generator));
    addSubcommand(AddModelCommand(_generator));
    addSubcommand(AddRepositoryCommand(_generator));
  }
}

class AddScreenCommand extends Command<void> {
  final GetXGenerator _generator;

  @override
  final name = 'screen';
  @override
  final description = 'Add a new screen with a controller and widgets folder.';

  AddScreenCommand(this._generator) {
    argParser.addFlag('with-repo',
        abbr: 'r',
        negatable: false,
        help: 'Create a repository and model for the screen.');
  }

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      print('Please provide a name for the screen.');
      return;
    }
    final name = argResults!.rest.first.toLowerCase();
    final withRepo = argResults!['with-repo'] as bool;

    _generator.createFeature(name, withRepo: withRepo);
  }
}

class AddModelCommand extends Command<void> {
  final GetXGenerator _generator;

  @override
  final name = 'model';
  @override
  final description = 'Add a new data model.';

  AddModelCommand(this._generator);

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      print('Please provide a name for the model.');
      return;
    }
    final name = argResults!.rest.first.toLowerCase();
    _generator.createModel(name);
  }
}

class AddRepositoryCommand extends Command<void> {
  final GetXGenerator _generator;
  @override
  final name = 'repository';
  @override
  final description = 'Add a new data repository.';

  AddRepositoryCommand(this._generator);

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      print('Please provide a name for the repository.');
      return;
    }
    final name = argResults!.rest.first.toLowerCase();
    _generator.createRepository(name);
  }
}
