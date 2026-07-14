import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class EleveurController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();

  // Ferme
  final farmId = Rx<String?>(null);
  final farmName = ''.obs;
  final isVerified = false.obs;
  final rating = 0.0.obs;
  final totalRatings = 0.obs;
  final isLoadingFarm = true.obs;

  // Stats dashboard
  final productCount = 0.obs;
  final pendingOrderCount = 0.obs;
  final activeOrderCount = 0.obs;
  final monthRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    try {
      final farm = await _firestore.getFarmByOwner(_auth.uid);
      if (farm == null) {
        isLoadingFarm.value = false;
        return;
      }

      farmId.value = farm['id'];
      farmName.value = farm['name'] ?? '';
      isVerified.value = farm['isVerified'] as bool? ?? false;
      rating.value = (farm['rating'] as num?)?.toDouble() ?? 0;
      totalRatings.value = farm['totalRatings'] as int? ?? 0;
      isLoadingFarm.value = false;

      // Écouter les produits
      _listenProducts();
      // Écouter les commandes
      _listenOrders();
    } catch (e) {
      isLoadingFarm.value = false;
    }
  }

  void _listenProducts() {
    if (farmId.value == null) return;
    FirebaseFirestore.instance
        .collection('products')
        .where('farmId', isEqualTo: farmId.value)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      productCount.value = snap.docs.length;
    });
  }

  void _listenOrders() {
    if (farmId.value == null) return;
    FirebaseFirestore.instance
        .collection('orders')
        .where('farmId', isEqualTo: farmId.value)
        .snapshots()
        .listen((snap) {
      final orders = snap.docs.map((d) => d.data()).toList();

      pendingOrderCount.value = orders
          .where((o) => o['status'] == 'pending')
          .length;

      activeOrderCount.value = orders
          .where((o) => ['pending', 'confirmed', 'inRoute']
              .contains(o['status']))
          .length;

      // Revenus du mois en cours
      final now = DateTime.now();
      double revenue = 0;
      for (final o in orders) {
        if (o['status'] != 'completed') continue;
        try {
          final dt = (o['createdAt'] as Timestamp).toDate();
          if (dt.month == now.month && dt.year == now.year) {
            revenue += (o['total'] as num?)?.toDouble() ?? 0;
          }
        } catch (_) {}
      }
      monthRevenue.value = revenue;
    });
  }
}