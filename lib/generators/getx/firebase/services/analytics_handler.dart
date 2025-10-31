import 'dart:io';
import 'firebase_service_handler.dart';

/// Handles Firebase Analytics setup
class AnalyticsHandler implements FirebaseServiceHandler {
  @override
  String get serviceType => 'analytics';

  @override
  Future<void> setup() async {
    await _injectAnalyticsIntoRoutes();
  }

  @override
  Future<bool> isConfigured() async {
    final appPagesFile = File('lib/routes/app_pages.dart');
    if (!await appPagesFile.exists()) return false;
    
    final content = await appPagesFile.readAsString();
    return content.contains('registerAnalyticsEvent') &&
           content.contains('firebase_analytics');
  }

  Future<void> _injectAnalyticsIntoRoutes() async {
    final appPagesFile = File('lib/routes/app_pages.dart');
    if (!await appPagesFile.exists()) {
      print('⚠️ Warning: lib/routes/app_pages.dart not found. Could not inject analytics.');
      return;
    }
    print('   -> Injecting Analytics into app routes...');

    var lines = await appPagesFile.readAsLines();

    const analyticsImport = "import 'package:firebase_analytics/firebase_analytics.dart';";
    const helperFunction = '''
void registerAnalyticsEvent({required String name}) {
  FirebaseAnalytics.instance.logEvent(name: name.replaceAll('/', ''), parameters: {'time': '\${DateTime.now()}'});
}
''';

    // Add import
    if (!lines.any((line) => line.contains(analyticsImport))) {
      int insertIndex = lines.indexWhere((line) => line.trim().startsWith('part '));
      if (insertIndex == -1) {
        insertIndex = lines.indexWhere((line) => line.trim().startsWith('class '));
      }
      if (insertIndex == -1) {
        insertIndex = 1;
      }
      lines.insert(insertIndex, analyticsImport);
    }

    // Add helper function
    if (!lines.any((line) => line.contains('void registerAnalyticsEvent'))) {
      final classDefIndex = lines.indexWhere((line) => line.contains('class AppPages {'));
      if (classDefIndex != -1) {
        lines.insert(classDefIndex, '\n$helperFunction');
      }
    }

    var content = lines.join('\n');

    // Update routes with analytics
    final pageRegex = RegExp(
      r'(name:\s*(AppRoutes\.[a-zA-Z_]+),[\s\n\r]*page:\s*\(\)\s*=>\s*([a-zA-Z0-9_<>]+)\(\))',
      multiLine: true,
    );

    if (pageRegex.hasMatch(content)) {
      content = content.replaceAllMapped(pageRegex, (match) {
        final routeName = match.group(2);
        final widgetName = match.group(3);
        if (routeName == null || widgetName == null) {
          return match.group(0)!;
        }
        return '''name: $routeName,
      page: () {
        registerAnalyticsEvent(name: $routeName);
        return $widgetName();
      }''';
      });
      await appPagesFile.writeAsString(content);
      print('   -> Successfully injected analytics logging into GetPage routes.');
    } else {
      await appPagesFile.writeAsString(content);
      print('   -> No routes to update, or they are already configured for analytics.');
    }
  }
}

