import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';

enum FarmStatus { verified, pending, suspended }

class AdminFarm {
  final String id;
  final String name;
  final String owner;
  final String phone;
  final String location;
  final int productCount;
  final int salesCount;
  final double rating;
  FarmStatus status;

  AdminFarm({
    required this.id,
    required this.name,
    required this.owner,
    required this.phone,
    required this.location,
    required this.productCount,
    required this.salesCount,
    required this.rating,
    required this.status,
  });
}

class AdminFarmsController extends GetxController {
  final farms = <AdminFarm>[
    AdminFarm(id: 'f1', name: 'Ferme Koné', owner: 'Koné Moussa',
        phone: '+237 677 001 001', location: 'Garoua Nord',
        productCount: 8, salesCount: 14, rating: 4.9,
        status: FarmStatus.verified),
    AdminFarm(id: 'f2', name: 'Ferme Alhadji', owner: 'Alhadji Bello',
        phone: '+237 699 002 002', location: 'Garoua Centre',
        productCount: 6, salesCount: 9, rating: 4.7,
        status: FarmStatus.verified),
    AdminFarm(id: 'f3', name: 'Ferme Bougué', owner: 'M. Bougué',
        phone: '+237 655 003 003', location: 'Garoua Est',
        productCount: 12, salesCount: 21, rating: 4.8,
        status: FarmStatus.verified),
    AdminFarm(id: 'f4', name: 'Ferme Sadou', owner: 'Sadou Ibrahim',
        phone: '+237 677 004 004', location: 'Ngaoundéré',
        productCount: 3, salesCount: 0, rating: 0,
        status: FarmStatus.pending),
    AdminFarm(id: 'f5', name: 'Ferme Hamidou', owner: 'Hamidou Ali',
        phone: '+237 699 005 005', location: 'Garoua Ouest',
        productCount: 5, salesCount: 0, rating: 0,
        status: FarmStatus.pending),
  ].obs;

  int get pendingCount =>
      farms.where((f) => f.status == FarmStatus.pending).length;

  void verify(String id) {
    farms.firstWhere((f) => f.id == id).status = FarmStatus.verified;
    farms.refresh();
    Get.snackbar('Ferme vérifiée', 'Le badge Vérifié a été accordé.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  void suspend(String id) {
    farms.firstWhere((f) => f.id == id).status = FarmStatus.suspended;
    farms.refresh();
    Get.snackbar('Ferme suspendue', 'La ferme a été suspendue.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }
}

class AdminFarmsScreen extends StatelessWidget {
  const AdminFarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminFarmsController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fermes partenaires'),
        backgroundColor: AppColors.adminColor,
        actions: [
          Obx(() => ctrl.pendingCount > 0
              ? Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${ctrl.pendingCount} en attente',
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildList(ctrl),
          ),
        ),
        mobile: _buildList(ctrl),
      ),
    );
  }

  Widget _buildList(AdminFarmsController ctrl) {
    return Obx(() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.farms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _FarmCard(farm: ctrl.farms[i], ctrl: ctrl),
        ));
  }
}

class _FarmCard extends StatelessWidget {
  final AdminFarm farm;
  final AdminFarmsController ctrl;
  const _FarmCard({required this.farm, required this.ctrl});

  Color get _statusColor {
    switch (farm.status) {
      case FarmStatus.verified:  return AppColors.success;
      case FarmStatus.pending:   return AppColors.warning;
      case FarmStatus.suspended: return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (farm.status) {
      case FarmStatus.verified:  return '✓ Vérifié';
      case FarmStatus.pending:   return '⏳ En attente';
      case FarmStatus.suspended: return '⛔ Suspendu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = farm.status == FarmStatus.pending;
    final isVerified = farm.status == FarmStatus.verified;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(farm.name[0],
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _statusColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(farm.name,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(farm.owner,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _InfoChip(icon: Icons.phone_outlined, text: farm.phone),
          const SizedBox(width: 10),
          _InfoChip(icon: Icons.location_on_outlined, text: farm.location),
        ]),
        if (farm.salesCount > 0) ...[
          const SizedBox(height: 8),
          Row(children: [
            _InfoChip(
                icon: Icons.inventory_2_outlined,
                text: '${farm.productCount} produits'),
            const SizedBox(width: 10),
            _InfoChip(
                icon: Icons.shopping_bag_outlined,
                text: '${farm.salesCount} ventes'),
            const SizedBox(width: 10),
            _InfoChip(
                icon: Icons.star_outline,
                text: '${farm.rating} ★'),
          ]),
        ],
        const SizedBox(height: 12),
        Row(children: [
          if (isPending) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => ctrl.verify(farm.id),
                icon: const Icon(Icons.verified_outlined, size: 16),
                label: const Text('Accorder le badge',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => ctrl.suspend(farm.id),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error)),
                child: const Text('Refuser',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              ),
            ),
          ],
          if (isVerified)
            OutlinedButton.icon(
              onPressed: () => ctrl.suspend(farm.id),
              icon: const Icon(Icons.block_outlined,
                  size: 16, color: AppColors.error),
              label: const Text('Suspendre',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error)),
            ),
        ]),
      ]),
    );
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