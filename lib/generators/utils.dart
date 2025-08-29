class FirebaseServiceType {
  static String core = 'core';
  static String auth = 'auth';
  static String firestore = 'firestore';
  static String messaging = 'messaging';
  static String analytics = 'analytics';
  static String crashlytics = 'crashlytics';
}

/// Capitalizes the first letter of a string.
/// Example: "home" -> "Home"
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Converts a snake_case or kebab-case string to PascalCase.
/// Example: "user_profile" -> "UserProfile"
/// Example: "user-profile" -> "UserProfile"
String toPascalCase(String text) {
  return text
      .split(RegExp(r'[_\-]'))
      .map((word) => capitalize(word))
      .join();
}

/// Converts a string to snake_case.
/// Example: "UserProfile" -> "user_profile"
String toSnakeCase(String text) {
  final regex = RegExp(r'(?<=[a-z])[A-Z]');
  return text.replaceAllMapped(regex, (match) => '_${match.group(0)}').toLowerCase();
}

/// Converts a string to kebab-case.
/// Example: "UserProfile" -> "user-profile"
String toKebabCase(String text) {
  final regex = RegExp(r'(?<=[a-z])[A-Z]');
  return text.replaceAllMapped(regex, (match) => '-${match.group(0)}').toLowerCase();
}

/// Ensures safe class name generation (removes invalid characters).
String sanitizeClassName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  return capitalize(cleaned);
}
