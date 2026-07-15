import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  color: AppColors.accent,
                  child: const Row(
                    children: [
                      Icon(Icons.agriculture_rounded,
                          size: 24, color: AppColors.accent),
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
                        case 1:
                          Get.to(() => const StockScreen());
                          break;
                        case 2:
                          Get.to(() => const EleveurOrdersScreen());
                          break;
                        case 3:
                          Get.to(() => const FarmProfileScreen());
                          break;
                        default:
                          onNavTap(i);
                      }
                    },
                  ),
                ],
                const Spacer(),
                const Divider(height: 1),
                const Spacer(),
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_outlined,
                      color: Colors.white70, size: 20),
                  title: const Text('Déconnexion',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white70)),
                  onTap: () => confirmLogout(context, Get.find<AuthService>()),
                ),
                const SizedBox(height: 8),
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
              //     if (pending > 0)
              // Positioned(
              //   right: 6,
              //   top: 6,
              //   child: Container(
              //     width: 14,
              //     height: 14,
              //     decoration: const BoxDecoration(
              //         color: AppColors.error, shape: BoxShape.circle),
              //     child: Center(
              //       child: Text(
              //         pending > 9 ? '9+' : '$pending',
              //         style: const TextStyle(
              //             fontFamily: 'Poppins',
              //             fontSize: 8,
              //             fontWeight: FontWeight.w700,
              //             color: Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
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
            case 1:
              Get.to(() => const StockScreen());
              break;
            case 2:
              Get.to(() => const EleveurOrdersScreen());
              break;
            case 3:
              Get.to(() => const FarmProfileScreen());
              break;
            default:
              onNavTap(i);
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
  State<_EleveurDashboardBody> createState() => _EleveurDashboardBodyState();
}

class _EleveurDashboardBodyState extends State<_EleveurDashboardBody> {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();

  String? _farmId;
  String _farmName = '';
  bool _isLoading = true;
  int _productCount = 0;
  int _activeOrders = 0;
  int _pendingCount = 0;
  double _revenue = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    try {
      final farm = await _firestore.getFarmByOwner(_auth.uid);
      if (!mounted) return;
      setState(() {
        _farmId = farm?['id'] as String?;
        _farmName = farm?['name'] as String? ?? '';
        _rating = (farm?['rating'] as num?)?.toDouble() ?? 0;
        _isLoading = false;
      });
      if (_farmId != null) {
        _listenProducts();
        _listenOrders();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _listenProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .where('farmId', isEqualTo: _farmId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() => _productCount = snap.docs.length);
    });
  }

  void _listenOrders() {
    FirebaseFirestore.instance
        .collection('orders')
        .where('farmId', isEqualTo: _farmId)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final docs = snap.docs;
      final now = DateTime.now();
      double rev = 0;
      int active = 0;
      int pending = 0;

      for (final d in docs) {
        final o = d.data() as Map<String, dynamic>;
        final status = o['status'] as String? ?? '';
        if (['pending', 'confirmed', 'inRoute'].contains(status)) active++;
        if (status == 'pending') pending++;
        if (status == 'completed') {
          try {
            final dt = (o['createdAt'] as Timestamp).toDate();
            if (dt.month == now.month && dt.year == now.year) {
              rev += (o['total'] as num?)?.toDouble() ?? 0;
            }
          } catch (_) {}
        }
      }

      setState(() {
        _activeOrders = active;
        _pendingCount = pending;
        _revenue = rev;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_farmId == null) {
      return const Center(
        child: Text('Aucune ferme associée à ce compte',
            style: TextStyle(
                fontFamily: 'Poppins', color: AppColors.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bonjour, $_farmName !',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Voici un aperçu de votre activité',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),

        // KPIs
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('farmId', isEqualTo: _farmId)
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, productSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('farmId', isEqualTo: _farmId)
                  .snapshots(),
              builder: (context, orderSnap) {
                final productCount = productSnap.data?.docs.length ?? 0;
                final orders = orderSnap.data?.docs ?? [];

                final activeOrders = orders
                    .where((d) => ['pending', 'confirmed', 'inRoute']
                        .contains((d.data() as Map)['status']))
                    .length;

                final now = DateTime.now();
                double revenue = 0;
                for (final d in orders) {
                  final o = d.data() as Map<String, dynamic>;
                  if (o['status'] != 'completed') continue;
                  try {
                    final dt = (o['createdAt'] as Timestamp).toDate();
                    if (dt.month == now.month && dt.year == now.year) {
                      revenue += (o['total'] as num?)?.toDouble() ?? 0;
                    }
                  } catch (_) {}
                }

                final pendingCount = orders
                    .where((d) => (d.data() as Map)['status'] == 'pending')
                    .length;

                return Column(children: [
                  // Remplace tout le bloc StreamBuilder<QuerySnapshot> des KPIs par :
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: widget.isDesktop ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: widget.isDesktop ? 1.3 : 1.0,
                    children: [
                      WoilaKpiCard(
                        value: '$_productCount',
                        label: 'Produits en stock',
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFF854F0B),
                        trend: KpiTrend.neutral,
                        trendLabel: 'actifs',
                        onTap: () => Get.to(() => const StockScreen()),
                      ),
                      WoilaKpiCard(
                        value: '$_activeOrders',
                        label: 'Commandes en cours',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warning,
                        trend:
                            _activeOrders > 0 ? KpiTrend.up : KpiTrend.neutral,
                        trendLabel: _activeOrders > 0 ? 'à traiter' : 'aucune',
                        onTap: () => Get.to(() => const EleveurOrdersScreen()),
                      ),
                      WoilaKpiCard(
                        value: _revenue.toStringAsFixed(0),
                        unit: 'FCFA',
                        label: 'Revenus ce mois',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.success,
                        trend: KpiTrend.neutral,
                        trendLabel: 'ce mois',
                      ),
                      WoilaKpiCard(
                        value: _rating > 0 ? _rating.toStringAsFixed(1) : '—',
                        label: 'Note clients',
                        icon: Icons.star_rounded,
                        color: AppColors.accent,
                        trend: KpiTrend.neutral,
                        trendLabel: _rating > 0 ? 'sur 5' : 'pas encore',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

// Alerte commandes
                  if (_pendingCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.notifications_active_outlined,
                              color: AppColors.warning, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$_pendingCount commande${_pendingCount > 1 ? 's' : ''} à confirmer',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Get.to(() => const EleveurOrdersScreen()),
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
                    ),
                  const SizedBox(height: 24),

                  // Alerte
                  if (pendingCount > 0)
                    Padding(
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
                              '$pendingCount commande${pendingCount > 1 ? 's' : ''} à confirmer',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Get.to(() => const EleveurOrdersScreen()),
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
                    ),
                ]);
              },
            );
          },
        ),

        // Dernières commandes
        Text('Dernières commandes',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('farmId', isEqualTo: _farmId)
              .orderBy('createdAt', descending: true)
              .limit(4)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
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
              children: docs.map((doc) {
                final o = doc.data() as Map<String, dynamic>;
                final status = o['status'] as String? ?? 'pending';
                Color sc;
                String sl;
                switch (status) {
                  case 'pending':
                    sc = AppColors.warning;
                    sl = 'En attente';
                    break;
                  case 'confirmed':
                    sc = AppColors.success;
                    sl = 'Confirmée';
                    break;
                  case 'delivered':
                    sc = AppColors.primary;
                    sl = 'Livrée';
                    break;
                  case 'completed':
                    sc = AppColors.textSecondary;
                    sl = 'Terminée';
                    break;
                  default:
                    sc = AppColors.error;
                    sl = 'Litige';
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(children: [
                    ProductImage(
                      imageUrl: o['productPhotoUrl'] as String?,
                      width: 40,
                      height: 40,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#${o['ref'] ?? ''}',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text(o['clientName'] as String? ?? '',
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
                        color: sc.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(sl,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: sc)),
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
                          icon: const Icon(Icons.notifications_outlined,
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
    final itemColor = color ??
        (isSelected ? const Color(0xFF854F0B) : AppColors.textSecondary);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : null,
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

void confirmLogout(BuildContext context, AuthService auth) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Se déconnecter ?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      content: const Text('Vous serez redirigé vers l\'écran de connexion.',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler',
              style: TextStyle(
                  fontFamily: 'Poppins', color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Navigator.pop(context);
            auth.logout();
          },
          child: const Text('Déconnecter',
              style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    ),
  );
}
