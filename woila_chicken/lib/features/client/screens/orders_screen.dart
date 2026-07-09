import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/woila_toast.dart';
import 'order_tracking_screen.dart';

enum OrderFilter { toutes, enCours, livrees, terminees }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderFilter _filter = OrderFilter.toutes;
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';

  List<Map<String, dynamic>> _applyFilter(
      List<Map<String, dynamic>> orders) {
    switch (_filter) {
      case OrderFilter.toutes:
        return orders;
      case OrderFilter.enCours:
        return orders
            .where((o) => ['pending', 'confirmed', 'inRoute']
                .contains(o['status']))
            .toList();
      case OrderFilter.livrees:
        return orders
            .where((o) => o['status'] == 'delivered')
            .toList();
      case OrderFilter.terminees:
        return orders
            .where((o) => o['status'] == 'completed')
            .toList();
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':   return 'En attente';
      case 'confirmed': return 'Confirmée';
      case 'inRoute':   return 'En route';
      case 'delivered': return 'Livré';
      case 'completed': return 'Terminée';
      case 'disputed':  return 'Litige';
      default:          return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return AppColors.warning;
      case 'confirmed': return AppColors.primary;
      case 'inRoute':   return Colors.blue;
      case 'delivered': return AppColors.success;
      case 'completed': return AppColors.textSecondary;
      case 'disputed':  return AppColors.error;
      default:          return AppColors.textSecondary;
    }
  }

  bool _canTrack(String status) =>
      ['pending', 'confirmed', 'inRoute', 'delivered']
          .contains(status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildContent(),
          ),
        ),
        mobile: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(children: [
      // Filtres
      Container(
  height: 64,
  color: Colors.white,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 12),
    children: [
            _FilterTab(label: 'Toutes',
                isSelected: _filter == OrderFilter.toutes,
                onTap: () => setState(() => _filter = OrderFilter.toutes)),
            const SizedBox(width: 8),
            _FilterTab(label: 'En cours',
                isSelected: _filter == OrderFilter.enCours,
                color: AppColors.warning,
                onTap: () => setState(() => _filter = OrderFilter.enCours)),
            const SizedBox(width: 8),
            _FilterTab(label: 'Livré',
                isSelected: _filter == OrderFilter.livrees,
                color: AppColors.success,
                onTap: () => setState(() => _filter = OrderFilter.livrees)),
            const SizedBox(width: 8),
            _FilterTab(label: 'Terminées',
                isSelected: _filter == OrderFilter.terminees,
                color: AppColors.textSecondary,
                onTap: () => setState(() => _filter = OrderFilter.terminees)),
          ],
        ),
      ),

      Container(height: 1, color: AppColors.divider),

      // Liste Firestore
      Expanded(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getClientOrders(_auth.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text('Erreur : ${snap.error}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.error)),
              );
            }

            final orders = _applyFilter(snap.data ?? []);

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const Text('Aucune commande',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final order = orders[i];
                final status = order['status'] ?? 'pending';
                return _OrderCard(
                  ref: order['ref'] ?? '',
                  productName: order['productName'] ?? '',
                  farmName: order['farmName'] ?? '',
                  total: (order['total'] as num?)?.toDouble() ?? 0,
                  date: _formatDate(order['createdAt']),
                  status: _statusLabel(status),
                  statusColor: _statusColor(status),
                  canTrack: _canTrack(status),
                  orderId: order['id']?.toString() ?? '',
                  formatPrice: _formatPrice,
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = (timestamp as dynamic).toDate();
      return '${dt.day} ${_month(dt.month)} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _month(int m) {
    const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin',
        'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
    return months[m - 1];
  }
}

class _OrderCard extends StatelessWidget {
  final String ref;
  final String productName;
  final String farmName;
  final double total;
  final String date;
  final String status;
  final Color statusColor;
  final bool canTrack;
  final String orderId;
  final String Function(double) formatPrice;

  const _OrderCard({
    required this.ref,
    required this.productName,
    required this.farmName,
    required this.total,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.canTrack,
    required this.orderId,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
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
            Text('#$ref',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.set_meal_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(farmName,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(date,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(formatPrice(total),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
          if (canTrack) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  debugPrint('orderId: $orderId');
  if (orderId.isEmpty) {
    WoilaToast.error(
        'Erreur', 'Référence de commande introuvable');
    return;
  }
  Get.to(
    () => OrderTrackingScreen(orderId: orderId),
    transition: Transition.rightToLeft,
  );
},
                icon: const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.primary),
                label: const Text('Suivre la commande',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.primary)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}