import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
}

class FirebaseService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifs = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      // Messaging et notifs locales — pas supporté sur Flutter Web
      await _initMessaging();
      await _initLocalNotifications();
    }
  }

  static Future<void> _initMessaging() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  static Future<void> _initLocalNotifications() async {
    const android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: android, iOS: ios);
    await _localNotifs.initialize(settings);
  }

  static Future<void> _showLocalNotification(
      RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const androidDetails = AndroidNotificationDetails(
      'woila_chicken',
      'Woïla Chicken',
      channelDescription: 'Notifications Woïla Chicken',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifs.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  static Future<String?> getFcmToken() async {
    if (kIsWeb) return null;
    return await _messaging.getToken();
  }
}