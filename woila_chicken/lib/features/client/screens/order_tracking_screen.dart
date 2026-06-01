import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/routes/app_routes.dart';

enum TrackingStatus { paye, preparation, enRoute, livre, confirme }

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Simuler la commande en cours
  // En production ces données viennent de Firebase
  final String orderRef = 'WC-1043';
  final String productName = 'Poulet fermier 2kg × 2';
  final String farmName = 'Ferme Koné';
  final double total = 7500;
  final bool isDelivery = true;
  TrackingStatus currentStatus = TrackingStatus.preparation;

  String _formatPrice(double p) => '${p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      )} FCFA';

  void _showRatingDialog(BuildContext context) {
    int selectedStars = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(children: [
            const Text('Noter la ferme',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(farmName,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            // Étoiles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  5,
                  (i) => GestureDetector(
                        onTap: () => setS(() => selectedStars = i + 1),
                        child: Icon(
                          i < selectedStars ? Icons.star : Icons.star_border,
                          color: AppColors.accent,
                          size: 36,
                        ),
                      )),
            ),
            const SizedBox(height: 6),
            Text(
              selectedStars == 5
                  ? 'Excellent !'
                  : selectedStars == 4
                      ? 'Très bien'
                      : selectedStars == 3
                          ? 'Bien'
                          : selectedStars == 2
                              ? 'Passable'
                              : 'Mauvais',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Laissez un commentaire (optionnel)...',
                hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary),
              ),
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
              onPressed: () {
                Navigator.pop(ctx);
                Get.snackbar(
                  '⭐ Merci pour votre avis !',
                  '$selectedStars étoile${selectedStars > 1 ? 's' : ''} — $farmName',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('Envoyer',
                  style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(AppRoutes.clientHome),
        ),
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _buildContent(),
          ),
        ),
        mobile: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // ── Référence + statut global ────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Text('Référence commande',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white70)),
            const SizedBox(height: 4),
            Text('#$orderRef',
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
                _statusGlobalLabel(),
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
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset('assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('🐓'))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(farmName,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(
                        isDelivery
                            ? Icons.local_shipping_outlined
                            : Icons.store_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDelivery ? 'Livraison à domicile' : 'Retrait ferme',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                time: '10 mai · 09:14',
                status: _stepStatus(TrackingStatus.paye),
                isLast: false,
              ),
              _TrackingStep(
                title: 'Préparation en cours',
                subtitle: '$farmName prépare votre commande',
                time: '10 mai · 09:32',
                status: _stepStatus(TrackingStatus.preparation),
                isLast: false,
              ),
              _TrackingStep(
                title: isDelivery ? 'En route' : 'Prêt pour retrait',
                subtitle: isDelivery
                    ? 'Le livreur est en chemin'
                    : 'Rendez-vous à la ferme',
                time: currentStatus.index >= TrackingStatus.enRoute.index
                    ? '10 mai · 11:00'
                    : '—',
                status: _stepStatus(TrackingStatus.enRoute),
                isLast: false,
              ),
              _TrackingStep(
                title: isDelivery ? 'Livré' : 'Récupéré',
                subtitle: isDelivery
                    ? 'Commande remise au client'
                    : 'Commande retirée à la ferme',
                time: currentStatus.index >= TrackingStatus.livre.index
                    ? '10 mai · 11:45'
                    : '—',
                status: _stepStatus(TrackingStatus.livre),
                isLast: false,
              ),
              _TrackingStep(
                title: 'Réception confirmée',
                subtitle: 'Paiement libéré à l\'éleveur',
                time: currentStatus == TrackingStatus.confirme
                    ? '10 mai · 11:50'
                    : '—',
                status: _stepStatus(TrackingStatus.confirme),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Bouton confirmation réception ────────────────────────
        if (currentStatus == TrackingStatus.livre) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(children: [
              const Icon(Icons.inventory_outlined,
                  color: AppColors.success, size: 32),
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
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => currentStatus = TrackingStatus.confirme);
                    Get.snackbar(
                      'Merci !',
                      'Paiement libéré à $farmName.',
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.white),
                    );
                    
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Confirmer la réception',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
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
              onPressed: () => _showDisputeDialog(),
              icon: const Icon(Icons.report_outlined,
                  size: 16, color: AppColors.error),
              label: const Text('Signaler un problème',
                  style:
                      TextStyle(fontFamily: 'Poppins', color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error)),
            ),
          ),
        ],

        // ── Statut final ─────────────────────────────────────────
        if (currentStatus == TrackingStatus.confirme) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 40),
              const SizedBox(height: 10),
              const Text('Commande terminée !',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success)),
              const SizedBox(height: 6),
              const Text(
                  'Merci pour votre confiance. N\'oubliez pas de noter la ferme.',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Noter la ferme',
                    style: TextStyle(fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFF412402)),
              ),
            ]),
          ),
        ],

        // ── Simulation avancement (pour démo) ───────────────────
        const SizedBox(height: 24),
        if (currentStatus != TrackingStatus.confirme)
          OutlinedButton(
            onPressed: () {
              if (currentStatus.index < TrackingStatus.livre.index) {
                setState(() => currentStatus =
                    TrackingStatus.values[currentStatus.index + 1]);
              }
            },
            child: const Text('Simuler étape suivante (démo)',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary)),
          ),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  _StepStatusType _stepStatus(TrackingStatus step) {
    if (currentStatus.index > step.index) return _StepStatusType.done;
    if (currentStatus.index == step.index) return _StepStatusType.active;
    return _StepStatusType.pending;
  }

  String _statusGlobalLabel() {
    switch (currentStatus) {
      case TrackingStatus.paye:
        return 'Paiement confirmé';
      case TrackingStatus.preparation:
        return 'En cours de préparation';
      case TrackingStatus.enRoute:
        return 'En route vers vous';
      case TrackingStatus.livre:
        return 'Livré — En attente de confirmation';
      case TrackingStatus.confirme:
        return 'Commande terminée ✓';
    }
  }

  void _showDisputeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Signaler un problème',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'Décrivez le problème rencontré (poids incorrect, produit endommagé...)',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            decoration:
                const InputDecoration(hintText: 'Décrivez le problème...'),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                  'Litige ouvert', 'L\'admin a été notifié et va intervenir.',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM);
            },
            child:
                const Text('Envoyer', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─── Widget étape timeline ────────────────────────────────────────
enum _StepStatusType { done, active, pending }

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final _StepStatusType status;
  final bool isLast;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.isLast,
  });

  Color get _color {
    switch (status) {
      case _StepStatusType.done:
        return AppColors.success;
      case _StepStatusType.active:
        return AppColors.primary;
      case _StepStatusType.pending:
        return AppColors.divider;
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
                color: status == _StepStatusType.done
                    ? AppColors.success
                    : AppColors.divider,
                margin: const EdgeInsets.symmetric(vertical: 3),
              ),
            ),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary)),
              if (time != '—') ...[
                const SizedBox(height: 3),
                Text(time,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: _color,
                        fontWeight: FontWeight.w600)),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}
