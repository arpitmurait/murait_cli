import 'package:args/command_runner.dart';
import '../utils.dart';
import 'firebase/firebase_generator.dart';

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
    addSubcommand(FirebaseAdsCommand());
  }
}

/// Base class for Firebase service commands
abstract class BaseFirebaseCommand extends Command<void> {
  final List<String> services;

  BaseFirebaseCommand(this.services);

  @override
  void run() async {
    await FirebaseGenerator().addServices(services);
  }
}

// --- Subcommands for "firebase" ---

class FirebaseCoreCommand extends BaseFirebaseCommand {
  FirebaseCoreCommand() : super([FirebaseServiceType.core]);

  @override
  String get name => FirebaseServiceType.core;
  @override
  String get description => 'Adds core Firebase service.';
}

class FirebaseAllCommand extends BaseFirebaseCommand {
  FirebaseAllCommand() : super([
    FirebaseServiceType.core,
    FirebaseServiceType.auth,
    FirebaseServiceType.analytics,
    FirebaseServiceType.messaging,
    FirebaseServiceType.crashlytics,
  ]);

  @override
  String get name => 'all';
  @override
  String get description => 'Adds core Firebase services (Auth, Firestore, analytics, notification, crashlytics).';
}

class FirebaseAuthCommand extends BaseFirebaseCommand {
  FirebaseAuthCommand() : super([FirebaseServiceType.auth]);

  @override
  String get name => FirebaseServiceType.auth;
  @override
  String get description => 'Adds Firebase Authentication.';
}

class FirebaseNotificationsCommand extends BaseFirebaseCommand {
  FirebaseNotificationsCommand() : super([FirebaseServiceType.messaging]);

  @override
  String get name => FirebaseServiceType.messaging;
  @override
  String get description => 'Adds Firebase Cloud Messaging for notifications.';
}

class FirebaseAnalyticsCommand extends BaseFirebaseCommand {
  FirebaseAnalyticsCommand() : super([FirebaseServiceType.analytics]);

  @override
  String get name => FirebaseServiceType.analytics;
  @override
  String get description => 'Adds Firebase Analytics.';
}

class FirebaseCrashlyticsCommand extends BaseFirebaseCommand {
  FirebaseCrashlyticsCommand() : super([FirebaseServiceType.crashlytics]);

  @override
  String get name => FirebaseServiceType.crashlytics;
  @override
  String get description => 'Adds Firebase Crashlytics.';
}

class FirebaseAdsCommand extends BaseFirebaseCommand {
  FirebaseAdsCommand() : super([FirebaseServiceType.ads]);

  @override
  String get name => FirebaseServiceType.ads;
  @override
  String get description => 'Adds Firebase Ads.';
}

