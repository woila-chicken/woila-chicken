import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../controllers/cart_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CartController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(
              'Panier (${ctrl.totalItems})',
            )),
        actions: [
          Obx(() => ctrl.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: () => _confirmClear(context, ctrl),
                  child: const Text('Vider',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 13)),
                )),
        ],
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildBody(context, ctrl, isDesktop: true),
          ),
        ),
        mobile: _buildBody(context, ctrl, isDesktop: false),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartController ctrl,
      {required bool isDesktop}) {
    return Obx(() {
      if (ctrl.isEmpty) return _buildEmpty(context);

      return isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Liste articles
                Expanded(
                  flex: 6,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: ctrl.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _CartItemCard(item: ctrl.items[i], ctrl: ctrl),
                  ),
                ),
                Container(width: 1, color: AppColors.divider),
                // Récapitulatif
                SizedBox(
                  width: 320,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _SummaryPanel(ctrl: ctrl),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _CartItemCard(item: ctrl.items[i], ctrl: ctrl),
                  ),
                ),
                _SummaryPanel(ctrl: ctrl, isMobile: true),
              ],
            );
    });
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Votre panier est vide',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Ajoutez des produits depuis le catalogue',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.search_outlined, size: 18),
            label: const Text('Voir le catalogue',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, CartController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider le panier ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Tous les articles seront supprimés.',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              ctrl.clear();
              Navigator.pop(context);
            },
            child: const Text('Vider',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Carte article du panier
// ─────────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController ctrl;
  const _CartItemCard({required this.item, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            // Image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.product.name} — ${item.product.weightKg} kg',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.product.farmName,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ctrl.formatPrice(item.product.pricefcfa),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Supprimer
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              onPressed: () =>
                  ctrl.removeItem(item.product.id),
            ),
          ]),
          const SizedBox(height: 12),

          // Mode livraison
          if (item.product.deliveryAvailable &&
              item.product.pickupAvailable)
            Row(children: [
              _ModeChip(
                label: '🚚 Livraison',
                isSelected: item.wantsDelivery,
                onTap: () => ctrl.toggleDelivery(
                    item.product.id, true),
              ),
              const SizedBox(width: 8),
              _ModeChip(
                label: '🏪 Retrait',
                isSelected: !item.wantsDelivery,
                onTap: () => ctrl.toggleDelivery(
                    item.product.id, false),
              ),
            ]),
          if (item.product.deliveryAvailable &&
              !item.product.pickupAvailable)
            const Row(children: [
  Icon(Icons.local_shipping_rounded,
      size: 14, color: AppColors.textSecondary),
  SizedBox(width: 5),
  Text('Livraison uniquement',style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary) ),
]),
            
          if (!item.product.deliveryAvailable)
            const Row(children: [
  Icon(Icons.storefront_rounded,
      size: 14, color: AppColors.textSecondary),
  SizedBox(width: 5),
  Text('Retrait à la ferme', style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary)),
]),
          

          const SizedBox(height: 12),

          // Quantité + sous-total
          Row(children: [
            // Sélecteur quantité
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _QtyBtn(
                  icon: Icons.remove,
                  onTap: () => ctrl.decrementQuantity(
                      item.product.id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add,
                  onTap: () => ctrl.incrementQuantity(
                      item.product.id),
                ),
              ]),
            ),
            const Spacer(),
            // Sous-total ligne
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                ctrl.formatPrice(
                    item.product.pricefcfa * item.quantity),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
              if (item.wantsDelivery &&
                  item.product.deliveryAvailable)
                Text(
                  '+ ${ctrl.formatPrice(500)} livraison',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary),
                ),
            ]),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Panneau récapitulatif
// ─────────────────────────────────────────────────────────────────
class _SummaryPanel extends StatelessWidget {
  final CartController ctrl;
  final bool isMobile;
  const _SummaryPanel({required this.ctrl, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.all(isMobile ? 16 : 0),
          decoration: isMobile
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4))
                  ],
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                const Text('Récapitulatif',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
              ],
              _SummaryRow(
                  label: 'Sous-total (${ctrl.totalItems} articles)',
                  value: ctrl.formatPrice(ctrl.subtotal)),
              const SizedBox(height: 8),
              _SummaryRow(
                  label: 'Frais de livraison',
                  value: ctrl.deliveryFees > 0
                      ? ctrl.formatPrice(ctrl.deliveryFees)
                      : 'Gratuit'),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text(
                    ctrl.formatPrice(ctrl.total),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Badge séquestre
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.shield_outlined,
                      color: AppColors.success, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé — libéré après réception',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.success),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => _goToCheckout(),
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  'Commander — ${ctrl.formatPrice(ctrl.total)}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ));
  }

  void _goToCheckout() {
    // Si plusieurs produits on prend le premier pour l'instant
    // Firebase permettra de gérer un checkout multi-articles
    final firstItem = ctrl.items.first;
    Get.to(
      () => CheckoutScreen(
        product: firstItem.product,
        quantity: firstItem.quantity,
        wantsDelivery: firstItem.wantsDelivery,
      ),
      transition: Transition.rightToLeft,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      label == 'Livraison'
          ? Icons.local_shipping_rounded
          : Icons.storefront_rounded,
      size: 14,
      color: isSelected ? AppColors.primary : AppColors.textSecondary,
    ),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary)),
  ],
),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}