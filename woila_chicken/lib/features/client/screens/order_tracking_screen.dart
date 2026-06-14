import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firestore_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _firestore = Get.find<FirestoreService>();

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(
              child: Text('Commande introuvable',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          final ref = data['ref'] ?? '';
          final productName = data['productName'] ?? '';
          final farmName = data['farmName'] ?? '';
          final farmId = data['farmId'] ?? '';
          final total = (data['total'] as num?)?.toDouble() ?? 0;
          final isDelivery = data['isDelivery'] as bool? ?? true;

          return ResponsiveLayout(
            desktop: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: _buildContent(context,
                    status: status, ref: ref, productName: productName,
                    farmName: farmName, farmId: farmId, total: total, isDelivery: isDelivery),
              ),
            ),
            mobile: _buildContent(context,
                status: status, ref: ref, productName: productName,
                farmName: farmName, farmId: farmId, total: total, isDelivery: isDelivery),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required String status,
    required String ref,
    required String productName,
    required String farmName,
    required String farmId,
    required double total,
    required bool isDelivery,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // ── Référence + statut global ──────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Text('Référence commande',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 4),
            Text('#$ref',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 3)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusGlobalLabel(status),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Résumé produit ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(productName,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(farmName,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(
                    isDelivery ? Icons.local_shipping_outlined : Icons.storefront_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDelivery ? 'Livraison à domicile' : 'Retrait ferme',
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                ]),
              ]),
            ),
            Text(_formatPrice(total),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Timeline de suivi ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Étapes de livraison',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _TrackingStep(
              title: 'Paiement confirmé',
              subtitle: 'Fonds sécurisés en séquestre',
              status: _stepStatus(status, 'pending'),
              isLast: false,
            ),
            _TrackingStep(
              title: 'Préparation en cours',
              subtitle: '$farmName prépare votre commande',
              status: _stepStatus(status, 'confirmed'),
              isLast: false,
            ),
            _TrackingStep(
              title: isDelivery ? 'En route' : 'Prêt pour retrait',
              subtitle: isDelivery ? 'Le livreur est en chemin' : 'Rendez-vous à la ferme',
              status: _stepStatus(status, 'inRoute'),
              isLast: false,
            ),
            _TrackingStep(
              title: isDelivery ? 'Livré' : 'Récupéré',
              subtitle: isDelivery ? 'Commande remise au client' : 'Commande retirée à la ferme',
              status: _stepStatus(status, 'delivered'),
              isLast: false,
            ),
            _TrackingStep(
              title: 'Réception confirmée',
              subtitle: 'Paiement libéré à l\'éleveur',
              status: _stepStatus(status, 'completed'),
              isLast: true,
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Bouton confirmation réception ────────────────────────
        if (status == 'delivered') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(children: [
              const Icon(Icons.inventory_outlined, color: AppColors.success, size: 32),
              const SizedBox(height: 10),
              const Text('Vous avez reçu votre commande ?',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text(
                'En confirmant, vous autorisez le paiement à l\'éleveur.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmReception(farmName),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Confirmer la réception',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDisputeDialog(context),
              icon: const Icon(Icons.report_outlined, size: 16, color: AppColors.error),
              label: const Text('Signaler un problème',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
            ),
          ),
        ],

        // ── Statut final ─────────────────────────────────────────
        if (status == 'completed') ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 40),
              const SizedBox(height: 10),
              const Text('Commande terminée !',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success)),
              const SizedBox(height: 6),
              const Text('Merci pour votre confiance. N\'oubliez pas de noter la ferme.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context, farmId, farmName),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Noter la ferme', style: TextStyle(fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent, foregroundColor: const Color(0xFF412402)),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.clientHome),
            child: const Text('Retour à l\'accueil'),
          ),
        ),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  _StepStatusType _stepStatus(String currentStatus, String step) {
    const order = ['pending', 'confirmed', 'inRoute', 'delivered', 'completed'];
    final currentIndex = order.indexOf(currentStatus);
    final stepIndex = order.indexOf(step);
    if (currentIndex > stepIndex) return _StepStatusType.done;
    if (currentIndex == stepIndex) return _StepStatusType.active;
    return _StepStatusType.pending;
  }

  String _statusGlobalLabel(String status) {
    switch (status) {
      case 'pending':   return 'Paiement confirmé';
      case 'confirmed': return 'En cours de préparation';
      case 'inRoute':   return 'En route vers vous';
      case 'delivered': return 'Livré — En attente de confirmation';
      case 'completed': return 'Commande terminée';
      case 'disputed':  return 'Litige en cours';
      default:          return status;
    }
  }

  Future<void> _confirmReception(String farmName) async {
    await _firestore.updateOrderStatus(widget.orderId, 'completed');
    Get.snackbar(
      'Merci !',
      'Paiement libéré à $farmName.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  void _showDisputeDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Signaler un problème',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Décrivez le problème rencontré (poids incorrect, produit endommagé...)',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextFormField(
            controller: descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Décrivez le problème...'),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await _firestore.createDispute({
                'orderId': widget.orderId,
                'type': 'autre',
                'description': descCtrl.text,
              });
              Get.snackbar('Litige ouvert', 'L\'admin a été notifié et va intervenir.',
                  backgroundColor: AppColors.error, colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Envoyer', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String farmId, String farmName) {
    int selectedStars = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(children: [
            const Text('Noter la ferme',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(farmName,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setS(() => selectedStars = i + 1),
                child: Icon(
                  i < selectedStars ? Icons.star : Icons.star_border,
                  color: AppColors.accent,
                  size: 36,
                ),
              )),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Laissez un commentaire (optionnel)...'),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final auth = Get.find<AuthService>();
                await _firestore.addRating(
                  farmId: farmId,
                  orderId: widget.orderId,
                  clientId: auth.uid,
                  stars: selectedStars,
                  comment: commentCtrl.text,
                );
                Get.snackbar('Merci pour votre avis !',
                    '$selectedStars étoile${selectedStars > 1 ? 's' : ''} — $farmName',
                    backgroundColor: AppColors.success, colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
              },
              child: const Text('Envoyer', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget étape timeline ────────────────────────────────────────
enum _StepStatusType { done, active, pending }

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final _StepStatusType status;
  final bool isLast;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isLast,
  });

  Color get _color {
    switch (status) {
      case _StepStatusType.done:    return AppColors.success;
      case _StepStatusType.active:  return AppColors.primary;
      case _StepStatusType.pending: return AppColors.divider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: status == _StepStatusType.pending ? Colors.white : _color,
              shape: BoxShape.circle,
              border: Border.all(color: _color, width: 2),
            ),
            child: status == _StepStatusType.done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : status == _StepStatusType.active
                    ? const Icon(Icons.circle, size: 8, color: Colors.white)
                    : null,
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: status == _StepStatusType.done ? AppColors.success : AppColors.divider,
                margin: const EdgeInsets.symmetric(vertical: 3),
              ),
            ),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: status == _StepStatusType.pending
                          ? AppColors.textSecondary
                          : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
        ),
      ]),
    );
  }
}