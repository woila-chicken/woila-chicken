import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/product.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/woila_toast.dart';
import '../../../core/services/auth_service.dart';
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
  bool _isFavorite = false;
  bool _loadingFavorite = true;

  final _auth = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    if (!widget.product.deliveryAvailable) _wantsDelivery = false;
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.uid)
          .collection('favorites')
          .doc(widget.product.id)
          .get();
      if (!mounted) return;
      setState(() {
        _isFavorite = doc.exists;
        _loadingFavorite = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFavorite = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.uid)
        .collection('favorites')
        .doc(widget.product.id);

    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        await ref.set({
          'productId': widget.product.id,
          'name': widget.product.name,
          'priceFcfa': widget.product.pricefcfa,
          'farmName': widget.product.farmName,
          'imageUrl': widget.product.imageUrl ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        });
        WoilaToast.success(
            'Favori ajouté', '${widget.product.name} dans vos favoris');
      } else {
        await ref.delete();
        WoilaToast.info(
            'Favori retiré', '${widget.product.name} retiré des favoris');
      }
    } catch (_) {
      // Annuler si erreur
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
      WoilaToast.error('Erreur', 'Impossible de modifier les favoris');
    }
  }

  Future<void> _share() async {
    final text =
        '🐓 ${widget.product.name} — ${widget.product.pricefcfa.toInt()} FCFA\n'
        '📍 ${widget.product.farmName}\n'
        '⭐ ${widget.product.farmRating}/5\n\n'
        'Disponible sur Woïla Chicken 🇨🇲';

    // Sur mobile → partage natif
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Sur PC → copier dans le presse-papier
      await Clipboard.setData(ClipboardData(text: text));
      WoilaToast.info('Copié', 'Infos produit copiées dans le presse-papier');
    }
  }

  List<Widget> _appBarActions() => [
        _loadingFavorite
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
              )
            : IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: _isFavorite ? Colors.red : null,
                ),
                tooltip:
                    _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                onPressed: _toggleFavorite,
              ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Partager',
          onPressed: _share,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: _buildDesktop(context),
      mobile: _buildMobile(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: _appBarActions(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(children: [
                    _ProductImage(product: widget.product),
                    const SizedBox(height: 16),
                    _FarmCard(product: widget.product),
                    const SizedBox(height: 16),
                    _ProductRatings(productId: widget.product.id),
                  ]),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: _OrderPanel(product: widget.product),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: _appBarActions(),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _ProductImage(product: widget.product, height: 220),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _OrderPanel(product: widget.product),
              const SizedBox(height: 16),
              _FarmCard(product: widget.product),
              const SizedBox(height: 16),
              _ProductRatings(productId: widget.product.id),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Notes du produit
// ─────────────────────────────────────────────────────────────────
class _ProductRatings extends StatelessWidget {
  final String productId;
  const _ProductRatings({required this.productId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('product_ratings')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();

        double avg = 0;
        for (final d in docs) {
          avg += (d.data() as Map)['stars'] as int? ?? 0;
        }
        avg = avg / docs.length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Avis clients',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                const Icon(Icons.star_rounded,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 4),
                Text(avg.toStringAsFixed(1),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(' (${docs.length})',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 12),
              ...docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final stars = data['stars'] as int? ?? 0;
                final comment = data['comment'] as String? ?? '';
                final name = data['clientName'] as String? ?? 'Client';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(name,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < stars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 13,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ]),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(comment,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                      if (d != docs.last) const Divider(height: 16),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
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
          child: product.imageUrl != null &&
                  product.imageUrl!.isNotEmpty &&
                  product.imageUrl!.startsWith('http')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(product.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholder()),
                )
              : _placeholder(),
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

  Widget _placeholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 140,
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.set_meal_rounded,
              color: AppColors.primary, size: 80),
        ),
      ),
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

  String formatPrice(double p) => '${p.toStringAsFixed(0).replaceAllMapped(
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
        int stockQty = widget.product.stockQuantity;
        if (snap.hasData && snap.data!.exists) {
          final d = snap.data!.data() as Map<String, dynamic>;
          stockQty = (d['quantity'] as num?)?.toInt() ?? 0;
        }

        final double totalPrice = widget.product.pricefcfa * quantity +
            (wantsDelivery && widget.product.deliveryAvailable ? 500 : 0);

        final bool canOrder = stockQty > 0 && quantity <= stockQty;

        if (quantity > stockQty && stockQty > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => quantity = stockQty);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(formatPrice(widget.product.pricefcfa),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 6),
            // Poids
            Text(
                '${widget.product.weightKg.toString().replaceAll('.', ',')} kg',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // Stock indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stockQty == 0
                    ? AppColors.error.withValues(alpha: 0.08)
                    : stockQty <= 3
                        ? AppColors.warning.withValues(alpha: 0.08)
                        : AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
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
                              : AppColors.success),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Quantité
            if (stockQty > 0) ...[
              const Text('Quantité',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [
                SizedBox(
                  width: 180,
                  child: QuantityStepper(
                    value: quantity,
                    onChanged: (v) {
                      if (v <= stockQty) setState(() => quantity = v);
                    },
                    max: stockQty,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Max : $stockQty',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
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

            // Ajouter au panier
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: canOrder
                    ? () {
                        Get.find<CartController>().addProduct(
                          widget.product,
                          wantsDelivery: wantsDelivery,
                          quantity: quantity,
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: const Text('Ajouter au panier',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(height: 10),

            // Commander
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
                    padding: const EdgeInsets.symmetric(vertical: 14)),
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

            // Note du produit
            const SizedBox(height: 20),
            _RateProductButton(product: widget.product),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Bouton noter le produit
// ─────────────────────────────────────────────────────────────────
class _RateProductButton extends StatelessWidget {
  final Product product;
  const _RateProductButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('clientId', isEqualTo: auth.uid)
          .where('productId', isEqualTo: product.id)
          .where('status', isEqualTo: 'completed')
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        // Afficher uniquement si le client a commandé et reçu ce produit
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('product_ratings')
              .doc('${auth.uid}_${product.id}')
              .get(),
          builder: (context, ratingSnap) {
            final alreadyRated = ratingSnap.hasData && ratingSnap.data!.exists;

            if (alreadyRated) {
              final stars =
                  (ratingSnap.data!.data() as Map?)?['stars'] as int? ?? 0;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text('Vous avez noté ce produit : $stars/5',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ]),
              );
            }

            return OutlinedButton.icon(
              onPressed: () => _showRatingDialog(context, auth.uid),
              icon: const Icon(Icons.star_outline_rounded, size: 18),
              label: const Text('Noter ce produit',
                  style: TextStyle(fontFamily: 'Poppins')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, String clientId) {
    int selectedStars = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(children: [
            const Text('Noter ce produit',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(product.name,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setS(() => selectedStars = i + 1),
                  child: Icon(
                    i < selectedStars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accent,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Votre avis sur ce produit (optionnel)...'),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(
                      fontFamily: 'Poppins', color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final auth = Get.find<AuthService>();
                  // ID unique : uid_productId pour éviter les doublons
                  await FirebaseFirestore.instance
                      .collection('product_ratings')
                      .doc('${clientId}_${product.id}')
                      .set({
                    'productId': product.id,
                    'clientId': clientId,
                    'clientName':
                        auth.currentUser.value?.displayName ?? 'Client',
                    'stars': selectedStars,
                    'comment': commentCtrl.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  WoilaToast.success(
                    'Merci pour votre avis !',
                    '$selectedStars étoile${selectedStars > 1 ? 's' : ''} — ${product.name}',
                  );
                } catch (_) {
                  WoilaToast.error('Erreur', 'Impossible d\'envoyer la note');
                }
              },
              child: const Text('Envoyer',
                  style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
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
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
              color: AppColors.accent, shape: BoxShape.circle),
          child: const Center(
            child: Icon(Icons.agriculture_rounded,
                size: 22, color: Color(0xFF412402)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.farmName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.star, size: 14, color: AppColors.accent),
                const SizedBox(width: 3),
                Text(
                  '${product.farmRating} · Ferme partenaire',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widgets utilitaires conservés
// ─────────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(children: [
          Icon(icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? AppColors.primary : AppColors.textPrimary)),
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
