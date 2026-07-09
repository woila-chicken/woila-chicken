import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/models/product.dart';
import '../controllers/cart_controller.dart';
import '../controllers/catalogue_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'catalogue_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../../../core/widgets/product_card.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CatalogueController>()) {
    Get.put(CatalogueController());
  }
    return ResponsiveLayout(
      desktop: _DesktopClientLayout(
        selectedIndex: _selectedIndex,
        onNavTap: (i) => setState(() => _selectedIndex = i),
      ),
      mobile: _MobileClientLayout(
        selectedIndex: _selectedIndex,
        onNavTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Layout Desktop : sidebar gauche + contenu principal
// ─────────────────────────────────────────────────────────────────
class _DesktopClientLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const _DesktopClientLayout(
      {required this.selectedIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar navigation ────────────────────────────────
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: [
                // Header sidebar
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
                                child:
                                    Text('🐓', style: TextStyle(fontSize: 18))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Woïla Chicken',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Accueil',
                  isSelected: selectedIndex == 0,
                  onTap: () => onNavTap(0),
                ),
                _SidebarItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Catalogue',
                  isSelected: selectedIndex == 1,
                  onTap: () => Get.toNamed(AppRoutes.catalogue),
                ),
                _SidebarItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Mes commandes',
                  isSelected: selectedIndex == 2,
                  onTap: () => Get.to(() => const OrdersScreen()),
                ),
                _SidebarItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Mon profil',
                  isSelected: selectedIndex == 3,
                  onTap: () => Get.to(() => const ProfileScreen()),
                ),
                const Spacer(),
                const Divider(height: 1),
                _SidebarItem(
                  icon: Icons.logout_outlined,
                  activeIcon: Icons.logout,
                  label: 'Déconnexion',
                  isSelected: false,
                  onTap: () => Get.offAllNamed('/'),
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Séparateur
          Container(width: 1, color: AppColors.divider),

          // ── Contenu principal ─────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // TopBar desktop
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: _SearchBar(),
                      ),
                      const SizedBox(width: 16),
                      const _NotifButton(color: AppColors.primary),
                      const _CartButton(color: AppColors.primary),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.divider),

                // Corps scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: const _ClientHomeBody(isDesktop: true),
                      ),
                    ),
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
//  Layout Mobile : AppBar + BottomNav classiques
// ─────────────────────────────────────────────────────────────────
class _MobileClientLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const _MobileClientLayout(
      {required this.selectedIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Woïla Chicken'),
        actions: const [
          _NotifButton(),
          _CartButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(),
            const SizedBox(height: 16),
            const _ClientHomeBody(isDesktop: false),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) {
          switch (i) {
            case 1:
              Get.to(() => const CatalogueScreen());
              break;
            case 2:
              Get.to(() => const OrdersScreen());
              break;
            case 3:
              Get.to(() => const ProfileScreen());
              break;
            default:
              onNavTap(i);
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Catalogue'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Commandes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Corps partagé (stats + catalogue)
// ─────────────────────────────────────────────────────────────────
class _ClientHomeBody extends StatelessWidget {
  final bool isDesktop;
  const _ClientHomeBody({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats rapides
         StreamBuilder<List<Map<String, dynamic>>>(
  stream: Get.find<FirestoreService>().getAllFarms(),
  builder: (context, farmSnap) {
    return StreamBuilder<List<Product>>(
      stream: Get.find<FirestoreService>().getProducts(),
      builder: (context, productSnap) {
        final farms = farmSnap.data ?? [];
        final verifiedFarms =
            farms.where((f) => f['isVerified'] == true).toList();
        final products = productSnap.data ?? [];

        double avgRating = 0;
        if (verifiedFarms.isNotEmpty) {
          final ratings = verifiedFarms
              .map((f) => (f['rating'] as num?)?.toDouble() ?? 0)
              .where((r) => r > 0)
              .toList();
          if (ratings.isNotEmpty) {
            avgRating =
                ratings.reduce((a, b) => a + b) / ratings.length;
          }
        }

        return Row(
          children: [
            _StatCard(
              value: '${verifiedFarms.length}',
              label: 'Fermes actives',
              icon: Icons.storefront_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            _StatCard(
              value: '${products.length}',
              label: 'Produits dispo.',
              icon: Icons.agriculture_rounded,
              color: AppColors.success,
            ),
            const SizedBox(width: 12),
            _StatCard(
              value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
              label: 'Note moyenne',
              icon: Icons.star_rounded,
              color: AppColors.accent,
            ),
          ],
        );
      },
    );
  },
),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Produits disponibles',
                    style: Theme.of(context).textTheme.headlineMedium),
                Text('Garoua et environs',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.catalogue),
            icon: const Icon(Icons.arrow_forward,
                size: 16, color: AppColors.primary),
            label: const Text('Voir tout',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 16),

        // Grille produits — 2 colonnes mobile, 3-4 desktop
        Obx(() {
  final ctrl = Get.find<CatalogueController>();
  if (ctrl.isLoading.value) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
  final products = ctrl.products.take(8).toList();
  if (products.isEmpty) {
    return Center(
      child: Text('Aucun produit disponible',
          style: Theme.of(context).textTheme.bodyMedium),
    );
  }
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      mainAxisExtent: 230,
    ),
    itemCount: products.length,
    itemBuilder: (context, index) =>
        ProductCard(product: products[index]),
  );
}),
      ],
    );
  }
}

// ─── Widgets réutilisables ────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.catalogue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Text(
              'Rechercher par ferme, poids, prix...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Rond décoratif dans le coin
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Contenu réel
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => ProductDetailScreen(product: product),
        transition: Transition.rightToLeft,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Center(
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
    ? Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 100,
        errorBuilder: (_, __, ___) => const Icon(
            Icons.egg_rounded,
            color: AppColors.primary, size: 40),
      )
    : const Icon(Icons.egg_rounded,
        color: AppColors.primary, size: 40),
                  ),
                ),
                if (product.hasSanitaryCert)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 10, color: Colors.white),
                          SizedBox(width: 3),
                          Text('Certifié',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.deliveryAvailable
                          ? AppColors.primary
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      product.deliveryAvailable
                          ? Icons.local_shipping_rounded
                          : Icons.storefront_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Infos
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.name} — ${product.weightKg} kg',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.pricefcfa} FCFA',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.store_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        product.farmName,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.star, size: 12, color: AppColors.accent),
                    const SizedBox(width: 2),
                    Text(
                      product.farmRating.toString(),
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor =
        color ?? (isSelected ? AppColors.primary : AppColors.textSecondary);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(isSelected ? activeIcon : icon, color: itemColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _NotifButton extends StatelessWidget {
  final Color color;
  const _NotifButton({this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final firestore = Get.find<FirestoreService>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.getClientOrders(auth.uid),
      builder: (context, snap) {
        final orders = snap.data ?? [];
        // Compte les commandes qui ont changé de statut récemment
        // et nécessitent l'attention du client (livré = à confirmer)
        final needsAttention = orders
            .where((o) => o['status'] == 'delivered')
            .length;

        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: color),
                onPressed: () {
                  if (needsAttention > 0) {
                    Get.to(() => const OrdersScreen());
                  } else {
                    Get.snackbar(
                      'Notifications',
                      'Aucune nouvelle notification',
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      icon: const Icon(Icons.notifications,
                          color: Colors.white),
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
              ),
              if (needsAttention > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        needsAttention > 9 ? '9+' : '$needsAttention',
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
  }
}

class _CartButton extends StatelessWidget {
  final Color color;
  const _CartButton({this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Obx(() {
      final count = cart.totalItems;
      return SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: color),
              onPressed: () => Get.to(
                () => const CartScreen(),
                transition: Transition.rightToLeft,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF412402)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
