import 'package:args/command_runner.dart';
import '../utils.dart';
import 'firebase_generator.dart';

class FirebaseCommand extends Command<void> {
  @override
  final name = 'firebase';
  @override
  final description = 'Adds and configures Firebase services to your project.';

  FirebaseCommand() {
    addSubcommand(FirebaseCoreCommand());
    addSubcommand(FirebaseAllCommand());
    addSubcommand(FirebaseAuthCommand());
    addSubcommand(FirebaseNotificationsCommand());
    addSubcommand(FirebaseAnalyticsCommand());
    addSubcommand(FirebaseCrashlyticsCommand());
  }
}

// --- Subcommands for "firebase" ---

class FirebaseCoreCommand extends Command<void> {
  @override
  final name = FirebaseServiceType.core;
  @override
  final description = 'Adds core Firebase service.';

  @override
  void run() {
    FirebaseGenerator().addServices([FirebaseServiceType.core]);
  }
}

class FirebaseAllCommand extends Command<void> {
  @override
  final name = 'all';
  @override
  final description = 'Adds core Firebase services (Auth, Firestore, analytics, notification , crashlytics).';

  @override
  void run() {
    FirebaseGenerator().addServices([FirebaseServiceType.core,FirebaseServiceType.auth, FirebaseServiceType.analytics, FirebaseServiceType.messaging, FirebaseServiceType.crashlytics]);
  }
}

class FirebaseAuthCommand extends Command<void> {
  @override
  final name = FirebaseServiceType.auth;
  @override
  final description = 'Adds Firebase Authentication.';

  @override
  void run() {
    FirebaseGenerator().addServices([FirebaseServiceType.auth]);
  }
}

class FirebaseNotificationsCommand extends Command<void> {
  @override
  final name = FirebaseServiceType.messaging;
  @override
  final description = 'Adds Firebase Cloud Messaging for notifications.';

  @override
  void run() {
    FirebaseGenerator().addServices([FirebaseServiceType.messaging]);
  }
}

class FirebaseAnalyticsCommand extends Command<void> {
  @override
  final name = FirebaseServiceType.analytics;
  @override
  final description = 'Adds Firebase Analytics.';

  @override
  void run() {
    FirebaseGenerator().addServices([FirebaseServiceType.analytics]);
  }
}

class FirebaseCrashlyticsCommand extends Command<void> {
  @override
  final name = FirebaseServiceType.crashlytics;
  @override
  final description = 'Adds Firebase Crashlytics.';

  @override
  void run() {
    FirebaseGenerator().addServices([FirebaseServiceType.crashlytics]);
  }
}

