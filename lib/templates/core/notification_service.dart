import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart' as dio;

// --- Constants ---
const String _channelId = "primary_channel";
const String _channelName = "Primary Notifications";
const String _channelDescription = "This channel is used for important notifications.";

/// A top-level function to handle background messages.
/// This must be a top-level function (not a class method) to work.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using them.
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
  // You can process the message here if needed.
}

class NotificationService {
  // --- Singleton Setup ---
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // --- Plugin Instances ---
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  /// This should be called once, preferably in `main.dart`.
  Future<void> initialize() async {
    // 1. Request Permissions
    await _requestPermissions();

    // 2. Initialize Local Notifications
    await _initializeLocalNotifications();

    // 3. Initialize Firebase Listeners
    await _initializeFirebaseListeners();

    // 4. Get FCM Token
    final String? fcmToken = await _firebaseMessaging.getToken();
    log("FCM Token: $fcmToken");

    // Optional: Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Requests permissions for iOS and Android.
  Future<void> _requestPermissions() async {
    // iOS and web permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // iOS foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Initializes the local notifications plugin.
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      final AndroidNotificationChannel channel = const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
      );
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Sets up listeners for incoming Firebase messages.
  Future<void> _initializeFirebaseListeners() async {
    // 1. For messages received when the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received a message while in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // 2. For messages that open the app from a background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Message opened app from background: ${message.data}');
      _handleMessageTap(message.data);
    });

    // 3. For messages that open the app from a terminated state.
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('Message opened app from terminated: ${initialMessage.data}');
      _handleMessageTap(initialMessage.data);
    }
  }

  /// Callback for when a user taps on a local notification.
  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
      log('Local notification tapped with payload: ${notificationResponse.payload}');
      final Map<String, dynamic> data = json.decode(notificationResponse.payload!);
      _handleMessageTap(data);
    }
  }

  /// Displays a local notification.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final Map<String, dynamic> data = message.data;

    // Use notification data if available, otherwise fallback to data payload
    final String title = notification?.title ?? data['title'] ?? 'New Message';
    final String body = notification?.body ?? data['body'] ?? '';

    // Create platform-specific notification details
    final NotificationDetails platformChannelSpecifics = await _createNotificationDetails(notification);

    await _localNotificationsPlugin.show(
      notification.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: json.encode(data),
    );
  }

  /// Creates platform-specific NotificationDetails, handling images for Android.
  Future<NotificationDetails> _createNotificationDetails(RemoteNotification? notification) async {
    // Android-specific details
    final String? imageUrl = notification?.android?.imageUrl;
    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      final String base64Image = await _downloadAndEncodeImage(imageUrl);
      androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Image),
        styleInformation: BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(base64Image),
          hideExpandedLargeIcon: true,
        ),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
    }

    // iOS-specific details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Downloads an image from a URL and converts it to a base64 string.
  Future<String> _downloadAndEncodeImage(String url) async {
    try {
      final dio.Response response = await dio.Dio(dio.BaseOptions(responseType: dio.ResponseType.bytes)).get(url);
      return base64Encode(response.data);
    } catch (e) {
      log("Error downloading image: $e");
    }
    return '';
  }

  /// Central handler for notification taps from all states (foreground, background, terminated).
  void _handleMessageTap(Map<String, dynamic> data) {
    log("Handling notification tap with data: $data", name: "NotificationService");
    // Example: Check for a 'screen' key in the data and navigate.
    // if (data.containsKey('screen')) {
    //   final String screen = data['screen'];
    //   Get.toNamed(screen); // Example with GetX
    // }
  }
}