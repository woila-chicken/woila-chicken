import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/product.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'checkout_screen.dart';
import '../controllers/cart_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _wantsDelivery = true;
  int _quantity = 1;

  double get _deliveryFee => _wantsDelivery ? 500 : 0;
  double get _totalPrice =>
      (widget.product.pricefcfa + _deliveryFee) * _quantity;

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';

  @override
  void initState() {
    super.initState();
    // Si livraison non dispo, retrait par défaut
    if (!widget.product.deliveryAvailable) _wantsDelivery = false;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: _buildDesktop(context),
      mobile: _buildMobile(context),
    );
  }

  // ─── DESKTOP ────────────────────────────────────────────────
  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              Get.snackbar(
                'Ajouté aux favoris',
                '${widget.product.name} ajouté à vos favoris',
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                icon: const Icon(Icons.favorite, color: Colors.white),
                duration: const Duration(seconds: 2),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Get.snackbar(
                'Partager',
                '${widget.product.name} — ${widget.product.pricefcfa} · ${widget.product.farmName}',
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                icon: const Icon(Icons.share, color: Colors.white),
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne gauche — image + infos ferme
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _ProductImage(product: widget.product),
                      const SizedBox(height: 16),
                      _FarmCard(product: widget.product),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Colonne droite — détails + commande
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: _OrderPanel(
                      product: widget.product,
                      wantsDelivery: _wantsDelivery,
                      quantity: _quantity,
                      deliveryFee: _deliveryFee,
                      totalPrice: _totalPrice,
                      formatPrice: _formatPrice,
                      onDeliveryChanged: (v) =>
                          setState(() => _wantsDelivery = v),
                      onQuantityChanged: (v) => setState(() => _quantity = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── MOBILE ─────────────────────────────────────────────────
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.favorite_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProductImage(product: widget.product, height: 220),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _OrderPanel(
                    product: widget.product,
                    wantsDelivery: _wantsDelivery,
                    quantity: _quantity,
                    deliveryFee: _deliveryFee,
                    totalPrice: _totalPrice,
                    formatPrice: _formatPrice,
                    onDeliveryChanged: (v) =>
                        setState(() => _wantsDelivery = v),
                    onQuantityChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 16),
                  _FarmCard(product: widget.product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Image du produit
// ─────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final Product product;
  final double height;
  const _ProductImage({required this.product, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: product.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(product.imageUrl!,
                      fit: BoxFit.cover, width: double.infinity),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.set_meal_rounded,
      color: AppColors.primary, size: 80),
                      ),
                    ),
                  ),
                ),
        ),
        if (product.hasSanitaryCert)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Certifié',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Panneau de commande
// ─────────────────────────────────────────────────────────────────
class _OrderPanel extends StatelessWidget {
  final Product product;
  final bool wantsDelivery;
  final int quantity;
  final double deliveryFee;
  final double totalPrice;
  final String Function(double) formatPrice;
  final ValueChanged<bool> onDeliveryChanged;
  final ValueChanged<int> onQuantityChanged;

  const _OrderPanel({
    required this.product,
    required this.wantsDelivery,
    required this.quantity,
    required this.deliveryFee,
    required this.totalPrice,
    required this.formatPrice,
    required this.onDeliveryChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom + prix
        Text(
          '${product.name} — ${product.weightKg} kg',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          formatPrice(product.pricefcfa),
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primary),
        ),
        const SizedBox(height: 20),

        // Infos clés
        _InfoRow(
          icon: Icons.scale_outlined,
          label: 'Poids',
          value: '${product.weightKg} kg',
        ),
        _InfoRow(
  icon: Icons.verified_rounded,
  label: 'État sanitaire',
  value: product.hasSanitaryCert ? 'Certifié' : 'Non certifié',
  valueColor:
      product.hasSanitaryCert ? AppColors.success : AppColors.error,
),
        _InfoRow(
          icon: Icons.access_time_outlined,
          label: 'Disponibilité',
          value: product.availability,
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // Choix logistique
        Text('Mode de retrait', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            if (product.deliveryAvailable)
              Expanded(
                child: _LogisticOption(
                  icon: Icons.local_shipping_outlined,
                  label: 'Livraison à domicile',
                  sublabel: '+ 500 FCFA',
                  isSelected: wantsDelivery,
                  onTap: () => onDeliveryChanged(true),
                ),
              ),
            if (product.deliveryAvailable && product.pickupAvailable)
              const SizedBox(width: 12),
            if (product.pickupAvailable)
              Expanded(
                child: _LogisticOption(
                  icon: Icons.store_outlined,
                  label: 'Retrait à la ferme',
                  sublabel: 'Gratuit',
                  isSelected: !wantsDelivery,
                  onTap: () => onDeliveryChanged(false),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Quantité
        Text('Quantité', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onTap:
                  quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
            ),
            const SizedBox(width: 16),
            Text(
              '$quantity',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(width: 16),
            _QuantityButton(
              icon: Icons.add,
              onTap: () =>  product.stockQuantity > 0 &&
          quantity < product.stockQuantity
      ? onQuantityChanged(quantity + 1)
      : null,
            ),
          ],
        ),
        const SizedBox(height: 6),
Text(
  product.stockQuantity > 0
      ? '${product.stockQuantity} disponible${product.stockQuantity > 1 ? 's' : ''} en stock'
      : 'Rupture de stock',
  style: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    color: product.stockQuantity > 0
        ? AppColors.textSecondary
        : AppColors.error,
    fontWeight: product.stockQuantity == 0
        ? FontWeight.w600
        : FontWeight.normal,
  ),
),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // Récapitulatif prix
        _PriceRow(
            label: '${product.name} × $quantity',
            value: formatPrice(product.pricefcfa * quantity)),
        if (wantsDelivery && product.deliveryAvailable)
          _PriceRow(
              label: 'Frais de livraison', value: formatPrice(deliveryFee)),
        const Divider(height: 20),
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
              formatPrice(totalPrice),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Get.find<CartController>().addProduct(
        product,
        wantsDelivery: wantsDelivery,
      );
    },
    icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
    label: const Text('Ajouter au panier',
        style: TextStyle(fontFamily: 'Poppins')),
  ),
),
const SizedBox(height: 10),
        // Bouton commander
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
        // Option 1 — Commander directement
        product.stockQuantity == 0
      ? null
      : () =>
        Get.to(
          () => CheckoutScreen(
            product: product,
            quantity: quantity,
            wantsDelivery: wantsDelivery,
          ),
          transition: Transition.rightToLeft,
        );
      },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(product.stockQuantity == 0
      ? 'Rupture de stock'
      : 'Commander — ${formatPrice(totalPrice)}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Carte ferme
// ─────────────────────────────────────────────────────────────────
class _FarmCard extends StatelessWidget {
  final Product product;
  const _FarmCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
            child:
                const Center(child: Icon(Icons.agriculture_rounded,
    size: 22, color: Color(0xFF412402)),),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.farmName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.accent),
                    const SizedBox(width: 3),
                    Text(
                      '${product.farmRating} · Ferme vérifiée',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.snackbar(
                product.farmName,
                'Profil de la ferme — disponible après connexion Firebase',
                backgroundColor: AppColors.accent,
                colorText: const Color(0xFF412402),
                snackPosition: SnackPosition.BOTTOM,
                icon: const Icon(Icons.store, color: Color(0xFF412402)),
              );
            },
            child: const Text('Voir la ferme',
                style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets utilitaires ──────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _LogisticOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _LogisticOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary),
                textAlign: TextAlign.center),
            Text(sublabel,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.divider,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: onTap != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.divider),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }
}
