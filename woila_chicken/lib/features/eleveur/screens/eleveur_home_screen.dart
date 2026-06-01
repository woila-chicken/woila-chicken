import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
class _EleveurDashboardBody extends StatelessWidget {
  final bool isDesktop;
  const _EleveurDashboardBody({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte ferme
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
                child: const Center(
                    child:  Icon(Icons.agriculture_rounded, size: 26, color: Color(0xFF412402)),
              )),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ferme Bougué',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ Ferme vérifiée',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // KPIs
        Text('Résumé du mois',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: isDesktop ? 4 : 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: isDesktop ? 1.3 : 1.0,
  children: [
    WoilaKpiCard(
      value: '12',
      label: 'Produits en stock',
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFF854F0B),
      trend: KpiTrend.neutral,
      trendLabel: 'actifs',
      onTap: () => Get.to(() => const StockScreen()),
    ),
    WoilaKpiCard(
      value: '3',
      label: 'Commandes en cours',
      icon: Icons.pending_actions_rounded,
      color: AppColors.warning,
      trend: KpiTrend.up,
      trendLabel: '+1 today',
      onTap: () => Get.to(() => const EleveurOrdersScreen()),
    ),
    const WoilaKpiCard(
      value: '47 500',
      unit: 'FCFA',
      label: 'Revenus ce mois',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.success,
      trend: KpiTrend.up,
      trendLabel: '+12%',
    ),
    const WoilaKpiCard(
      value: '4.8',
      label: 'Note clients',
      icon: Icons.star_rounded,
      color: AppColors.accent,
      trend: KpiTrend.up,
      trendLabel: '+0.1',
    ),
  ],
),
        const SizedBox(height: 20),

        // Alerte commandes en attente
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.warning, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2 commandes en attente',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text('Confirmez la préparation ou la livraison',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              ElevatedButton(
  onPressed: () => Get.to(() => const EleveurOrdersScreen()),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.warning,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  ),
  child: const Text('Voir',
      style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Commandes récentes
        Text('Commandes récentes',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        ..._mockOrders.map((order) => _OrderRow(order: order)),
      ],
    );
  }
}


class _OrderRow extends StatelessWidget {
  final Map<String, String> order;
  const _OrderRow({required this.order});

  Color get _statusColor {
    switch (order['status']) {
      case 'En attente':
        return AppColors.warning;
      case 'Confirmée':
        return AppColors.success;
      case 'Livrée':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order['client']!,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text('${order['product']} · ${order['date']}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(order['amount']!,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order['status']!,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _EleveurTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Text('Bonjour, Bougué 👋',
              style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.warning),
              onPressed: () {}),
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
              isSelected ? AppColors.accent.withOpacity(0.15) : null,
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

const _mockOrders = [
  {
    'client': 'Amadou Diallo',
    'product': 'Poulet 2kg × 3',
    'amount': '10 500 FCFA',
    'date': '10 mai',
    'status': 'En attente',
  },
  {
    'client': 'Fatoumata Bah',
    'product': 'Poulet 1.8kg × 2',
    'amount': '5 600 FCFA',
    'date': '9 mai',
    'status': 'Confirmée',
  },
  {
    'client': 'Ibrahim Sow',
    'product': 'Poulet 2.5kg × 1',
    'amount': '4 200 FCFA',
    'date': '8 mai',
    'status': 'Livrée',
  },
];
