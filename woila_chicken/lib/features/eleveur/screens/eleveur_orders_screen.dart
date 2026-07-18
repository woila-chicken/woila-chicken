import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/woila_toast.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/notification_service.dart';

class EleveurOrdersScreen extends StatefulWidget {
  const EleveurOrdersScreen({super.key});

  @override
  State<EleveurOrdersScreen> createState() => _EleveurOrdersScreenState();
}

class _EleveurOrdersScreenState extends State<EleveurOrdersScreen> {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();
  final _notif = Get.find<NotificationService>();

  String? _farmId;
  bool _loadingFarm = true;

  @override
  void initState() {
    super.initState();
    _loadFarmId();
  }

  Future<void> _loadFarmId() async {
    try {
      final farm = await _firestore.getFarmByOwner(_auth.uid);
      if (!mounted) return;
      setState(() {
        _farmId = farm?['id'] as String?;
        _loadingFarm = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingFarm = false);
    }
  }

  Future<void> _confirmOrder(Map<String, dynamic> order) async {
    try {
      await _firestore.updateOrderStatus(order['id'], 'confirmed');
      await _notif.notifyOrderConfirmed(
        clientId: order['clientId'] ?? '',
        orderRef: order['ref'] ?? '',
        farmName: order['farmName'] ?? '',
      );
      WoilaToast.success('Commande confirmée', '#${order['ref'] ?? ''}');
    } catch (e) {
      WoilaToast.error('Erreur', 'Impossible de confirmer');
    }
  }

  Future<void> _markDelivered(Map<String, dynamic> order) async {
    try {
      await _firestore.updateOrderStatus(order['id'], 'delivered');
      await _notif.notifyOrderDelivered(
        clientId: order['clientId'] ?? '',
        orderRef: order['ref'] ?? '',
      );
      WoilaToast.success('Commande livrée', '#${order['ref'] ?? ''}');
    } catch (e) {
      WoilaToast.error('Erreur', 'Impossible de marquer comme livré');
    }
  }

  Future<void> _refuseOrder(Map<String, dynamic> order) async {
    try {
      await _firestore.updateOrderStatus(order['id'], 'disputed');
      if ((order['productId'] as String? ?? '').isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(order['productId'] as String)
            .update({
          'quantity':
              FieldValue.increment((order['quantity'] as num?)?.toInt() ?? 1),
        });
      }
      WoilaToast.warning('Commande refusée', '#${order['ref'] ?? ''}');
    } catch (e) {
      WoilaToast.error('Erreur', 'Impossible de refuser');
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'inRoute':
        return 'En route';
      case 'delivered':
        return 'Livrée';
      case 'completed':
        return 'Terminée';
      case 'disputed':
        return 'Refusée';
      default:
        return s;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.success;
      case 'delivered':
        return AppColors.primary;
      case 'completed':
        return AppColors.textSecondary;
      case 'disputed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commandes reçues'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
      ),
      body: _loadingFarm
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _farmId == null
              ? const Center(
                  child: Text(
                    'Aucune ferme associée à ce compte',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: AppColors.textSecondary),
                  ),
                )
              : ResponsiveLayout(
                  desktop: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: _buildList(),
                    ),
                  ),
                  mobile: _buildList(),
                ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestore.getFarmOrders(_farmId!),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                const Text('Aucune commande reçue',
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
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final order = orders[i];
            final status = order['status'] as String? ?? 'pending';
            return _OrderCard(
              order: order,
              statusLabel: _statusLabel(status),
              statusColor: _statusColor(status),
              onConfirm:
                  status == 'pending' ? () => _confirmOrder(order) : null,
              onDeliver:
                  status == 'confirmed' ? () => _markDelivered(order) : null,
              onRefuse: status == 'pending' ? () => _refuseOrder(order) : null,
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onDeliver;
  final VoidCallback? onRefuse;

  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    this.onConfirm,
    this.onDeliver,
    this.onRefuse,
  });

  String _formatPrice(double p) => '${p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      )} FCFA';

  @override
  Widget build(BuildContext context) {
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final isDelivery = order['isDelivery'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: onConfirm != null
              ? AppColors.warning.withValues(alpha: 0.5)
              : AppColors.divider,
          width: onConfirm != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('#${order['ref'] ?? ''}',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            ProductImage(
              imageUrl: order['productPhotoUrl'] as String?,
              width: 48,
              height: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['productName'] as String? ?? '',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Expanded(
                      child: Text(
                        order['clientName'] as String? ?? 'Client inconnu',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '×${(order['quantity'] as num?)?.toInt() ?? 1}',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(
                      isDelivery
                          ? Icons.local_shipping_outlined
                          : Icons.storefront_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDelivery ? 'Livraison' : 'Retrait ferme',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                  ]),
                ],
              ),
            ),
            Text(_formatPrice(total),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
          if (onConfirm != null || onRefuse != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: const Text('Confirmer',
                      style: TextStyle(fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onRefuse,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error)),
                  child: const Text('Refuser',
                      style: TextStyle(fontFamily: 'Poppins')),
                ),
              ),
            ]),
          ],
          if (onDeliver != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDeliver,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Marquer comme livré',
                    style: TextStyle(fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
