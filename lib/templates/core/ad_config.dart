import 'package:firebase_remote_config/firebase_remote_config.dart';

class AdConfig {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  /// 🔹 Helper to safely get string
  static String _get(String key, String fallback) {
    final value = _remoteConfig.getString("demo_$key");
    return value.isNotEmpty ? value : fallback;
  }

  // 🔹 AdMob IDs (from Remote Config group "dp_creator")
  static String get appId =>
      _get("ad_app_id", "ca-app-pub-3940256099942544~3347511713");

  static String get openAdId =>
      _get("open_ad_id", "ca-app-pub-3940256099942544/3419835294");

  static String get bannerAdId =>
      _get("banner_ad_id", "ca-app-pub-3940256099942544/6300978111");

  static String get interstitialAdId =>
      _get("interstitial_ad_id", "ca-app-pub-3940256099942544/1033173712");

  static String get nativeAdId =>
      _get("native_ad_id", "ca-app-pub-3940256099942544/2247696110");
}
