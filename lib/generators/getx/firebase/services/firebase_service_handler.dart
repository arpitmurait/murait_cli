/// Interface for Firebase service handlers
abstract class FirebaseServiceHandler {
  /// Service type identifier
  String get serviceType;

  /// Setup this service (update files, copy templates, etc.)
  Future<void> setup();

  /// Check if service is already configured
  Future<bool> isConfigured();
}

