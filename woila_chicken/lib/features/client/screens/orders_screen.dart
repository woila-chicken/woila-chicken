import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'order_tracking_screen.dart';

enum OrderFilter { toutes, enCours, livrees, terminees }

class ClientOrder {
  final String ref;
  final String productName;
  final String farmName;
  final double total;
  final String date;
  final String status;
  final Color statusColor;
  final bool canTrack;

  const ClientOrder({
    required this.ref,
    required this.productName,
    required this.farmName,
    required this.total,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.canTrack,
  });
}

final _mockOrders = [
  ClientOrder(
    ref: 'WC-1043',
    productName: 'Poulet fermier 2kg × 2',
    farmName: 'Ferme Koné',
    total: 7500,
    date: '10 mai 2026',
    status: 'En cours',
    statusColor: AppColors.warning,
    canTrack: true,
  ),
  ClientOrder(
    ref: 'WC-1040',
    productName: 'Poulet local 1.8kg × 1',
    farmName: 'Ferme Alhadji',
    total: 2800,
    date: '7 mai 2026',
    status: 'Livré',
    statusColor: AppColors.success,
    canTrack: true,
  ),
  ClientOrder(
    ref: 'WC-1036',
    productName: 'Gros poulet 2.5kg × 2',
    farmName: 'Ferme Bougué',
    total: 8400,
    date: '3 mai 2026',
    status: 'Terminée',
    statusColor: AppColors.textSecondary,
    canTrack: false,
  ),
  ClientOrder(
    ref: 'WC-1030',
    productName: 'Poulet bio 2.2kg × 1',
    farmName: 'Ferme Hamidou',
    total: 4500,
    date: '25 avr 2026',
    status: 'Terminée',
    statusColor: AppColors.textSecondary,
    canTrack: false,
  ),
];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderFilter _filter = OrderFilter.toutes;

  List<ClientOrder> get _filtered {
    switch (_filter) {
      case OrderFilter.toutes:
        return _mockOrders;
      case OrderFilter.enCours:
        return _mockOrders
            .where((o) => o.status == 'En cours')
            .toList();
      case OrderFilter.livrees:
        return _mockOrders
            .where((o) => o.status == 'Livré')
            .toList();
      case OrderFilter.terminees:
        return _mockOrders
            .where((o) => o.status == 'Terminée')
            .toList();
    }
  }

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';

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
    return Column(
      children: [
        // Filtres
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            children: [
              _FilterTab(
                label: 'Toutes',
                isSelected: _filter == OrderFilter.toutes,
                onTap: () =>
                    setState(() => _filter = OrderFilter.toutes),
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'En cours',
                isSelected: _filter == OrderFilter.enCours,
                onTap: () =>
                    setState(() => _filter = OrderFilter.enCours),
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'Livré',
                isSelected: _filter == OrderFilter.livrees,
                onTap: () =>
                    setState(() => _filter = OrderFilter.livrees),
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'Terminées',
                isSelected: _filter == OrderFilter.terminees,
                onTap: () =>
                    setState(() => _filter = OrderFilter.terminees),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64,
                          color:
                              AppColors.textSecondary.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      const Text('Aucune commande',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) => _OrderCard(
                    order: _filtered[i],
                    formatPrice: _formatPrice,
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ClientOrder order;
  final String Function(double) formatPrice;

  const _OrderCard({required this.order, required this.formatPrice});

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
          // En-tête
          Row(children: [
            Text('#${order.ref}',
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
                color: order.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(order.status,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: order.statusColor)),
            ),
          ]),
          const SizedBox(height: 10),

          // Détails
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.productName,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(order.farmName,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(order.date,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(formatPrice(order.total),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),

          // Bouton suivi
          if (order.canTrack) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(
                  () => const OrderTrackingScreen(),
                  transition: Transition.rightToLeft,
                ),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
                color:
                    isSelected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}