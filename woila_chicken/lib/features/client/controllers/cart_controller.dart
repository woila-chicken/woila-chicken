import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_theme.dart';

class CartItem {
  final Product product;
  int quantity;
  bool wantsDelivery;

  CartItem({
    required this.product,
    required this.quantity,
    required this.wantsDelivery,
  });
}

class CartController extends GetxController {
  final items = <CartItem>[].obs;

  // ── Getters ───────────────────────────────────────────────────
  int get totalItems =>
      items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      items.fold(0, (sum, i) => sum + i.product.pricefcfa * i.quantity);

  double get deliveryFees =>
      items.fold(0, (sum, i) =>
          sum + (i.wantsDelivery ? 500 * i.quantity : 0));

  double get total => subtotal + deliveryFees;

  bool get isEmpty => items.isEmpty;

  // ── Actions ───────────────────────────────────────────────────
  void addProduct(Product product, {bool wantsDelivery = true}) {
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
    } else {
      items.add(CartItem(
        product: product,
        quantity: 1,
        wantsDelivery: wantsDelivery,
      ));
    }
    Get.snackbar(
      'Ajouté au panier ✓',
      '${product.name} — ${product.formattedPrice}',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void incrementQuantity(String productId) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
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
    }
  }

  void removeItem(String productId) {
    items.removeWhere((i) => i.product.id == productId);
  }

  void toggleDelivery(String productId, bool wantsDelivery) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx].wantsDelivery = wantsDelivery;
      items.refresh();
    }
  }

  void clear() => items.clear();

  String formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';
}