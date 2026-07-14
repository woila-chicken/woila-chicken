import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'eleveur_controller.dart';

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
  // Attendre que EleveurController ait chargé la ferme
  final eleveurCtrl = Get.find<EleveurController>();

  // Si déjà chargé, utiliser directement
  if (!eleveurCtrl.isLoadingFarm.value &&
      eleveurCtrl.farmId.value != null) {
    farmId.value = eleveurCtrl.farmId.value;
    farmName = eleveurCtrl.farmName.value;
    _listenStock();
    isLoading.value = false;
    return;
  }

  // Sinon attendre
  ever(eleveurCtrl.farmId, (id) {
    if (id != null && farmId.value == null) {
      farmId.value = id;
      farmName = eleveurCtrl.farmName.value;
      _listenStock();
      isLoading.value = false;
    }
  });

  // Cas où isLoadingFarm devient false mais farmId est null
  ever(eleveurCtrl.isLoadingFarm, (loading) {
    if (!loading && eleveurCtrl.farmId.value == null) {
      isLoading.value = false;
    }
  });
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
        'weightKg': (d['weightKg'] as num?)?.toDouble() ?? 0,
        'priceFcfa': (d['priceFcfa'] as num?)?.toDouble() ?? 0,
        'quantity': (d['quantity'] as num?)?.toInt() ?? 0,
        'isCertified': d['hasSanitaryCert'] as bool? ?? false,
        'photoUrl': d['photoUrl'] as String? ?? '',
        'deliveryAvailable':
            d['deliveryAvailable'] as bool? ?? true,
        'pickupAvailable': d['pickupAvailable'] as bool? ?? true,
        'description': d['description'] as String? ?? '',
      };
    }).toList();
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
      'description': description ?? '',
      if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
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
