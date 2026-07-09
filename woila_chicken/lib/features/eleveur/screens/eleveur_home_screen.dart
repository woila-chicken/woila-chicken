import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/kpi_card.dart';
import 'stock_screen.dart';
import 'eleveur_orders_screen.dart';
import 'farm_profile_screen.dart';

class EleveurHomeScreen extends StatefulWidget {
  const EleveurHomeScreen({super.key});

  @override
  State<EleveurHomeScreen> createState() => _EleveurHomeScreenState();
}

class _EleveurHomeScreenState extends State<EleveurHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: _DesktopEleveurLayout(
        selectedIndex: _selectedIndex,
        onNavTap: (i) => setState(() => _selectedIndex = i),
      ),
      mobile: _MobileEleveurLayout(
        selectedIndex: _selectedIndex,
        onNavTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Layout Desktop
// ─────────────────────────────────────────────────────────────────
class _DesktopEleveurLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const _DesktopEleveurLayout(
      {required this.selectedIndex, required this.onNavTap});

  static const _navItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'Tableau de bord'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Mon stock'},
    {'icon': Icons.list_alt_outlined, 'label': 'Commandes'},
    {'icon': Icons.store_outlined, 'label': 'Ma ferme'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar jaune/ambre
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  color: AppColors.accent,
                  child: const Row(
                    children: [
                      Icon(Icons.agriculture_rounded, size: 24, color: AppColors.accent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mon Élevage',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF412402),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _navItems.length; i++) ...[
  _EleveurSidebarItem(
    icon: _navItems[i]['icon'] as IconData,
    label: _navItems[i]['label'] as String,
    isSelected: selectedIndex == i,
    onTap: () {
      switch (i) {
        case 1: Get.to(() => const StockScreen()); break;
        case 2: Get.to(() => const EleveurOrdersScreen()); break;
        case 3: Get.to(() => const FarmProfileScreen()); break;
        default: onNavTap(i);
      }
    },
  ),
],
                const Spacer(),
                const Divider(height: 1),
                _EleveurSidebarItem(
                  icon: Icons.logout_outlined,
                  label: 'Déconnexion',
                  isSelected: false,
                  onTap: () => Get.offAllNamed('/'),
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Container(width: 1, color: AppColors.divider),

          // Contenu
          Expanded(
            child: Column(
              children: [
                _EleveurTopBar(),
                Container(height: 1, color: AppColors.divider),
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: _EleveurDashboardBody(isDesktop: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Layout Mobile
// ─────────────────────────────────────────────────────────────────
class _MobileEleveurLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const _MobileEleveurLayout(
      {required this.selectedIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Élevage'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
        actions: [
  Stack(
    children: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => Get.to(() => const EleveurOrdersScreen()),
      ),
      Positioned(
        right: 6, top: 6,
        child: Container(
          width: 14, height: 14,
          decoration: const BoxDecoration(
              color: AppColors.error, shape: BoxShape.circle),
          child: const Center(
            child: Text('2',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ),
    ],
  ),
],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _EleveurDashboardBody(isDesktop: false),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) {
  switch (i) {
    case 1: Get.to(() => const StockScreen()); break;
    case 2: Get.to(() => const EleveurOrdersScreen()); break;
    case 3: Get.to(() => const FarmProfileScreen()); break;
    default: onNavTap(i);
  }
},
        selectedItemColor: const Color(0xFF854F0B),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Stock'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'Commandes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: 'Ma Ferme'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Corps partagé dashboard éleveur
// ─────────────────────────────────────────────────────────────────
class _EleveurDashboardBody extends StatefulWidget {
  final bool isDesktop;
  const _EleveurDashboardBody({required this.isDesktop});

  @override
  State<_EleveurDashboardBody> createState() =>
      _EleveurDashboardBodyState();
}

class _EleveurDashboardBodyState extends State<_EleveurDashboardBody> {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();
  String? _farmId;
  String _farmName = '';
  bool _isLoadingFarm = true;

  @override
  void initState() {
    super.initState();
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    final farm = await _firestore.getFarmByOwner(_auth.uid);
    if (farm != null) {
      setState(() {
        _farmId = farm['id'];
        _farmName = farm['name'] ?? '';
        _isLoadingFarm = false;
      });
    } else {
      setState(() => _isLoadingFarm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFarm) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_farmId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.store_outlined,
                size: 56, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Aucune ferme associée à ce compte',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── En-tête bonjour ────────────────────────────────────
        Text('Bonjour, $_farmName',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Voici un aperçu de votre activité',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),

        // ── KPIs réels ───────────────────────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getProducts(farmId: _farmId).map(
              (products) => products
                  .map((p) => {'id': p.id, 'name': p.name})
                  .toList()),
          builder: (context, productSnap) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.getFarmOrders(_farmId!),
              builder: (context, orderSnap) {
                final products = productSnap.data ?? [];
                final orders = orderSnap.data ?? [];

                final activeOrders = orders
                    .where((o) => [
                          'pending',
                          'confirmed',
                          'inRoute'
                        ].contains(o['status']))
                    .length;

                final now = DateTime.now();
                double monthRevenue = 0;
                for (final o in orders) {
                  if (o['status'] != 'completed') continue;
                  try {
                    final dt = (o['createdAt'] as dynamic).toDate();
                    if (dt.month == now.month &&
                        dt.year == now.year) {
                      monthRevenue +=
                          (o['total'] as num?)?.toDouble() ?? 0;
                    }
                  } catch (_) {}
                }

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _firestore.getFarmByOwner(_auth.uid),
                  builder: (context, farmSnap) {
                    final rating =
                        (farmSnap.data?['rating'] as num?)
                                ?.toDouble() ??
                            0;

                    return GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount: widget.isDesktop ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          widget.isDesktop ? 1.3 : 1.0,
                      children: [
                        WoilaKpiCard(
                          value: '${products.length}',
                          label: 'Produits en stock',
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF854F0B),
                          trend: KpiTrend.neutral,
                          trendLabel: 'actifs',
                          onTap: () =>
                              Get.to(() => const StockScreen()),
                        ),
                        WoilaKpiCard(
                          value: '$activeOrders',
                          label: 'Commandes en cours',
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.warning,
                          trend: activeOrders > 0
                              ? KpiTrend.up
                              : KpiTrend.neutral,
                          trendLabel:
                              activeOrders > 0 ? 'à traiter' : 'aucune',
                          onTap: () => Get.to(
                              () => const EleveurOrdersScreen()),
                        ),
                        WoilaKpiCard(
                          value: monthRevenue.toStringAsFixed(0),
                          unit: 'FCFA',
                          label: 'Revenus ce mois',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.success,
                          trend: KpiTrend.neutral,
                          trendLabel: 'ce mois',
                        ),
                        WoilaKpiCard(
                          value: rating.toStringAsFixed(1),
                          label: 'Note clients',
                          icon: Icons.star_rounded,
                          color: AppColors.accent,
                          trend: KpiTrend.neutral,
                          trendLabel: rating > 0 ? 'sur 5' : 'pas encore',
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),

        // ── Alerte commandes en attente ──────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getFarmOrders(_farmId!),
          builder: (context, snap) {
            final orders = snap.data ?? [];
            final pending = orders
                .where((o) => o['status'] == 'pending')
                .length;
            if (pending == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.notifications_active_outlined,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$pending nouvelle${pending > 1 ? 's' : ''} commande${pending > 1 ? 's' : ''} à confirmer',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.to(
                        () => const EleveurOrdersScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Voir',
                        style: TextStyle(
                            fontSize: 12, fontFamily: 'Poppins')),
                  ),
                ]),
              ),
            );
          },
        ),

        // ── Dernières commandes ──────────────────────────────────
        Text('Dernières commandes',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getFarmOrders(_farmId!),
          builder: (context, snap) {
            final orders = (snap.data ?? []).take(4).toList();
            if (orders.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Center(
                  child: Text('Aucune commande pour le moment',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ),
              );
            }
            return Column(
              children: orders.map((order) {
                final status = order['status'] ?? 'pending';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.set_meal_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('#${order['ref'] ?? ''}',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              order['clientName'] as String? ?? '',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_statusLabel(status),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(status))),
                    ),
                  ]),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':   return AppColors.warning;
      case 'confirmed': return AppColors.success;
      case 'inRoute':   return Colors.blue;
      case 'delivered': return AppColors.primary;
      case 'completed': return AppColors.textSecondary;
      case 'disputed':  return AppColors.error;
      default:          return AppColors.textSecondary;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':   return 'En attente';
      case 'confirmed': return 'Confirmée';
      case 'inRoute':   return 'En route';
      case 'delivered': return 'Livrée';
      case 'completed': return 'Terminée';
      case 'disputed':  return 'Litige';
      default:          return s;
    }
  }
}


class _EleveurTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final firestore = Get.find<FirestoreService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Text(
                'Tableau de Bord',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
          const Spacer(),

          // Cloche avec badge commandes en attente
          FutureBuilder<Map<String, dynamic>?>(
            future: firestore.getFarmByOwner(auth.uid),
            builder: (context, farmSnap) {
              final farmId = farmSnap.data?['id'] as String?;
              if (farmId == null) {
                return IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.warning),
                  onPressed: () {},
                );
              }
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: firestore.getFarmOrders(farmId),
                builder: (context, orderSnap) {
                  final pending = (orderSnap.data ?? [])
                      .where((o) => o['status'] == 'pending')
                      .length;

                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.warning),
                          onPressed: () {
                            Get.to(() => const EleveurOrdersScreen());
                          },
                        ),
                        if (pending > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  pending > 9 ? '9+' : '$pending',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EleveurSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _EleveurSidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor =
        color ?? (isSelected ? const Color(0xFF854F0B) : AppColors.textSecondary);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.accent.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: itemColor)),
          ],
        ),
      ),
    );
  }
}

