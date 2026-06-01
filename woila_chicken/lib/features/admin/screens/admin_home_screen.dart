import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar noire ──────────────────────────────────────
          Container(
            width: 220,
            color: AppColors.adminColor,
            child: Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                            errorBuilder: (_, __, ___) => const Center(
                                child:  Icon(Icons.storefront_rounded, color: Colors.white, size: 18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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

                _AdminSidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => onNavTap(0),
                ),
                _AdminSidebarItem(
                  icon: Icons.store_mall_directory_outlined,
                  activeIcon: Icons.store_mall_directory,
                  label: 'Fermes',
                  isSelected: selectedIndex == 1,
                  onTap: () => Get.to(() => const AdminFarmsScreen()),
                  badge: '2',
                ),
                _AdminSidebarItem(
                  icon: Icons.gavel_outlined,
                  activeIcon: Icons.gavel,
                  label: 'Litiges',
                  isSelected: selectedIndex == 2,
                  onTap: () => Get.to(() => const AdminDisputesScreen()),
                  badge: '3',
                ),
                _AdminSidebarItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Statistiques',
                  isSelected: selectedIndex == 3,
                  onTap: () => Get.to(() => const AdminStatisticsScreen()),
                ),
                _AdminSidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Paramètres',
                  isSelected: selectedIndex == 4,
                  onTap: () => Get.to(() => const AdminSettingsScreen()),
                ),

                const Spacer(),
                Container(height: 1, color: Colors.white12),
                _AdminSidebarItem(
                  icon: Icons.logout_outlined,
                  activeIcon: Icons.logout,
                  label: 'Déconnexion',
                  isSelected: false,
                  onTap: () => Get.offAllNamed('/'),
                  color: Colors.red[300]!,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Contenu principal ──────────────────────────────────
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: AppColors.adminColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _AdminDashboardBody(isDesktop: false),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            // Note : les paramètres ne sont pas dans la BottomNav mobile
            // On les ajoute via un bouton dans le dashboard
            default:
              onNavTap(i);
          }
        },
        selectedItemColor: AppColors.adminColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory_outlined),
              activeIcon: Icon(Icons.store_mall_directory),
              label: 'Fermes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.gavel_outlined),
              activeIcon: Icon(Icons.gavel),
              label: 'Litiges'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats'),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPIs financiers ──────────────────────────────────────
        Text('Vue d\'ensemble',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: isDesktop ? 4 : 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: isDesktop ? 1.2 : 1.0,
  children: [
    WoilaKpiCard(
      value: '128 500',
      unit: 'FCFA',
      label: 'Commissions ce mois',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.success,
      trend: KpiTrend.up,
      trendLabel: '+18%',
      onTap: () => Get.to(() => const AdminTransactionsScreen()),
    ),
    WoilaKpiCard(
      value: '24',
      unit: 'fermes',
      label: 'Fermes actives',
      icon: Icons.store_rounded,
      color: AppColors.primary,
      trend: KpiTrend.up,
      trendLabel: '+2',
      onTap: () => Get.to(() => const AdminFarmsScreen()),
    ),
    WoilaKpiCard(
      value: '3',
      unit: 'litiges',
      label: 'Litiges ouverts',
      icon: Icons.gavel_rounded,
      color: AppColors.error,
      trend: KpiTrend.down,
      trendLabel: '-1',
      onTap: () => Get.to(() => const AdminDisputesScreen()),
    ),
    WoilaKpiCard(
      value: '2',
      unit: 'en attente',
      label: 'Fermes à valider',
      icon: Icons.pending_rounded,
      color: AppColors.warning,
      trend: KpiTrend.neutral,
      trendLabel: 'nouveau',
      onTap: () => Get.to(() => const AdminFarmsScreen()),
    ),
  ],
),
        const SizedBox(height: 28),

        // ── Alertes actives ──────────────────────────────────────
        _AlertBanner(
          icon: Icons.gavel_outlined,
          color: AppColors.error,
          title: '3 litiges nécessitent votre attention',
          subtitle: 'Problèmes de poids signalés par des clients',
          buttonLabel: 'Traiter',
          onTap: () => Get.to(() => const AdminDisputesScreen()),
        ),
        const SizedBox(height: 10),
        _AlertBanner(
          icon: Icons.pending_outlined,
          color: AppColors.warning,
          title: '2 nouvelles fermes en attente de validation',
          subtitle: 'Vérifiez les documents et accordez le badge Vérifié',
          buttonLabel: 'Valider',
          onTap: () => Get.to(() => const AdminFarmsScreen()),
        ),
        const SizedBox(height: 28),
        // ── Annuaire fermes ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text('Fermes partenaires',
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            TextButton.icon(
              onPressed: () => Get.to(() => const AdminFarmsScreen()),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Ajouter',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._mockFarms.map((farm) => _FarmRow(farm: farm)),

        const SizedBox(height: 28),

        // ── Transactions récentes ────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text('Transactions récentes',
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            TextButton.icon(
              onPressed: () => Get.to(() => const AdminTransactionsScreen()),
              icon: const Icon(Icons.bar_chart_outlined,
                  size: 16, color: AppColors.primary),
              label: const Text('Voir tout',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._mockTransactions.map((tx) => _TransactionRow(tx: tx)),

        const SizedBox(height: 16),
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
      Icon(Icons.settings_outlined,
          color: AppColors.primary, size: 20),
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
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
    final bool isVerified = farm['verified'] as bool;
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
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVerified ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(farm['name'] as String,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(
                    '${farm['products']} produits · ${farm['sales']} ventes ce mois',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isVerified ? '✓ Vérifié' : '⏳ En attente',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isVerified ? AppColors.success : AppColors.warning),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                size: 18, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'voir') {
                Get.to(() => const AdminFarmsScreen());
              } else if (value == 'valider') {
                Get.to(() => const AdminFarmsScreen());
              } else if (value == 'suspendre') {
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
        ],
      ),
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
              color: AppColors.primary.withOpacity(0.08),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Text('Tableau de bord',
              style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          // Badge litiges cliquable
          InkWell(
            onTap: () => Get.to(() => const AdminDisputesScreen()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.warning_amber_outlined,
                      color: AppColors.error, size: 16),
                  SizedBox(width: 6),
                  Text('3 litiges',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Cloche avec badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary),
                onPressed: () {
                  Get.snackbar(
                    'Notifications',
                    '3 litiges ouverts · 2 fermes en attente de validation',
                    backgroundColor: AppColors.adminColor,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 3),
                    icon: const Icon(Icons.notifications, color: Colors.white),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('5',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
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

// ─── Données mock ──────────────────────────────────────────────────
final _mockFarms = [
  {'name': 'Ferme Koné', 'verified': true, 'products': 8, 'sales': 14},
  {'name': 'Ferme Alhadji', 'verified': false, 'products': 5, 'sales': 0},
  {'name': 'Ferme Bougué', 'verified': true, 'products': 12, 'sales': 21},
  {'name': 'Ferme Sadou', 'verified': false, 'products': 3, 'sales': 0},
];

const _mockTransactions = [
  {
    'label': 'Commande #1042 — Ferme Koné',
    'date': '10 mai 2026',
    'total': '10 500 FCFA',
    'commission': '210 FCFA',
  },
  {
    'label': 'Commande #1041 — Ferme Bougué',
    'date': '9 mai 2026',
    'total': '4 200 FCFA',
    'commission': '84 FCFA',
  },
  {
    'label': 'Commande #1040 — Ferme Koné',
    'date': '8 mai 2026',
    'total': '7 800 FCFA',
    'commission': '156 FCFA',
  },
];
