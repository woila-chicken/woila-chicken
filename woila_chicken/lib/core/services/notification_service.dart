import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final _db = FirebaseFirestore.instance;

  // Envoyer une notif à un utilisateur via son token FCM
  // En production → utiliser Firebase Cloud Functions
  Future<void> sendToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final doc =
          await _db.collection('users').doc(userId).get();
      final token = doc.data()?['fcmToken'] as String?;
      if (token == null) return;

      // Stocker la notif dans Firestore pour l'historique
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Notification error: $e');
      }
    }
  }

  // ── Notifs métier ─────────────────────────────────────────────

  Future<void> notifyNewOrder({
    required String farmOwnerId,
    required String orderRef,
    required String clientName,
  }) async {
    await sendToUser(
      userId: farmOwnerId,
      title: 'Nouvelle commande',
      body: '$clientName a passé la commande $orderRef',
      data: {'type': 'new_order', 'ref': orderRef},
    );
  }

  Future<void> notifyOrderConfirmed({
    required String clientId,
    required String orderRef,
    required String farmName,
  }) async {
    await sendToUser(
      userId: clientId,
      title: 'Commande confirmée',
      body: '$farmName a confirmé votre commande $orderRef',
      data: {'type': 'order_confirmed', 'ref': orderRef},
    );
  }

  Future<void> notifyOrderDelivered({
    required String clientId,
    required String orderRef,
  }) async {
    await sendToUser(
      userId: clientId,
      title: 'Commande livrée',
      body:
          'Votre commande $orderRef est arrivée. Confirmez la réception.',
      data: {'type': 'order_delivered', 'ref': orderRef},
    );
  }

  Future<void> notifyPaymentReleased({
    required String farmOwnerId,
    required String orderRef,
    required double amount,
  }) async {
    await sendToUser(
      userId: farmOwnerId,
      title: 'Paiement reçu',
      body:
          '${amount.toStringAsFixed(0)} FCFA virés pour la commande $orderRef',
      data: {'type': 'payment_released', 'ref': orderRef},
    );
  }

  Future<void> notifyNewDispute({
    required String adminId,
    required String orderRef,
    required String clientName,
  }) async {
    await sendToUser(
      userId: adminId,
      title: 'Nouveau litige',
      body: '$clientName a signalé un problème sur $orderRef',
      data: {'type': 'new_dispute', 'ref': orderRef},
    );
  }
}