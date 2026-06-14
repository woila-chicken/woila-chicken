import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/firestore_service.dart';

class AdminFarmsScreen extends StatelessWidget {
  const AdminFarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getAllFarms(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final farms = snap.data ?? [];
          final pendingCount = farms
              .where((f) =>
                  f['isVerified'] == false &&
                  f['isSuspended'] == false)
              .length;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Fermes partenaires'),
              backgroundColor: AppColors.adminColor,
              automaticallyImplyLeading: true,
              actions: [
                if (pendingCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$pendingCount en attente',
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
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: _buildList(context, farms, firestore),
                ),
              ),
              mobile: _buildList(context, farms, firestore),
            ),
          );
        },
    );
  }

  Widget _buildList(BuildContext context,
      List<Map<String, dynamic>> farms, FirestoreService firestore) {
    if (farms.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.store_outlined,
              size: 64, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Aucune ferme inscrite',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: farms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final farm = farms[i];
        final isVerified = farm['isVerified'] as bool? ?? false;
        final isSuspended = farm['isSuspended'] as bool? ?? false;
        final isPending = !isVerified && !isSuspended;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPending
                  ? AppColors.warning.withOpacity(0.5)
                  : AppColors.divider,
              width: isPending ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor(isVerified, isSuspended)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (farm['name'] as String? ?? 'F')[0].toUpperCase(),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(isVerified, isSuspended)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farm['name'] as String? ?? '',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(farm['owner'] as String? ?? '',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(isVerified, isSuspended)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(isVerified, isSuspended),
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(isVerified, isSuspended)),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Infos
              Wrap(spacing: 16, runSpacing: 6, children: [
                if ((farm['phone'] as String? ?? '').isNotEmpty)
                  _InfoChip(
                      icon: Icons.phone_outlined,
                      text: farm['phone'] as String? ?? ''),
                if ((farm['location'] as String? ?? '').isNotEmpty)
                  _InfoChip(
                      icon: Icons.location_on_outlined,
                      text: farm['location'] as String? ?? ''),
                if ((farm['rating'] as num? ?? 0) > 0)
                  _InfoChip(
                      icon: Icons.star_rounded,
                      text:
                          '${(farm['rating'] as num? ?? 0).toStringAsFixed(1)} ★'),
              ]),
              const SizedBox(height: 12),

              // Actions
              Row(children: [
                if (isPending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await firestore.verifyFarm(farm['id']);
                        Get.snackbar(
                          'Ferme vérifiée',
                          '${farm['name']} a reçu le badge Vérifié',
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          icon: const Icon(Icons.verified_rounded,
                              color: Colors.white),
                        );
                      },
                      icon: const Icon(Icons.verified_outlined, size: 16),
                      label: const Text('Accorder le badge',
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await firestore.suspendFarm(farm['id']);
                        Get.snackbar(
                          'Ferme refusée',
                          '${farm['name']} a été refusée',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                              color: AppColors.error)),
                      child: const Text('Refuser',
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 12)),
                    ),
                  ),
                ],
                if (isVerified)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await firestore.suspendFarm(farm['id']);
                      Get.snackbar(
                        'Ferme suspendue',
                        '${farm['name']} a été suspendue',
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.block_outlined,
                        size: 16, color: AppColors.error),
                    label: const Text('Suspendre',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.error)),
                  ),
                if (isSuspended)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await firestore.verifyFarm(farm['id']);
                      Get.snackbar(
                        'Ferme réactivée',
                        '${farm['name']} a été réactivée',
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Réactiver',
                        style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success),
                  ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(bool isVerified, bool isSuspended) {
    if (isSuspended) return AppColors.error;
    if (isVerified) return AppColors.success;
    return AppColors.warning;
  }

  String _statusLabel(bool isVerified, bool isSuspended) {
    if (isSuspended) return 'Suspendu';
    if (isVerified) return 'Vérifié';
    return 'En attente';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary)),
    ]);
  }
}