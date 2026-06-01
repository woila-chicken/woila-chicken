import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';

enum DisputeType { poidsIncorrect, nonLivre, qualite, autre }
enum DisputeStatus { ouvert, enCours, resolu }

class AdminDispute {
  final String ref;
  final String clientName;
  final String farmName;
  final DisputeType type;
  final String description;
  final double amount;
  final String date;
  DisputeStatus status;

  AdminDispute({
    required this.ref,
    required this.clientName,
    required this.farmName,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class AdminDisputesController extends GetxController {
  final disputes = <AdminDispute>[
    AdminDispute(ref: 'WC-1038', clientName: 'Amadou Diallo',
        farmName: 'Ferme Koné', type: DisputeType.poidsIncorrect,
        description: 'Poulet annoncé 2kg, reçu 1.7kg. Différence de 300g.',
        amount: 7000, date: '8 mai', status: DisputeStatus.ouvert),
    AdminDispute(ref: 'WC-1035', clientName: 'Fatoumata Bah',
        farmName: 'Ferme Alhadji', type: DisputeType.nonLivre,
        description: 'Commande non reçue après 48h. Le livreur ne répond plus.',
        amount: 4200, date: '6 mai', status: DisputeStatus.ouvert),
    AdminDispute(ref: 'WC-1031', clientName: 'Ibrahim Sow',
        farmName: 'Ferme Bougué', type: DisputeType.qualite,
        description: 'Produit reçu en mauvais état sanitaire.',
        amount: 3500, date: '4 mai', status: DisputeStatus.enCours),
    AdminDispute(ref: 'WC-1025', clientName: 'Mariama Koné',
        farmName: 'Ferme Koné', type: DisputeType.poidsIncorrect,
        description: 'Poids légèrement inférieur à l\'annonce.',
        amount: 2800, date: '1 mai', status: DisputeStatus.resolu),
  ].obs;

  int get openCount =>
      disputes.where((d) => d.status == DisputeStatus.ouvert).length;

  void resolve(String ref) {
    disputes.firstWhere((d) => d.ref == ref).status = DisputeStatus.resolu;
    disputes.refresh();
    Get.snackbar('Litige résolu', 'Le litige #$ref a été marqué comme résolu.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  void setInProgress(String ref) {
    disputes.firstWhere((d) => d.ref == ref).status = DisputeStatus.enCours;
    disputes.refresh();
  }
}

class AdminDisputesScreen extends StatelessWidget {
  const AdminDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminDisputesController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des litiges'),
        backgroundColor: AppColors.adminColor,
        actions: [
          Obx(() => ctrl.openCount > 0
              ? Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${ctrl.openCount} ouverts',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildList(context, ctrl),
          ),
        ),
        mobile: _buildList(context, ctrl),
      ),
    );
  }

  Widget _buildList(BuildContext context, AdminDisputesController ctrl) {
    return Obx(() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.disputes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) =>
              _DisputeCard(dispute: ctrl.disputes[i], ctrl: ctrl),
        ));
  }
}

class _DisputeCard extends StatelessWidget {
  final AdminDispute dispute;
  final AdminDisputesController ctrl;
  const _DisputeCard({required this.dispute, required this.ctrl});

  Color get _statusColor {
    switch (dispute.status) {
      case DisputeStatus.ouvert:   return AppColors.error;
      case DisputeStatus.enCours:  return AppColors.warning;
      case DisputeStatus.resolu:   return AppColors.success;
    }
  }

  String get _statusLabel {
    switch (dispute.status) {
      case DisputeStatus.ouvert:   return 'Ouvert';
      case DisputeStatus.enCours:  return 'En cours';
      case DisputeStatus.resolu:   return 'Résolu';
    }
  }

  String get _typeLabel {
    switch (dispute.type) {
      case DisputeType.poidsIncorrect: return 'Poids incorrect';
      case DisputeType.nonLivre:       return 'Non livré';
      case DisputeType.qualite:        return 'Qualité';
      case DisputeType.autre:          return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = dispute.status == DisputeStatus.ouvert;
    final isInProgress = dispute.status == DisputeStatus.enCours;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen
              ? AppColors.error.withOpacity(0.4)
              : AppColors.divider,
          width: isOpen ? 1.5 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#${dispute.ref}',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_typeLabel,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_statusLabel,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _DetailRow(
                  icon: Icons.person_outline, text: dispute.clientName),
              const SizedBox(height: 4),
              _DetailRow(
                  icon: Icons.store_outlined, text: dispute.farmName),
              const SizedBox(height: 4),
              _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  text: dispute.date),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Montant bloqué',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary)),
            Text('${dispute.amount.toInt()} FCFA',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(dispute.description,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary)),
        ),
        if (isOpen || isInProgress) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => ctrl.resolve(dispute.ref),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Résoudre',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showContactDialog(context),
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text('Contacter',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              ),
            ),
            if (isOpen) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => ctrl.setInProgress(dispute.ref),
                icon: const Icon(Icons.pending_actions_outlined,
                    color: AppColors.warning),
                tooltip: 'Marquer en cours',
              ),
            ],
          ]),
        ],
      ]),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contacter les parties',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.primary),
            title: Text(dispute.clientName,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13)),
            subtitle: const Text('Client',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.store_outlined,
                color: AppColors.primary),
            title: Text(dispute.farmName,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13)),
            subtitle: const Text('Éleveur',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
            onTap: () {},
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary)),
    ]);
  }
}