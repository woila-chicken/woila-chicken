import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/woila_toast.dart';

class AdminDisputesScreen extends StatelessWidget {
  const AdminDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getAllDisputes(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final disputes = snap.data ?? [];
          final openCount =
              disputes.where((d) => d['status'] == 'open').length;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Gestion des litiges'),
              backgroundColor: AppColors.adminColor,
              automaticallyImplyLeading: true,
              actions: [
                if (openCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$openCount ouverts',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
              ],
            ),
            body: ResponsiveLayout(
              desktop: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildList(context, disputes, firestore),
                ),
              ),
              mobile: _buildList(context, disputes, firestore),
            ),
          );
        },
    );
  }

  Widget _buildList(BuildContext context,
      List<Map<String, dynamic>> disputes, FirestoreService firestore) {
    if (disputes.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.gavel_rounded,
              size: 64, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Aucun litige',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.textSecondary)),
          SizedBox(height: 6),
          Text('Tout va bien pour le moment',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: disputes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final d = disputes[i];
        final status = d['status'] as String? ?? 'open';
        final isOpen = status == 'open';
        final isInProgress = status == 'inProgress';

        Color statusColor;
        String statusLabel;
        switch (status) {
          case 'open':
            statusColor = AppColors.error;
            statusLabel = 'Ouvert';
            break;
          case 'inProgress':
            statusColor = AppColors.warning;
            statusLabel = 'En cours';
            break;
          default:
            statusColor = AppColors.success;
            statusLabel = 'Résolu';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOpen
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.divider,
              width: isOpen ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(children: [
                Text(
                  '#${d['orderId'] ?? ''}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    d['type'] as String? ?? 'Autre',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ]),
              const SizedBox(height: 10),

              // Détails
              _DetailRow(
                  icon: Icons.person_outline,
                  text: d['clientId'] as String? ?? ''),
              const SizedBox(height: 4),
              _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDate(d['createdAt'])),
              const SizedBox(height: 8),

              // Description
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d['description'] as String? ?? '',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ),

              // Actions
              if (isOpen || isInProgress) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await firestore.resolveDispute(d['id']);
                        WoilaToast.success('Litige résolu', 'Le litige a été marqué comme résolu');
                      },
                      icon: const Icon(
                          Icons.check_circle_outline, size: 16),
                      label: const Text('Résoudre',
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showContactDialog(context, d),
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Contacter',
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 12)),
                    ),
                  ),
                  if (isOpen) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () async {
                        await Get.find<FirestoreService>()
                            .getAllDisputes()
                            .first
                            .then((_) async {
                          await FirestoreService()
                              .resolveDispute(d['id']);
                        });
                      },
                      icon: const Icon(
                          Icons.pending_actions_outlined,
                          color: AppColors.warning),
                      tooltip: 'Marquer en cours',
                    ),
                  ],
                ]),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showContactDialog(
      BuildContext context, Map<String, dynamic> dispute) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Contacter les parties',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.primary),
            title: Text(
                dispute['clientId'] as String? ?? 'Client',
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13)),
            subtitle: const Text('Client',
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.store_outlined,
                color: AppColors.primary),
            title: Text(
                dispute['farmId'] as String? ?? 'Éleveur',
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13)),
            subtitle: const Text('Éleveur',
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11)),
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = (timestamp as dynamic).toDate();
      const months = [
        'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
        'juil', 'août', 'sep', 'oct', 'nov', 'déc'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
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