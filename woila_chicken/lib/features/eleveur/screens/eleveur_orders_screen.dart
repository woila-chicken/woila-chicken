import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';

enum OrderStatus { enAttente, confirmee, livree, terminee, refusee }

class EleveurOrder {
  final String ref;
  final String clientName;
  final String product;
  final int quantity;
  final double total;
  final bool isDelivery;
  final String date;
  OrderStatus status;

  EleveurOrder({
    required this.ref,
    required this.clientName,
    required this.product,
    required this.quantity,
    required this.total,
    required this.isDelivery,
    required this.date,
    required this.status,
  });
}

class EleveurOrdersController extends GetxController {
  final orders = <EleveurOrder>[
    EleveurOrder(ref: 'WC-1043', clientName: 'Amadou Diallo',
        product: 'Poulet fermier 2kg', quantity: 2, total: 7000,
        isDelivery: true, date: '10 mai', status: OrderStatus.enAttente),
    EleveurOrder(ref: 'WC-1042', clientName: 'Fatoumata Bah',
        product: 'Poulet local 1.8kg', quantity: 1, total: 2800,
        isDelivery: false, date: '9 mai', status: OrderStatus.enAttente),
    EleveurOrder(ref: 'WC-1041', clientName: 'Ibrahim Sow',
        product: 'Gros poulet 2.5kg', quantity: 1, total: 4200,
        isDelivery: true, date: '8 mai', status: OrderStatus.confirmee),
    EleveurOrder(ref: 'WC-1040', clientName: 'Mariama Koné',
        product: 'Poulet fermier 2kg', quantity: 3, total: 10500,
        isDelivery: false, date: '7 mai', status: OrderStatus.terminee),
  ].obs;

  int get pendingCount =>
      orders.where((o) => o.status == OrderStatus.enAttente).length;

  void confirm(String ref) {
    final o = orders.firstWhere((o) => o.ref == ref);
    o.status = OrderStatus.confirmee;
    orders.refresh();
  }

  void markDelivered(String ref) {
    final o = orders.firstWhere((o) => o.ref == ref);
    o.status = OrderStatus.livree;
    orders.refresh();
  }

  void refuse(String ref) {
    final o = orders.firstWhere((o) => o.ref == ref);
    o.status = OrderStatus.refusee;
    orders.refresh();
  }
}

class EleveurOrdersScreen extends StatelessWidget {
  const EleveurOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(EleveurOrdersController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commandes reçues'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
        actions: [
          Obx(() => ctrl.pendingCount > 0
              ? Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${ctrl.pendingCount} nouvelles',
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

  Widget _buildList(BuildContext context, EleveurOrdersController ctrl) {
    return Obx(() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) =>
              _OrderCard(order: ctrl.orders[i], ctrl: ctrl),
        ));
  }
}

class _OrderCard extends StatelessWidget {
  final EleveurOrder order;
  final EleveurOrdersController ctrl;

  const _OrderCard({required this.order, required this.ctrl});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.enAttente: return AppColors.warning;
      case OrderStatus.confirmee: return AppColors.success;
      case OrderStatus.livree:    return AppColors.primary;
      case OrderStatus.terminee:  return AppColors.textSecondary;
      case OrderStatus.refusee:   return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.enAttente: return 'En attente';
      case OrderStatus.confirmee: return 'Confirmée';
      case OrderStatus.livree:    return 'Livrée';
      case OrderStatus.terminee:  return 'Terminée';
      case OrderStatus.refusee:   return 'Refusée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = order.status == OrderStatus.enAttente;
    final isConfirmed = order.status == OrderStatus.confirmee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNew
              ? AppColors.warning.withOpacity(0.5)
              : AppColors.divider,
          width: isNew ? 1.5 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        const SizedBox(height: 10),

        // Détails
        _DetailRow(icon: Icons.person_outline, text: order.clientName),
        const SizedBox(height: 4),
        _DetailRow(
            icon: Icons.inventory_2_outlined,
            text: '${order.product} × ${order.quantity}'),
        const SizedBox(height: 4),
        _DetailRow(
            icon: order.isDelivery
                ? Icons.local_shipping_outlined
                : Icons.store_outlined,
            text: order.isDelivery ? 'Livraison à domicile' : 'Retrait à la ferme'),
        const SizedBox(height: 4),
        _DetailRow(icon: Icons.calendar_today_outlined, text: order.date),
        const SizedBox(height: 10),

        // Total
        Row(children: [
          const Text('Total :',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Text('${order.total.toInt()} FCFA',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ]),

        // Actions
        if (isNew) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => ctrl.confirm(order.ref),
                child: const Text('✓ Confirmer',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => ctrl.refuse(order.ref),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error)),
                child: const Text('✗ Refuser',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),
          ]),
        ],
        if (isConfirmed) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ctrl.markDelivered(order.ref),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Marquer comme livré',
                  style: TextStyle(fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success),
            ),
          ),
        ],
      ]),
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
      Icon(icon, size: 15, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text(text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary)),
    ]);
  }
}