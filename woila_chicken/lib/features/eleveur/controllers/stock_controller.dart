import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class StockController extends GetxController {
  final _firestore = Get.find<FirestoreService>();
  final _auth = Get.find<AuthService>();

  final items = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final farmId = Rx<String?>(null);
  String farmName = '';

  @override
  void onInit() {
    super.onInit();
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    try {
      final farm =
          await _firestore.getFarmByOwner(_auth.uid);
      if (farm == null) {
        isLoading.value = false;
        return;
      }
      farmId.value = farm['id'] as String?;
      farmName = farm['name'] as String? ?? '';
      _listenStock();
    } catch (e) {
      debugPrint('Erreur StockController: $e');
      isLoading.value = false;
    }
  }

  void _listenStock() {
    if (farmId.value == null) return;
    FirebaseFirestore.instance
        .collection('products')
        .where('farmId', isEqualTo: farmId.value)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      items.value = snap.docs.map((doc) {
        final d = doc.data();
        return {
          'id': doc.id,
          'name': d['name'] ?? '',
          'weightKg':
              (d['weightKg'] as num?)?.toDouble() ?? 0,
          'priceFcfa':
              (d['priceFcfa'] as num?)?.toDouble() ?? 0,
          'quantity':
              (d['quantity'] as num?)?.toInt() ?? 0,
          'isCertified':
              d['hasSanitaryCert'] as bool? ?? false,
          'photoUrl': d['photoUrl'] as String? ?? '',
          'deliveryAvailable':
              d['deliveryAvailable'] as bool? ?? true,
          'pickupAvailable':
              d['pickupAvailable'] as bool? ?? true,
          'description':
              d['description'] as String? ?? '',
        };
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Erreur stream stock: $e');
      isLoading.value = false;
    });
  }

  Future<void> addOrUpdate({
    String? id,
    required String name,
    required double weightKg,
    required double priceFcfa,
    required int quantity,
    required bool isCertified,
    required bool deliveryAvailable,
    required bool pickupAvailable,
    String? description,
    String? photoUrl,
  }) async {
    final payload = {
      'farmId': farmId.value,
      'farmName': farmName,
      'name': name,
      'weightKg': weightKg,
      'priceFcfa': priceFcfa,
      'quantity': quantity,
      'hasSanitaryCert': isCertified,
      'deliveryAvailable': deliveryAvailable,
      'pickupAvailable': pickupAvailable,
      'availability': 'immediate',
      'farmRating': 0,
      'isActive': true,
      'description': description ?? '',
      if (photoUrl != null && photoUrl.isNotEmpty)
        'photoUrl': photoUrl,
    };
    if (id != null) {
      await _firestore.updateProduct(id, payload);
    } else {
      await _firestore.addProduct(payload);
    }
  }

  Future<void> deleteItem(String id) async {
    await _firestore.deleteProduct(id);
  }
}