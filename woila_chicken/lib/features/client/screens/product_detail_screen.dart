import 'package:cloud_firestore/cloud_firestore.dart';
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
class _OrderPanel extends StatefulWidget {
  final Product product;
  const _OrderPanel({required this.product});

  @override
  State<_OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<_OrderPanel> {
  int quantity = 1;
  bool wantsDelivery = true;

  String formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .snapshots(),
      builder: (context, snap) {
        // Stock en temps réel depuis Firestore
        int stockQty = widget.product.stockQuantity;
        if (snap.hasData && snap.data!.exists) {
          final d = snap.data!.data() as Map<String, dynamic>;
          stockQty = (d['quantity'] as num?)?.toInt() ?? 0;
        }

        final double totalPrice =
            widget.product.pricefcfa * quantity +
                (wantsDelivery &&
                        widget.product.deliveryAvailable
                    ? 500
                    : 0);

        final bool canOrder =
            stockQty > 0 && quantity <= stockQty;

        // Corriger quantity si dépasse le stock
        if (quantity > stockQty && stockQty > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => quantity = stockQty);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom + prix
            Text(
              widget.product.name,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              formatPrice(widget.product.pricefcfa),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            // Stock indicator
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stockQty == 0
                    ? AppColors.error.withValues(alpha: 0.08)
                    : stockQty <= 3
                        ? AppColors.warning.withValues(alpha: 0.08)
                        : AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stockQty == 0
                        ? Icons.remove_circle_outline
                        : stockQty <= 3
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                    size: 14,
                    color: stockQty == 0
                        ? AppColors.error
                        : stockQty <= 3
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stockQty == 0
                        ? 'Rupture de stock'
                        : stockQty <= 3
                            ? 'Plus que $stockQty en stock !'
                            : '$stockQty disponibles',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: stockQty == 0
                          ? AppColors.error
                          : stockQty <= 3
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sélecteur quantité
            if (stockQty > 0) ...[
              const Text('Quantité',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded),
                      iconSize: 18,
                      color: quantity > 1
                          ? AppColors.primary
                          : AppColors.divider,
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$quantity',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      iconSize: 18,
                      color: quantity < stockQty
                          ? AppColors.primary
                          : AppColors.divider,
                      onPressed: quantity < stockQty
                          ? () => setState(() => quantity++)
                          : null,
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                Text(
                  'Max : $stockQty',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ]),
              const SizedBox(height: 16),
            ],

            // Mode livraison
            if (widget.product.deliveryAvailable ||
                widget.product.pickupAvailable) ...[
              const Text('Mode de retrait',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [
                if (widget.product.deliveryAvailable)
                  Expanded(
                    child: _ModeBtn(
                      icon: Icons.local_shipping_outlined,
                      label: 'Livraison',
                      sublabel: '+500 FCFA',
                      isSelected: wantsDelivery,
                      onTap: () => setState(() => wantsDelivery = true),
                    ),
                  ),
                if (widget.product.deliveryAvailable &&
                    widget.product.pickupAvailable)
                  const SizedBox(width: 10),
                if (widget.product.pickupAvailable)
                  Expanded(
                    child: _ModeBtn(
                      icon: Icons.storefront_outlined,
                      label: 'Retrait',
                      sublabel: 'Gratuit',
                      isSelected: !wantsDelivery,
                      onTap: () => setState(() => wantsDelivery = false),
                    ),
                  ),
              ]),
              const SizedBox(height: 20),
            ],

            // Bouton ajouter au panier
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: canOrder
                    ? () {
                        Get.find<CartController>().addProduct(
                          widget.product,
                          wantsDelivery: wantsDelivery,
                        );
                      }
                    : null,
                icon: const Icon(
                    Icons.add_shopping_cart_outlined, size: 18),
                label: const Text('Ajouter au panier',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(height: 10),

            // Bouton commander
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canOrder
                    ? () => Get.to(
                          () => CheckoutScreen(
                            product: widget.product,
                            quantity: quantity,
                            wantsDelivery: wantsDelivery,
                          ),
                          transition: Transition.rightToLeft,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  // Grisé automatiquement quand onPressed est null
                ),
                child: Text(
                  stockQty == 0
                      ? 'Rupture de stock'
                      : 'Commander — ${formatPrice(totalPrice)}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeBtn({
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(children: [
          Icon(icon,
              size: 18,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary)),
          Text(sublabel,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textSecondary)),
        ]),
      ),
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
