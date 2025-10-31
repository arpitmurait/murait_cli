import 'core/pubspec_manager.dart';
import 'core/main_file_updater.dart';
import 'core/service_registry.dart';
import 'services/firebase_service_handler.dart';
import '../../utils.dart';

/// Main Firebase generator with modular architecture
class FirebaseGenerator {
  final FirebasePubspecManager _pubspecManager;
  final FirebaseMainFileUpdater _mainUpdater;
  final FirebaseServiceRegistry _serviceRegistry;

  FirebaseGenerator({
    FirebasePubspecManager? pubspecManager,
    FirebaseMainFileUpdater? mainUpdater,
    FirebaseServiceRegistry? serviceRegistry,
  })  : _pubspecManager = pubspecManager ?? FirebasePubspecManager(),
        _mainUpdater = mainUpdater ?? FirebaseMainFileUpdater(),
        _serviceRegistry = serviceRegistry ?? FirebaseServiceRegistry() {
    if (serviceRegistry == null) {
      _serviceRegistry.initializeDefaults();
    }
  }

  /// Add Firebase services to the project
  Future<void> addServices(List<String> services) async {
    // Validate services
    final validServices = _validateServices(services);
    if (validServices.isEmpty) {
      print('❌ No valid Firebase services provided.');
      return;
    }

    print('🚀 Setting up Firebase services: ${validServices.join(', ')}...\n');

    // 1. Update pubspec.yaml
    await _pubspecManager.updatePubspec(validServices);

    // 2. Update main.dart
    await _mainUpdater.updateMain(validServices);

    // 3. Setup service-specific handlers
    final handlers = _serviceRegistry.getHandlersForServices(validServices);
    for (final handler in handlers) {
      try {
        await handler.setup();
      } catch (e) {
        print('⚠️ Warning: Failed to setup ${handler.serviceType}: $e');
      }
    }

    // 4. Show completion message
    _printCompletionMessage();
  }

  /// Validate service types
  List<String> _validateServices(List<String> services) {
    final validTypes = {
      FirebaseServiceType.core,
      FirebaseServiceType.auth,
      FirebaseServiceType.firestore,
      FirebaseServiceType.messaging,
      FirebaseServiceType.analytics,
      FirebaseServiceType.crashlytics,
      FirebaseServiceType.ads,
    };

    return services.where((service) => validTypes.contains(service)).toList();
  }

  /// Print completion message with next steps
  void _printCompletionMessage() {
    print('\n✅ Firebase setup complete!');
    print('------------------------------------------');
    print('🔴 IMPORTANT NEXT STEPS:');
    print('1. Run `flutter pub get` in your project terminal.');
    print('2. Configure your project with the FlutterFire CLI.');
    print('   - If you don\'t have it, run: `dart pub global activate flutterfire_cli`');
    print('   - Then run: `flutterfire configure`');
    print('   - Follow the prompts to connect to your Firebase project.');
    print('------------------------------------------');
  }

  /// Register a custom service handler
  void registerHandler(FirebaseServiceHandler handler) {
    _serviceRegistry.registerHandler(handler);
  }
}

