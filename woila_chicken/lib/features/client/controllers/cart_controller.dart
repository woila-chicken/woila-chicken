import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/product.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/woila_toast.dart';

class CartItem {
  final Product product;
  int quantity;
  bool wantsDelivery;

  CartItem({
    required this.product,
    required this.quantity,
    required this.wantsDelivery,
  });

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'productFarmId': product.farmId,
        'productName': product.name,
        'productWeightKg': product.weightKg,
        'productPricefcfa': product.pricefcfa,
        'productFarmName': product.farmName,
        'productFarmRating': product.farmRating,
        'productHasSanitaryCert': product.hasSanitaryCert,
        'productDeliveryAvailable': product.deliveryAvailable,
        'productPickupAvailable': product.pickupAvailable,
        'productAvailability': product.availability,
        'productImageUrl': product.imageUrl ?? '',
        'quantity': quantity,
        'wantsDelivery': wantsDelivery,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        product: Product(
          id: j['productId'] ?? '',
          farmId: j['productFarmId'] ?? '',
          name: j['productName'] ?? '',
          weightKg: (j['productWeightKg'] as num?)?.toDouble() ?? 0,
          pricefcfa: (j['productPricefcfa'] as num?)?.toDouble() ?? 0,
          farmName: j['productFarmName'] ?? '',
          farmRating: (j['productFarmRating'] as num?)?.toDouble() ?? 0,
          hasSanitaryCert: j['productHasSanitaryCert'] as bool? ?? false,
          deliveryAvailable: j['productDeliveryAvailable'] as bool? ?? true,
          pickupAvailable: j['productPickupAvailable'] as bool? ?? true,
          availability: j['productAvailability'] as String? ?? 'immediate',
          imageUrl: j['productImageUrl'] as String?,
        ),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        wantsDelivery: j['wantsDelivery'] as bool? ?? true,
      );
}

class CartController extends GetxController {
  String get _key {
    final uid = Get.find<AuthService>().uid;
    return 'woila_cart_$uid';
  }

  final items = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  // ── Persistance ───────────────────────────────────────────────
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      items.value = list
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur chargement panier: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_key, raw);
    } catch (e) {
      debugPrint('Erreur sauvegarde panier: $e');
    }
  }

  // ── Getters ───────────────────────────────────────────────────
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      items.fold(0, (s, i) => s + i.product.pricefcfa * i.quantity);

  double get deliveryFees =>
      items.fold(0, (s, i) => s + (i.wantsDelivery ? 500 * i.quantity : 0));

  double get total => subtotal + deliveryFees;

  bool get isEmpty => items.isEmpty;

  // ── Actions ───────────────────────────────────────────────────
  void addProduct(Product product,
      {bool wantsDelivery = true, int quantity = 1}) {
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      items[idx].quantity += quantity;
      items.refresh();
    } else {
      items.add(CartItem(
        product: product,
        quantity: quantity,
        wantsDelivery: wantsDelivery,
      ));
    }
    _saveToStorage();
    WoilaToast.success(
      'Ajouté au panier',
      '${product.name} · ×$quantity — ${(product.pricefcfa * quantity).toInt()} FCFA',
    );
  }

  void incrementQuantity(String productId) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
      _saveToStorage();
    }
  }

  void decrementQuantity(String productId) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (items[idx].quantity > 1) {
        items[idx].quantity--;
      } else {
        items.removeAt(idx);
      }
      items.refresh();
      _saveToStorage();
    }
  }

  void removeItem(String productId) {
    items.removeWhere((i) => i.product.id == productId);
    _saveToStorage();
  }

  void toggleDelivery(String productId, bool wantsDelivery) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx].wantsDelivery = wantsDelivery;
      items.refresh();
      _saveToStorage();
    }
  }

  void clear() {
    items.clear();
    _saveToStorage();
  }

  String formatPrice(double p) => '${p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      )} FCFA';
}
