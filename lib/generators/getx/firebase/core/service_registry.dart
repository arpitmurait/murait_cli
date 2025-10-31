import '../services/firebase_service_handler.dart';
import '../services/analytics_handler.dart';
import '../services/auth_handler.dart';
import '../services/messaging_handler.dart';
import '../services/ads_handler.dart';
import '../../../utils.dart';

/// Registry for Firebase service handlers
class FirebaseServiceRegistry {
  static final FirebaseServiceRegistry _instance = FirebaseServiceRegistry._internal();
  factory FirebaseServiceRegistry() => _instance;
  FirebaseServiceRegistry._internal();

  final Map<String, FirebaseServiceHandler> _handlers = {};

  /// Initialize default service handlers
  void initializeDefaults() {
    _handlers[FirebaseServiceType.analytics] = AnalyticsHandler();
    _handlers[FirebaseServiceType.auth] = AuthHandler();
    _handlers[FirebaseServiceType.messaging] = MessagingHandler();
    _handlers[FirebaseServiceType.ads] = AdsHandler();
    // Core, crashlytics, firestore don't need special handlers
  }

  /// Get handler for a service type
  FirebaseServiceHandler? getHandler(String serviceType) {
    return _handlers[serviceType];
  }

  /// Register a custom handler
  void registerHandler(FirebaseServiceHandler handler) {
    _handlers[handler.serviceType] = handler;
  }

  /// Get all handlers for given services
  List<FirebaseServiceHandler> getHandlersForServices(List<String> services) {
    return services
        .map((service) => getHandler(service))
        .whereType<FirebaseServiceHandler>()
        .toList();
  }
}

