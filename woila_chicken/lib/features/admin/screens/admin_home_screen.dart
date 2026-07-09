import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/kpi_card.dart';
import 'admin_farms_screen.dart';
import 'admin_disputes_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_transactions_screen.dart';
import 'admin_settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: _DesktopAdminLayout(
        selectedIndex: _selectedIndex,
        onNavTap: (i) => setState(() => _selectedIndex = i),
      ),
      mobile: _MobileAdminLayout(
        selectedIndex: _selectedIndex,
        onNavTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Layout Desktop
// ─────────────────────────────────────────────────────────────────
class _DesktopAdminLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const _DesktopAdminLayout(
      {required this.selectedIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    final auth = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────
          Container(
            width: 220,
            color: AppColors.adminColor,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Admin',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('Woïla Chicken',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    color: Colors.white54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: Colors.white12),
                const SizedBox(height: 8),

                // Dashboard
                _AdminSidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => onNavTap(0),
                ),

                // Fermes avec badge dynamique
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestore.getAllFarms(),
                  builder: (context, snap) {
                    final pending = (snap.data ?? [])
                        .where((f) =>
                            f['isVerified'] == false &&
                            f['isSuspended'] == false)
                        .length;
                    return _AdminSidebarItem(
                      icon: Icons.store_mall_directory_outlined,
                      activeIcon: Icons.store_mall_directory,
                      label: 'Fermes',
                      isSelected: selectedIndex == 1,
                      onTap: () => Get.to(
                          () => const AdminFarmsScreen()),
                      badge: pending > 0 ? '$pending' : null,
                    );
                  },
                ),

                // Litiges avec badge dynamique
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestore.getAllDisputes(),
                  builder: (context, snap) {
                    final open = (snap.data ?? [])
                        .where((d) => d['status'] == 'open')
                        .length;
                    return _AdminSidebarItem(
                      icon: Icons.gavel_outlined,
                      activeIcon: Icons.gavel,
                      label: 'Litiges',
                      isSelected: selectedIndex == 2,
                      onTap: () => Get.to(
                          () => const AdminDisputesScreen()),
                      badge: open > 0 ? '$open' : null,
                    );
                  },
                ),

                // Statistiques
                _AdminSidebarItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Statistiques',
                  isSelected: selectedIndex == 3,
                  onTap: () => Get.to(
                      () => const AdminStatisticsScreen()),
                ),

                // Paramètres
                _AdminSidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Paramètres',
                  isSelected: selectedIndex == 4,
                  onTap: () => Get.to(
                      () => const AdminSettingsScreen()),
                ),

                const Spacer(),
                Container(height: 1, color: Colors.white12),

                // Déconnexion
                _AdminSidebarItem(
                  icon: Icons.logout_outlined,
                  activeIcon: Icons.logout,
                  label: 'Déconnexion',
                  isSelected: false,
                  onTap: () => _confirmLogout(context, auth),
                  color: Colors.red[300]!,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Contenu ────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(),
                Container(height: 1, color: AppColors.divider),
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: _AdminDashboardBody(isDesktop: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Se déconnecter ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Vous serez redirigé vers l\'écran de connexion.',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
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
}

// ─────────────────────────────────────────────────────────────────
//  Layout Mobile
// ─────────────────────────────────────────────────────────────────
class _MobileAdminLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const _MobileAdminLayout(
      {required this.selectedIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    final auth = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: AppColors.adminColor,
        actions: [
          // Cloche avec badge dynamique
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.getAllDisputes(),
            builder: (context, disputeSnap) {
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: firestore.getAllFarms(),
                builder: (context, farmSnap) {
                  final openDisputes = (disputeSnap.data ?? [])
                      .where((d) => d['status'] == 'open')
                      .length;
                  final pendingFarms = (farmSnap.data ?? [])
                      .where((f) =>
                          f['isVerified'] == false &&
                          f['isSuspended'] == false)
                      .length;
                  final total = openDisputes + pendingFarms;

                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.notifications_outlined),
                          onPressed: () {
                            Get.snackbar(
                              'Notifications',
                              '$openDisputes litige${openDisputes > 1 ? 's' : ''} · $pendingFarms ferme${pendingFarms > 1 ? 's' : ''} en attente',
                              backgroundColor: AppColors.adminColor,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                        ),
                        if (total > 0)
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
                                  total > 9 ? '9+' : '$total',
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

          // Bouton déconnexion
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _confirmLogout(context, auth),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _AdminDashboardBody(isDesktop: false),
      ),
      bottomNavigationBar: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getAllDisputes(),
        builder: (context, disputeSnap) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.getAllFarms(),
            builder: (context, farmSnap) {
              final openDisputes = (disputeSnap.data ?? [])
                  .where((d) => d['status'] == 'open')
                  .length;
              final pendingFarms = (farmSnap.data ?? [])
                  .where((f) =>
                      f['isVerified'] == false &&
                      f['isSuspended'] == false)
                  .length;

              return BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (i) {
                  switch (i) {
                    case 1:
                      Get.to(() => const AdminFarmsScreen());
                      break;
                    case 2:
                      Get.to(() => const AdminDisputesScreen());
                      break;
                    case 3:
                      Get.to(() => const AdminStatisticsScreen());
                      break;
                    default:
                      onNavTap(i);
                  }
                },
                selectedItemColor: AppColors.adminColor,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: _BadgeIcon(
                      icon: Icons.store_mall_directory_outlined,
                      count: pendingFarms,
                    ),
                    activeIcon: _BadgeIcon(
                      icon: Icons.store_mall_directory,
                      count: pendingFarms,
                      isActive: true,
                    ),
                    label: 'Fermes',
                  ),
                  BottomNavigationBarItem(
                    icon: _BadgeIcon(
                      icon: Icons.gavel_outlined,
                      count: openDisputes,
                    ),
                    activeIcon: _BadgeIcon(
                      icon: Icons.gavel,
                      count: openDisputes,
                      isActive: true,
                    ),
                    label: 'Litiges',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart),
                    label: 'Stats',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Se déconnecter ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Vous serez redirigé vers l\'écran de connexion.',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
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
}

// Widget badge sur icône BottomNav
class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;

  const _BadgeIcon({
    required this.icon,
    required this.count,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
// ─────────────────────────────────────────────────────────────────
//  Corps partagé dashboard admin
// ─────────────────────────────────────────────────────────────────
class _AdminDashboardBody extends StatelessWidget {
  final bool isDesktop;
  const _AdminDashboardBody({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPIs réels ───────────────────────────────────────────
        FutureBuilder<Map<String, dynamic>>(
          future: firestore.getAdminStats(),
          builder: (context, snap) {
            final stats = snap.data ??
                {
                  'totalCommission': 0.0,
                  'activeFarms': 0,
                  'openDisputes': 0,
                  'pendingFarms': 0,
                };
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isDesktop ? 1.2 : 1.0,
              children: [
                WoilaKpiCard(
                  value: ((stats['totalCommission'] as double?) ?? 0.0)
                      .toStringAsFixed(0),
                  unit: 'FCFA',
                  label: 'Commissions ce mois',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  trend: KpiTrend.up,
                  trendLabel: 'ce mois',
                  onTap: () => Get.to(() => const AdminTransactionsScreen()),
                ),
                WoilaKpiCard(
                  value: '${stats['activeFarms'] ?? 0}',
                  unit: 'fermes',
                  label: 'Fermes actives',
                  icon: Icons.store_rounded,
                  color: AppColors.primary,
                  trend: KpiTrend.neutral,
                  trendLabel: 'actives',
                  onTap: () => Get.to(() => const AdminFarmsScreen()),
                ),
                WoilaKpiCard(
                  value: '${stats['openDisputes'] ?? 0}',
                  unit: 'litiges',
                  label: 'Litiges ouverts',
                  icon: Icons.gavel_rounded,
                  color: AppColors.error,
                  trend: KpiTrend.neutral,
                  trendLabel: 'ouverts',
                  onTap: () => Get.to(() => const AdminDisputesScreen()),
                ),
                WoilaKpiCard(
                  value: '${stats['pendingFarms'] ?? 0}',
                  unit: 'en attente',
                  label: 'Fermes à valider',
                  icon: Icons.pending_rounded,
                  color: AppColors.warning,
                  trend: KpiTrend.neutral,
                  trendLabel: 'nouveau',
                  onTap: () => Get.to(() => const AdminFarmsScreen()),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // ── Alertes dynamiques ───────────────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: firestore.getAllDisputes(),
          builder: (context, snap) {
            final disputes = snap.data ?? [];
            final open = disputes.where((d) => d['status'] == 'open').length;
            if (open == 0) return const SizedBox.shrink();
            return Column(children: [
              _AlertBanner(
                icon: Icons.gavel_outlined,
                color: AppColors.error,
                title:
                    '$open litige${open > 1 ? 's' : ''} nécessite${open > 1 ? 'nt' : ''} votre attention',
                subtitle: 'Signalés par des clients — intervention requise',
                buttonLabel: 'Traiter',
                onTap: () => Get.to(() => const AdminDisputesScreen()),
              ),
              const SizedBox(height: 10),
            ]);
          },
        ),

        StreamBuilder<List<Map<String, dynamic>>>(
          stream: firestore.getAllFarms(),
          builder: (context, snap) {
            final farms = snap.data ?? [];
            final pending = farms
                .where((f) =>
                    f['isVerified'] == false && f['isSuspended'] == false)
                .length;
            if (pending == 0) return const SizedBox.shrink();
            return Column(children: [
              _AlertBanner(
                icon: Icons.pending_outlined,
                color: AppColors.warning,
                title:
                    '$pending ferme${pending > 1 ? 's' : ''} en attente de validation',
                subtitle: 'Vérifiez les documents et accordez le badge Vérifié',
                buttonLabel: 'Valider',
                onTap: () => Get.to(() => const AdminFarmsScreen()),
              ),
              const SizedBox(height: 10),
            ]);
          },
        ),
        const SizedBox(height: 18),

        // ── Fermes partenaires réelles ───────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: firestore.getAllFarms(),
          builder: (context, snap) {
            final farms = snap.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Fermes partenaires',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const AdminFarmsScreen()),
                    icon: const Icon(Icons.add,
                        size: 16, color: AppColors.primary),
                    label: const Text('Gérer',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.primary)),
                  ),
                ]),
                const SizedBox(height: 12),
                if (farms.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text('Aucune ferme inscrite',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...farms.take(5).map((farm) {
                    final isVerified = farm['isVerified'] as bool? ?? false;
                    final isSuspended = farm['isSuspended'] as bool? ?? false;
                    return _FarmRow(farm: {
                      'name': farm['name'] ?? '',
                      'verified': isVerified,
                      'suspended': isSuspended,
                      'products': farm['productCount'] ?? 0,
                      'sales': farm['salesCount'] ?? 0,
                      'id': farm['id'] ?? '',
                    });
                  }),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // ── Transactions récentes réelles ────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: firestore.getAllOrders(),
          builder: (context, snap) {
            final orders = snap.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Transactions récentes',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        Get.to(() => const AdminTransactionsScreen()),
                    icon: const Icon(Icons.bar_chart_outlined,
                        size: 16, color: AppColors.primary),
                    label: const Text('Voir tout',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.primary)),
                  ),
                ]),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text('Aucune transaction pour le moment',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...orders.take(5).map((order) => _TransactionRow(tx: {
                        'label':
                            '${order['ref'] ?? ''} — ${order['farmName'] ?? ''}',
                        'date': _formatDate(order['createdAt']),
                        'total':
                            '${(order['total'] as num?)?.toInt() ?? 0} FCFA',
                        'commission':
                            '${(order['commission'] as num?)?.toInt() ?? 0} FCFA',
                      })),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // ── Accès paramètres ─────────────────────────────────────
        InkWell(
          onTap: () => Get.to(() => const AdminSettingsScreen()),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Row(children: [
              Icon(Icons.settings_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text('Paramètres de la plateforme',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 18),
            ]),
          ),
        ),
      ],
    );
  }

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
}
// ─── Widgets ──────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(buttonLabel,
                style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

class _FarmRow extends StatelessWidget {
  final Map<String, dynamic> farm;
  const _FarmRow({required this.farm});

  @override
  Widget build(BuildContext context) {
    final isVerified = farm['verified'] as bool? ?? false;
    final isSuspended = farm['suspended'] as bool? ?? false;

    Color statusColor;
    String statusLabel;

    if (isSuspended) {
      statusColor = AppColors.error;
      statusLabel = 'Suspendu';
    } else if (isVerified) {
      statusColor = AppColors.success;
      statusLabel = 'Vérifié';
    } else {
      statusColor = AppColors.warning;
      statusLabel = 'En attente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(
                '${farm['products'] ?? 0} produits · ${farm['sales'] ?? 0} ventes ce mois',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(statusLabel,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor)),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert,
              size: 18, color: AppColors.textSecondary),
          padding: EdgeInsets.zero,
          onSelected: (value) {
            if (value == 'voir' || value == 'valider' || value == 'suspendre') {
              Get.to(() => const AdminFarmsScreen());
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'voir',
              child: Row(children: [
                Icon(Icons.visibility_outlined,
                    size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Voir le profil',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              ]),
            ),
            if (!isVerified && !isSuspended)
              const PopupMenuItem(
                value: 'valider',
                child: Row(children: [
                  Icon(Icons.verified_outlined,
                      size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Valider la ferme',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ]),
              ),
            if (!isSuspended)
              const PopupMenuItem(
                value: 'suspendre',
                child: Row(children: [
                  Icon(Icons.block_outlined, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Suspendre',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.error)),
                ]),
              ),
          ],
        ),
      ]),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Map<String, String> tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
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
                Text(tx['label']!,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(tx['date']!,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tx['total']!,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text('Commission : ${tx['commission']!}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Text('Tableau de bord',
              style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),

          // Badge litiges dynamique
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.getAllDisputes(),
            builder: (context, snap) {
              final disputes = snap.data ?? [];
              final open = disputes
                  .where((d) => d['status'] == 'open')
                  .length;
              if (open == 0) return const SizedBox.shrink();
              return InkWell(
                onTap: () => Get.to(() => const AdminDisputesScreen()),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_outlined,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$open litige${open > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Cloche avec badge dynamique
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.getAllDisputes(),
            builder: (context, disputeSnap) {
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: firestore.getAllFarms(),
                builder: (context, farmSnap) {
                  final openDisputes = (disputeSnap.data ?? [])
                      .where((d) => d['status'] == 'open')
                      .length;
                  final pendingFarms = (farmSnap.data ?? [])
                      .where((f) =>
                          f['isVerified'] == false &&
                          f['isSuspended'] == false)
                      .length;
                  final total = openDisputes + pendingFarms;

                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            Get.snackbar(
                              'Notifications',
                              '$openDisputes litige${openDisputes > 1 ? 's' : ''} ouvert${openDisputes > 1 ? 's' : ''} · $pendingFarms ferme${pendingFarms > 1 ? 's' : ''} en attente',
                              backgroundColor: AppColors.adminColor,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              icon: const Icon(Icons.notifications,
                                  color: Colors.white),
                              duration: const Duration(seconds: 3),
                            );
                          },
                        ),
                        if (total > 0)
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
                                  total > 9 ? '9+' : '$total',
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

class _AdminSidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final Color? color;

  const _AdminSidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? (isSelected ? Colors.white : Colors.white60);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white12 : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(isSelected ? activeIcon : icon, color: itemColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: itemColor),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
