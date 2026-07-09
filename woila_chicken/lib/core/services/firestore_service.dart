import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/product.dart';

class FirestoreService extends GetxService {
  final _db = FirebaseFirestore.instance;

  // ── PRODUITS ──────────────────────────────────────────────────
  Stream<List<Product>> getProducts({String? farmId}) {
    Query query = _db
        .collection('products')
        .where('isActive', isEqualTo: true);

    if (farmId != null) {
      query = query.where('farmId', isEqualTo: farmId);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => _productFromDoc(doc)).toList());
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _db.collection('products').add({
      ...data,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.collection('products').doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db
        .collection('products')
        .doc(id)
        .update({'isActive': false});
  }

  // ── COMMANDES ─────────────────────────────────────────────────
  Future<String> createOrder(Map<String, dynamic> data) async {
  try {
    // Générer une ref simple sans count()
    final ref = 'WC-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final commission =
        ((data['total'] as num) * 0.02).roundToDouble();

    final doc = await _db.collection('orders').add({
      ...data,
      'ref': ref,
      'commission': commission,
      'status': 'pending',
      'paymentStatus': 'held',
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Commande créée : ${doc.id} — $ref');
    return doc.id;
  } catch (e) {
    debugPrint('Erreur createOrder: $e');
    rethrow;
  }
}

  Stream<List<Map<String, dynamic>>> getClientOrders(String clientId) {
    return _db
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getFarmOrders(String farmId) {
    return _db
        .collection('orders')
        .where('farmId', isEqualTo: farmId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final data = <String, dynamic>{'status': status};
    if (status == 'completed') data['paymentStatus'] = 'released';
    if (status == 'disputed') data['paymentStatus'] = 'refunded';
    await _db.collection('orders').doc(orderId).update(data);
  }

  // ── FERMES ────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getAllFarms() {
    return _db
        .collection('farms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<Map<String, dynamic>?> getFarmByOwner(String ownerId) async {
    final snap = await _db
        .collection('farms')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return {'id': snap.docs.first.id, ...snap.docs.first.data()};
  }

  Future<void> verifyFarm(String farmId) async {
    await _db
        .collection('farms')
        .doc(farmId)
        .update({'isVerified': true, 'isSuspended': false});
  }

  Future<void> suspendFarm(String farmId) async {
    await _db
        .collection('farms')
        .doc(farmId)
        .update({'isSuspended': true});
  }

  Future<void> updateFarm(
      String farmId, Map<String, dynamic> data) async {
    await _db.collection('farms').doc(farmId).update(data);
  }

  // ── LITIGES ───────────────────────────────────────────────────
  Future<void> createDispute(Map<String, dynamic> data) async {
    await _db.collection('disputes').add({
      ...data,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (data['orderId'] != null) {
      await updateOrderStatus(data['orderId'], 'disputed');
    }
  }

  Stream<List<Map<String, dynamic>>> getAllDisputes() {
    return _db
        .collection('disputes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> resolveDispute(String disputeId) async {
    await _db
        .collection('disputes')
        .doc(disputeId)
        .update({'status': 'resolved'});
  }

  // ── NOTES ─────────────────────────────────────────────────────
  Future<void> addRating({
    required String farmId,
    required String orderId,
    required String clientId,
    required int stars,
    required String comment,
  }) async {
    await _db.collection('ratings').add({
      'farmId': farmId,
      'orderId': orderId,
      'clientId': clientId,
      'stars': stars,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final ratings = await _db
        .collection('ratings')
        .where('farmId', isEqualTo: farmId)
        .get();

    if (ratings.docs.isNotEmpty) {
      final avg = ratings.docs
              .map((d) => (d.data()['stars'] as num).toDouble())
              .reduce((a, b) => a + b) /
          ratings.docs.length;

      await _db.collection('farms').doc(farmId).update({
        'rating': double.parse(avg.toStringAsFixed(1)),
        'totalRatings': ratings.docs.length,
      });
    }
  }

  // ── STATS ADMIN ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getAdminStats() async {
    final orders = await _db.collection('orders').get();
    final farms = await _db
        .collection('farms')
        .where('isVerified', isEqualTo: true)
        .get();
    final disputes = await _db
        .collection('disputes')
        .where('status', isEqualTo: 'open')
        .get();
    final pending = await _db
        .collection('farms')
        .where('isVerified', isEqualTo: false)
        .where('isSuspended', isEqualTo: false)
        .get();

    double totalCommission = 0;
    for (final doc in orders.docs) {
      final data = doc.data();
      if (data['paymentStatus'] == 'released') {
        totalCommission +=
            (data['commission'] as num?)?.toDouble() ?? 0;
      }
    }

    return {
      'totalOrders': orders.docs.length,
      'activeFarms': farms.docs.length,
      'openDisputes': disputes.docs.length,
      'pendingFarms': pending.docs.length,
      'totalCommission': totalCommission,
    };
  }

  // ── PARAMÈTRES ────────────────────────────────────────────────
  Stream<Map<String, dynamic>> getSettings() {
    return _db
        .collection('config')
        .doc('settings')
        .snapshots()
        .map((doc) =>
            doc.exists ? doc.data() ?? _defaultSettings : _defaultSettings);
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    await _db
        .collection('config')
        .doc('settings')
        .set(data, SetOptions(merge: true));
  }

  Future<bool> isMaintenanceMode() async {
    try {
      final doc = await _db
          .collection('config')
          .doc('settings')
          .get();
      return doc.data()?['maintenanceMode'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> purgeTestData() async {
    final cutoff = DateTime.now()
        .subtract(const Duration(hours: 24));
    final oldOrders = await _db
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .where('createdAt',
            isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = _db.batch();
    for (final doc in oldOrders.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static const _defaultSettings = {
    'commissionRate': 2,
    'deliveryFee': 500,
    'platformName': 'Woïla Chicken',
    'contactEmail': 'woila.chicken.cm@gmail.com',
    'contactPhone': '+237 6XX XXX XXX',
    'city': 'Garoua',
    'notifNewOrder': true,
    'notifNewFarm': true,
    'notifDispute': true,
    'allowNewRegistrations': true,
    'requireSanitaryCert': false,
    'maintenanceMode': false,
  };

  // ── HELPER CONVERSION PRODUIT ─────────────────────────────────
  Product _productFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    String toStr(dynamic v, [String fallback = '']) {
      if (v == null) return fallback;
      if (v is String) return v;
      return v.toString();
    }

    bool toBool(dynamic v, [bool fallback = false]) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) return v == 'true';
      return fallback;
    }

    final photoUrl = toStr(d['photoUrl']);
    final imageUrl = toStr(d['imageUrl']);

    return Product(
      id: doc.id,
      farmId: toStr(d['farmId']),
      name: toStr(d['name']),
      weightKg: toDouble(d['weightKg']),
      pricefcfa: toDouble(d['priceFcfa']),
      farmName: toStr(d['farmName']),
      farmRating: toDouble(d['farmRating']),
      hasSanitaryCert: toBool(d['hasSanitaryCert']),
      deliveryAvailable: toBool(d['deliveryAvailable'], true),
      pickupAvailable: toBool(d['pickupAvailable'], true),
      availability: toStr(d['availability'], 'immediate'),
      imageUrl: photoUrl.isNotEmpty ? photoUrl : imageUrl,
    );
  }
}