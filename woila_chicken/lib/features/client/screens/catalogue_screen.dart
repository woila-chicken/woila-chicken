import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../controllers/catalogue_controller.dart';

class CatalogueScreen extends StatelessWidget {
  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CatalogueController());
    return const ResponsiveLayout(
      desktop: _DesktopCatalogue(),
      mobile: _MobileCatalogue(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  DESKTOP — filtres en sidebar fixe gauche, produits à droite
// ─────────────────────────────────────────────────────────────────
class _DesktopCatalogue extends StatelessWidget {
  const _DesktopCatalogue();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catalogue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {}),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panneau filtres
          Container(
            width: 240,
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _FiltersPanel(),
            ),
          ),
          Container(width: 1, color: AppColors.divider),
          // Grille produits
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _SearchSortBar(),
                ),
                const SizedBox(height: 12),
                const Expanded(child: _ProductsGrid(crossAxisCount: 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  MOBILE — filtres dans un bottom sheet, produits en grille 2 col
// ─────────────────────────────────────────────────────────────────
class _MobileCatalogue extends StatelessWidget {
  const _MobileCatalogue();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CatalogueController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catalogue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => ctrl.hasActiveFilters
              ? Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () => _showFiltersSheet(context),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _showFiltersSheet(context),
                )),
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SearchSortBar(),
          ),
          const SizedBox(height: 8),
          // Chips de filtres actifs
          Obx(() {
            if (!ctrl.hasActiveFilters) return const SizedBox.shrink();
            return SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (ctrl.selectedFarm.value != 'Toutes')
                    _ActiveChip(
                        label: ctrl.selectedFarm.value,
                        onRemove: () => ctrl.setFarm('Toutes')),
                  if (ctrl.weightFilter.value != WeightFilter.all)
                    _ActiveChip(
                        label: _weightLabel(ctrl.weightFilter.value),
                        onRemove: () => ctrl.setWeight(WeightFilter.all)),
                  if (ctrl.priceFilter.value != PriceFilter.all)
                    _ActiveChip(
                        label: _priceLabel(ctrl.priceFilter.value),
                        onRemove: () => ctrl.setPrice(PriceFilter.all)),
                  if (ctrl.deliveryFilter.value != DeliveryFilter.all)
                    _ActiveChip(
                        label: _deliveryLabel(ctrl.deliveryFilter.value),
                        onRemove: () =>
                            ctrl.setDelivery(DeliveryFilter.all)),
                ],
              ),
            );
          }),
          const Expanded(child: _ProductsGrid(crossAxisCount: 2)),
        ],
    ));
  }

  void _showFiltersSheet(BuildContext context) {
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
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Filtres',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Get.find<CatalogueController>().resetFilters();
                      Get.back();
                    },
                    child: const Text('Réinitialiser',
                        style: TextStyle(
                            color: AppColors.primary, fontFamily: 'Poppins')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _FiltersPanel(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Panneau de filtres (partagé desktop sidebar + mobile sheet)
// ─────────────────────────────────────────────────────────────────
class _FiltersPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CatalogueController>();
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Réinitialiser (desktop seulement)
            if (ctrl.hasActiveFilters)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: ctrl.resetFilters,
                  child: const Text('Réinitialiser',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                          fontSize: 12)),
                ),
              ),

            // ── Ferme ──────────────────────────────────────────
            const _FilterSection(title: 'Ferme'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ctrl.farms
                  .map((farm) => _FilterChip(
                        label: farm,
                        isSelected: ctrl.selectedFarm.value == farm,
                        onTap: () => ctrl.setFarm(farm),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── Poids ──────────────────────────────────────────
            const _FilterSection(title: 'Poids'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _FilterChip(
                    label: 'Tout',
                    isSelected:
                        ctrl.weightFilter.value == WeightFilter.all,
                    onTap: () => ctrl.setWeight(WeightFilter.all)),
                _FilterChip(
                    label: '< 2 kg',
                    isSelected:
                        ctrl.weightFilter.value == WeightFilter.light,
                    onTap: () => ctrl.setWeight(WeightFilter.light)),
                _FilterChip(
                    label: '2 – 3 kg',
                    isSelected:
                        ctrl.weightFilter.value == WeightFilter.medium,
                    onTap: () => ctrl.setWeight(WeightFilter.medium)),
                _FilterChip(
                    label: '> 3 kg',
                    isSelected:
                        ctrl.weightFilter.value == WeightFilter.heavy,
                    onTap: () => ctrl.setWeight(WeightFilter.heavy)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Prix ───────────────────────────────────────────
            const _FilterSection(title: 'Prix'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _FilterChip(
                    label: 'Tout',
                    isSelected:
                        ctrl.priceFilter.value == PriceFilter.all,
                    onTap: () => ctrl.setPrice(PriceFilter.all)),
                _FilterChip(
                    label: '< 3 000 F',
                    isSelected:
                        ctrl.priceFilter.value == PriceFilter.cheap,
                    onTap: () => ctrl.setPrice(PriceFilter.cheap)),
                _FilterChip(
                    label: '3 000 – 5 000 F',
                    isSelected:
                        ctrl.priceFilter.value == PriceFilter.mid,
                    onTap: () => ctrl.setPrice(PriceFilter.mid)),
                _FilterChip(
                    label: '> 5 000 F',
                    isSelected:
                        ctrl.priceFilter.value == PriceFilter.expensive,
                    onTap: () => ctrl.setPrice(PriceFilter.expensive)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Mode de livraison ──────────────────────────────
            const _FilterSection(title: 'Mode de retrait'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _FilterChip(
                    label: 'Tout',
                    isSelected:
                        ctrl.deliveryFilter.value == DeliveryFilter.all,
                    onTap: () => ctrl.setDelivery(DeliveryFilter.all)),
                _FilterChip(
                    label: 'Livraison',
                    isSelected: ctrl.deliveryFilter.value ==
                        DeliveryFilter.delivery,
                    onTap: () =>
                        ctrl.setDelivery(DeliveryFilter.delivery)),
                _FilterChip(
                    label: 'Retrait ferme',
                    isSelected:
                        ctrl.deliveryFilter.value == DeliveryFilter.pickup,
                    onTap: () =>
                        ctrl.setDelivery(DeliveryFilter.pickup)),
              ],
            ),
          ],
        ));
  }
}

// ─────────────────────────────────────────────────────────────────
//  Barre recherche + tri
// ─────────────────────────────────────────────────────────────────
class _SearchSortBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CatalogueController>();
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: ctrl.setSearch,
            decoration: const InputDecoration(
              hintText: 'Rechercher par nom, ferme...',
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
        const SizedBox(width: 12),
        Obx(() => PopupMenuButton<SortOption>(
              onSelected: ctrl.setSort,
              initialValue: ctrl.sortOption.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_vert,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(_sortLabel(ctrl.sortOption.value),
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                _sortMenuItem(SortOption.noteDesc, 'Meilleures notes'),
                _sortMenuItem(SortOption.prixCroissant, 'Prix croissant'),
                _sortMenuItem(SortOption.prixDecroissant, 'Prix décroissant'),
                _sortMenuItem(SortOption.poidsAsc, 'Poids croissant'),
              ],
            )),
      ],
    );
  }

  PopupMenuItem<SortOption> _sortMenuItem(SortOption opt, String label) =>
      PopupMenuItem(
        value: opt,
        child: Text(label,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Grille produits réactive
// ─────────────────────────────────────────────────────────────────
class _ProductsGrid extends StatelessWidget {
  final int crossAxisCount;
  const _ProductsGrid({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CatalogueController>();
    return Obx(() {
  if (ctrl.isLoading.value) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
  final products = ctrl.filteredProducts;
  if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text('Aucun produit trouvé',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: ctrl.resetFilters,
                child: const Text('Réinitialiser les filtres',
                    style: TextStyle(
                        color: AppColors.primary, fontFamily: 'Poppins')),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          // Hauteur fixe calibrée : image 110 + infos ~120 = 230
          mainAxisExtent: 230,
        ),
        itemCount: products.length,
        itemBuilder: (context, i) => ProductCard(product: products[i]),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widgets utilitaires
// ─────────────────────────────────────────────────────────────────
class _FilterSection extends StatelessWidget {
  final String title;
  const _FilterSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
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
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.primary)),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers labels ───────────────────────────────────────────────
String _sortLabel(SortOption opt) {
  switch (opt) {
    case SortOption.noteDesc:
      return 'Meilleures notes';
    case SortOption.prixCroissant:
      return 'Prix croissant';
    case SortOption.prixDecroissant:
      return 'Prix décroissant';
    case SortOption.poidsAsc:
      return 'Poids croissant';
  }
}

String _weightLabel(WeightFilter f) {
  switch (f) {
    case WeightFilter.light:
      return '< 2 kg';
    case WeightFilter.medium:
      return '2 – 3 kg';
    case WeightFilter.heavy:
      return '> 3 kg';
    default:
      return '';
  }
}

String _priceLabel(PriceFilter f) {
  switch (f) {
    case PriceFilter.cheap:
      return '< 3 000 F';
    case PriceFilter.mid:
      return '3 000 – 5 000 F';
    case PriceFilter.expensive:
      return '> 5 000 F';
    default:
      return '';
  }
}

String _deliveryLabel(DeliveryFilter f) {
  switch (f) {
    case DeliveryFilter.delivery:
      return 'Livraison';
    case DeliveryFilter.pickup:
      return 'Retrait';
    default:
      return '';
  }
}
