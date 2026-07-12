import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Product product;
  final int quantity;
  final double total;
  final bool wantsDelivery;
  final String orderRef;

  const OrderConfirmationScreen({
    super.key,
    required this.product,
    required this.quantity,
    required this.total,
    required this.wantsDelivery,
    required this.orderRef,
  });

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _buildContent(context),
          ),
        ),
        mobile: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Icône succès animée
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 44),
          ),
          const SizedBox(height: 20),

          const Text('Paiement confirmé !',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Votre commande a été transmise à ${product.farmName}',
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Référence commande
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              const Text('Référence commande',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text('#$orderRef',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 3)),
            ]),
          ),
          const SizedBox(height: 24),

          // Suivi de commande (timeline)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Suivi de commande',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                const _TimelineItem(
                  title: 'Paiement confirmé',
                  subtitle: 'Fonds en séquestre sécurisé',
                  color: AppColors.success,
                  isDone: true,
                  isLast: false,
                ),
                _TimelineItem(
                  title: 'Préparation en cours',
                  subtitle: '${product.farmName} prépare votre commande',
                  color: AppColors.accent,
                  isDone: true,
                  isLast: false,
                ),
                _TimelineItem(
                  title: wantsDelivery ? 'Livraison' : 'Prêt pour retrait',
                  subtitle: wantsDelivery
                      ? 'En attente de prise en charge par le livreur'
                      : 'Rendez-vous à la ferme',
                  color: AppColors.divider,
                  isDone: false,
                  isLast: false,
                ),
                const _TimelineItem(
                  title: 'Confirmation réception',
                  subtitle: 'Vous confirmez → l\'éleveur est payé',
                  color: AppColors.divider,
                  isDone: false,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Récap commande
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(children: [
              ProductImage(
  imageUrl: product.imageUrl,
  width: 56,
  height: 56,
),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${product.name} × $quantity',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(product.farmName,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(_formatPrice(total),
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 28),

          // Boutons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.to(
  () => OrderTrackingScreen(orderId: orderRef),
  transition: Transition.rightToLeft,
),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Suivre ma commande'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.clientHome),
              child: const Text('Retour à l\'accueil'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool isDone;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur + ligne
          Column(children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDone ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
              ),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppColors.textPrimary
                              : AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}