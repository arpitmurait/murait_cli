class FirebaseServiceType {
  static String core = 'core';
  static String auth = 'auth';
  static String firestore = 'firestore';
  static String messaging = 'messaging';
  static String analytics = 'analytics';
  static String crashlytics = 'crashlytics';
  static String ads = 'ads';
}

class PackageType {
  static String core = 'firebase_core: ^4.2.0';
  static String auth = 'firebase_auth: ^6.1.1';
  static String firestore = 'cloud_firestore: ^6.0.3';
  static String messaging = 'firebase_messaging: ^16.0.3';
  static String analytics = 'firebase_analytics: ^12.0.3';
  static String crashlytics = 'firebase_crashlytics: ^5.0.3';
  static String ads = 'flutter_native_ad:\n  git:\n    url: https://github.com/Khuntarpit/flutter_native_ad.git';
  static String googleSignIn = 'google_sign_in: ^7.2.0';
  static String appleSignIn = 'sign_in_with_apple: ^7.0.1';
  static String localNotifications = 'flutter_local_notifications: ^19.5.0';
  static String remoteConfig = 'firebase_remote_config: ^6.1.0';

  static String cupertinoIcons = 'cupertino_icons: ^1.0.8';
  static String intl = 'intl:';
  static String get = 'get: ^4.7.2';
  static String hiveFlutter = 'hive_flutter: ^2.0.0-dev';
  static String screenUtil = 'flutter_screenutil: ^5.9.3';
  static String cachedNetworkImage = 'cached_network_image: ^3.4.1';
  static String svg = 'flutter_svg: ^2.2.1';
  static String toast = 'fluttertoast: ^9.0.0';
  static String easyLoading = 'flutter_easyloading: ^3.0.5';
  static String connectivityPlus = 'connectivity_plus: ^7.0.0';
  static String dio = 'dio: ^5.9.0';
  static String animate = 'flutter_animate: ^4.5.2';
  static String alert = 'rflutter_alert: ^2.0.7';
  static String shimmer = 'h3m_shimmer_card: ^0.0.2';
  static String imageCropper = 'image_cropper: ^11.0.0';
  static String imagePicker = 'image_picker: ^1.2.0';
  static String logger = 'logger: ^2.6.2';
  static String upgrader = 'upgrader: ^12.2.0';
  static String lints = 'flutter_lints: ^6.0.0';
}

/// Capitalizes the first letter of a string.
/// Example: "home" -> "Home"
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Converts snake_case to PascalCase.
/// Example: "edit_profile" -> "EditProfile", "user_profile_screen" -> "UserProfileScreen"
String toPascalCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => capitalize(word))
      .join();
}

/// Converts snake_case to camelCase.
/// Example: "edit_profile" -> "editProfile", "user_profile_screen" -> "userProfileScreen"
String toCamelCase(String text) {
  if (text.isEmpty) return text;
  final words = text.split('_').where((word) => word.isNotEmpty).toList();
  if (words.isEmpty) return text;
  return words.first.toLowerCase() +
      words.skip(1).map((word) => capitalize(word)).join();
}

/// Converts snake_case to kebab-case.
/// Example: "edit_profile" -> "edit-profile", "user_profile_screen" -> "user-profile-screen"
String toKebabCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => word.toLowerCase())
      .join('-');
}