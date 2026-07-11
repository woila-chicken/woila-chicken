import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';

enum TxSortOption { dateDesc, dateAsc, montantDesc, montantAsc }

enum TxFilterFarm { toutes, kone, alhadji, boyrue, sadou, hamidou }

class AdminTransaction {
  final String ref;
  final String farmName;
  final String clientName;
  final String product;
  final double total;
  final double commission;
  final String date;
  final DateTime dateTime;
  final bool isDelivery;

  const AdminTransaction({
    required this.ref,
    required this.farmName,
    required this.clientName,
    required this.product,
    required this.total,
    required this.commission,
    required this.date,
    required this.dateTime,
    required this.isDelivery,
  });
}

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String _searchQuery = '';
  String _selectedFarm = 'Toutes';
  TxSortOption _sortOption = TxSortOption.dateDesc;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _onlyDelivery = false;

  final _firestore = Get.find<FirestoreService>();

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

String _statusLabel(String status) {
  switch (status) {
    case 'pending':   return 'En attente';
    case 'confirmed': return 'Confirmée';
    case 'inRoute':   return 'En route';
    case 'delivered': return 'Livrée';
    case 'completed': return 'Terminée';
    case 'disputed':  return 'Litige';
    default:          return status;
  }
}

  bool get _hasFilters =>
      _selectedFarm != 'Toutes' ||
      _dateFrom != null ||
      _dateTo != null ||
      _onlyDelivery ||
      _searchQuery.isNotEmpty;

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> orders) {
    var list = orders.where((tx) {
      // Recherche
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final ref = (tx['ref'] as String? ?? '').toLowerCase();
        final client = (tx['clientName'] as String? ?? '').toLowerCase();
        final farm = (tx['farmName'] as String? ?? '').toLowerCase();
        if (!ref.contains(q) && !client.contains(q) && !farm.contains(q)) {
          return false;
        }
      }
      // Ferme
      if (_selectedFarm != 'Toutes' && tx['farmName'] != _selectedFarm) {
        return false;
      }
      // Dates
      if (_dateFrom != null || _dateTo != null) {
        try {
          final dt = (tx['createdAt'] as dynamic).toDate();
          if (_dateFrom != null && dt.isBefore(_dateFrom!)) {
            return false;
          }
          if (_dateTo != null &&
              dt.isAfter(_dateTo!.add(const Duration(days: 1)))) {
            return false;
          }
        } catch (_) {}
      }
      // Livraison
      if (_onlyDelivery && !(tx['isDelivery'] as bool? ?? false)) return false;
      return true;
    }).toList();

    switch (_sortOption) {
      case TxSortOption.dateDesc:
        list.sort((a, b) {
          try {
            return (b['createdAt'] as dynamic)
                .toDate()
                .compareTo((a['createdAt'] as dynamic).toDate());
          } catch (_) {
            return 0;
          }
        });
        break;
      case TxSortOption.dateAsc:
        list.sort((a, b) {
          try {
            return (a['createdAt'] as dynamic)
                .toDate()
                .compareTo((b['createdAt'] as dynamic).toDate());
          } catch (_) {
            return 0;
          }
        });
        break;
      case TxSortOption.montantDesc:
        list.sort((a, b) =>
            ((b['total'] as num?) ?? 0).compareTo((a['total'] as num?) ?? 0));
        break;
      case TxSortOption.montantAsc:
        list.sort((a, b) =>
            ((a['total'] as num?) ?? 0).compareTo((b['total'] as num?) ?? 0));
        break;
    }
    return list;
  }

  String _formatPrice(double p) => '${p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      )} FCFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Toutes les transactions'),
        backgroundColor: AppColors.adminColor,
        actions: [
          IconButton(
            icon: Icon(
                _hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => _showFiltersSheet(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getAllOrders(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allOrders = snap.data ?? [];
          final filtered = _applyFilters(allOrders);

          // Fermes disponibles pour le filtre
          final farms = <String>{'Toutes'};
          for (final o in allOrders) {
            final f = o['farmName'] as String?;
            if (f != null && f.isNotEmpty) farms.add(f);
          }

          final totalVolume = filtered.fold<double>(
              0, (s, o) => s + ((o['total'] as num?) ?? 0));
          final totalCommission = filtered.fold<double>(
              0, (s, o) => s + ((o['commission'] as num?) ?? 0));

          return ResponsiveLayout(
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 260,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _FiltersPanel(
                      farms: farms.toList(),
                      selectedFarm: _selectedFarm,
                      sortOption: _sortOption,
                      dateFrom: _dateFrom,
                      dateTo: _dateTo,
                      onlyDelivery: _onlyDelivery,
                      hasFilters: _hasFilters,
                      onFarmChanged: (v) => setState(() => _selectedFarm = v),
                      onSortChanged: (v) => setState(() => _sortOption = v),
                      onDateFromChanged: (v) => setState(() => _dateFrom = v),
                      onDateToChanged: (v) => setState(() => _dateTo = v),
                      onDeliveryChanged: (v) =>
                          setState(() => _onlyDelivery = v),
                      onReset: _resetFilters,
                    ),
                  ),
                ),
                Container(width: 1, color: AppColors.divider),
                Expanded(
                  child: Column(children: [
                    _buildSearchBar(),
                    _buildSummaryBar(
                        filtered.length, totalVolume, totalCommission),
                    Expanded(child: _buildList(filtered)),
                  ]),
                ),
              ],
            ),
            mobile: Column(children: [
              _buildSearchBar(),
              if (_hasFilters) _buildActiveChips(),
              _buildSummaryBar(filtered.length, totalVolume, totalCommission),
              Expanded(child: _buildList(filtered)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Expanded(
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Rechercher par ref, client, ferme...',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.primary, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<TxSortOption>(
          onSelected: (v) => setState(() => _sortOption = v),
          initialValue: _sortOption,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.swap_vert, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text(_sortLabel(_sortOption),
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textPrimary)),
            ]),
          ),
          itemBuilder: (_) => [
            _sortItem(TxSortOption.dateDesc, 'Date ↓ (récent)'),
            _sortItem(TxSortOption.dateAsc, 'Date ↑ (ancien)'),
            _sortItem(TxSortOption.montantDesc, 'Montant ↓'),
            _sortItem(TxSortOption.montantAsc, 'Montant ↑'),
          ],
        ),
      ]),
    );
  }

  Widget _buildActiveChips() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          if (_selectedFarm != 'Toutes')
            _Chip(
                label: _selectedFarm,
                onRemove: () => setState(() => _selectedFarm = 'Toutes')),
          if (_dateFrom != null)
            _Chip(
                label: 'Depuis ${_dateFrom!.day}/${_dateFrom!.month}',
                onRemove: () => setState(() => _dateFrom = null)),
          if (_dateTo != null)
            _Chip(
                label: 'Jusqu\'au ${_dateTo!.day}/${_dateTo!.month}',
                onRemove: () => setState(() => _dateTo = null)),
          if (_onlyDelivery)
            _Chip(
                label: 'Livraison seulement',
                onRemove: () => setState(() => _onlyDelivery = false)),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Tout effacer',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int count, double volume, double commission) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.adminColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        _SummaryItem(
            label: '$count transactions',
            value: '',
            icon: Icons.receipt_long_outlined),
        const Spacer(),
        _SummaryItem(
            label: 'Volume',
            value: _formatPrice(volume),
            icon: Icons.swap_horiz_outlined),
        const SizedBox(width: 16),
        _SummaryItem(
            label: 'Commissions',
            value: _formatPrice(commission),
            icon: Icons.account_balance_wallet_outlined),
      ]),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.search_off,
              size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('Aucune transaction trouvée',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Réinitialiser les filtres',
                style:
                    TextStyle(fontFamily: 'Poppins', color: AppColors.primary)),
          ),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final order = orders[i];
        final total = (order['total'] as num?)?.toDouble() ?? 0;
        final commission = (order['commission'] as num?)?.toDouble() ?? 0;
        final isDelivery = order['isDelivery'] as bool? ?? false;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.swap_horiz,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      '#${order['ref'] ?? ''}',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDelivery
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDelivery
                                ? Icons.local_shipping_rounded
                                : Icons.storefront_rounded,
                            size: 10,
                            color: isDelivery
                                ? AppColors.primary
                                : const Color(0xFF412402),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isDelivery ? 'Livraison' : 'Retrait',
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 9),
                          ),
                          const SizedBox(width: 6),
  Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: _statusColor(order['status'] as String? ?? '')
          .withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      _statusLabel(order['status'] as String? ?? ''),
      style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: _statusColor(
              order['status'] as String? ?? '')),
    ),
  ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    '${order['clientName'] ?? ''} · ${order['farmName'] ?? ''}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                  Text(
                    '${order['productName'] ?? ''} · ${_formatDate(order['createdAt'])}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatPrice(total),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  'Commission : ${_formatPrice(commission)}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success),
                ),
              ],
            ),
          ]),
        );
      },
    );
  }

  void _showFiltersSheet(BuildContext context) {
    // Récupère les fermes du stream
    Get.find<FirestoreService>().getAllOrders().first.then((orders) {
      if (!context.mounted) return;
      final farms = <String>{'Toutes'};
      for (final o in orders) {
        final f = o['farmName'] as String?;
        if (f != null && f.isNotEmpty) farms.add(f);
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Text('Filtres',
                    style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                if (_hasFilters)
                  TextButton(
                    onPressed: () {
                      _resetFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Réinitialiser',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: AppColors.primary)),
                  ),
              ]),
              const SizedBox(height: 8),
              _FiltersPanel(
                farms: farms.toList(),
                selectedFarm: _selectedFarm,
                sortOption: _sortOption,
                dateFrom: _dateFrom,
                dateTo: _dateTo,
                onlyDelivery: _onlyDelivery,
                hasFilters: _hasFilters,
                onFarmChanged: (v) => setState(() => _selectedFarm = v),
                onSortChanged: (v) => setState(() => _sortOption = v),
                onDateFromChanged: (v) => setState(() => _dateFrom = v),
                onDateToChanged: (v) => setState(() => _dateTo = v),
                onDeliveryChanged: (v) => setState(() => _onlyDelivery = v),
                onReset: _resetFilters,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Appliquer',
                      style: TextStyle(fontFamily: 'Poppins')),
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }

  void _resetFilters() => setState(() {
        _searchQuery = '';
        _selectedFarm = 'Toutes';
        _sortOption = TxSortOption.dateDesc;
        _dateFrom = null;
        _dateTo = null;
        _onlyDelivery = false;
      });

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = (timestamp as dynamic).toDate();
      const months = [
        'jan',
        'fév',
        'mar',
        'avr',
        'mai',
        'juin',
        'juil',
        'août',
        'sep',
        'oct',
        'nov',
        'déc'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  PopupMenuItem<TxSortOption> _sortItem(TxSortOption opt, String label) =>
      PopupMenuItem(
        value: opt,
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Panneau filtres partagé
// ─────────────────────────────────────────────────────────────────
class _FiltersPanel extends StatelessWidget {
  final List<String> farms;
  final String selectedFarm;
  final TxSortOption sortOption;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool onlyDelivery;
  final bool hasFilters;
  final ValueChanged<String> onFarmChanged;
  final ValueChanged<TxSortOption> onSortChanged;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;
  final ValueChanged<bool> onDeliveryChanged;
  final VoidCallback onReset;

  const _FiltersPanel({
    required this.farms,
    required this.selectedFarm,
    required this.sortOption,
    required this.dateFrom,
    required this.dateTo,
    required this.onlyDelivery,
    required this.hasFilters,
    required this.onFarmChanged,
    required this.onSortChanged,
    required this.onDateFromChanged,
    required this.onDateToChanged,
    required this.onDeliveryChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Ferme ──────────────────────────────────────────────────
      const _FilterLabel(label: 'Ferme'),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: farms
            .map((f) => _FilterChip(
                  label: f,
                  isSelected: selectedFarm == f,
                  onTap: () => onFarmChanged(f),
                ))
            .toList(),
      ),
      const SizedBox(height: 20),

      // ── Période ────────────────────────────────────────────────
      const _FilterLabel(label: 'Période'),
      Row(children: [
        Expanded(
          child: _DateButton(
            label:
                dateFrom != null ? '${dateFrom!.day}/${dateFrom!.month}' : 'Du',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dateFrom ?? DateTime.now(),
                firstDate: DateTime(2026, 1),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              onDateFromChanged(picked);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: _DateButton(
            label: dateTo != null ? '${dateTo!.day}/${dateTo!.month}' : 'Au',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dateTo ?? DateTime.now(),
                firstDate: DateTime(2026, 1),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              onDateToChanged(picked);
            },
          ),
        ),
        if (dateFrom != null || dateTo != null)
          IconButton(
            icon: const Icon(Icons.clear,
                size: 16, color: AppColors.textSecondary),
            onPressed: () {
              onDateFromChanged(null);
              onDateToChanged(null);
            },
          ),
      ]),
      const SizedBox(height: 20),

      // ── Tri ────────────────────────────────────────────────────
      const _FilterLabel(label: 'Trier par'),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _FilterChip(
              label: 'Date ↓',
              isSelected: sortOption == TxSortOption.dateDesc,
              onTap: () => onSortChanged(TxSortOption.dateDesc)),
          _FilterChip(
              label: 'Date ↑',
              isSelected: sortOption == TxSortOption.dateAsc,
              onTap: () => onSortChanged(TxSortOption.dateAsc)),
          _FilterChip(
              label: 'Montant ↓',
              isSelected: sortOption == TxSortOption.montantDesc,
              onTap: () => onSortChanged(TxSortOption.montantDesc)),
          _FilterChip(
              label: 'Montant ↑',
              isSelected: sortOption == TxSortOption.montantAsc,
              onTap: () => onSortChanged(TxSortOption.montantAsc)),
        ],
      ),
      const SizedBox(height: 20),

      // ── Mode de retrait ────────────────────────────────────────
      const _FilterLabel(label: 'Mode de retrait'),
      Row(children: [
        Switch(
          value: onlyDelivery,
          activeColor: AppColors.primary,
          onChanged: onDeliveryChanged,
        ),
        const SizedBox(width: 6),
        const Text('Livraisons seulement',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textPrimary)),
      ]),
    ]);
  }
}

// ─── Widgets utilitaires ──────────────────────────────────────────
class _FilterLabel extends StatelessWidget {
  final String label;
  const _FilterLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.calendar_today_outlined,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _Chip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: AppColors.primary)),
        const SizedBox(width: 4),
        InkWell(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 13, color: AppColors.primary),
        ),
      ]),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.white70),
      const SizedBox(width: 5),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 10, color: Colors.white70)),
        if (value.isNotEmpty)
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
      ]),
    ]);
  }
}

String _sortLabel(TxSortOption opt) {
  switch (opt) {
    case TxSortOption.dateDesc:
      return 'Date ↓';
    case TxSortOption.dateAsc:
      return 'Date ↑';
    case TxSortOption.montantDesc:
      return 'Montant ↓';
    case TxSortOption.montantAsc:
      return 'Montant ↑';
  }
}
