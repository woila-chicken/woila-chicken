import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb) {
      await _initMessaging();
    }
  }

  static Future<void> _initMessaging() async {
    // Demander la permission notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handler background
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Handler foreground — affiche un WoilaToast
    // quand l'app est ouverte et qu'un message arrive
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      if (title.isNotEmpty) {
        // WoilaToast sera appelé ici quand
        // Cloud Functions sera activé plus tard
        debugPrint('Notification reçue : $title — $body');
      }
    });

    // Handler quand l'utilisateur tape sur
    // une notification et que l'app était en background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification ouverte : ${message.notification?.title}');
      // Navigation selon le type de message
      // sera ajoutée avec Cloud Functions
    });
  }

  static Future<String?> getFcmToken() async {
    if (kIsWeb) return null;
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Erreur FCM token : $e');
      return null;
    }
  }
}