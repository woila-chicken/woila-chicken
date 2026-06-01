import 'package:get/get.dart';
import '../../../core/models/product.dart';

enum SortOption { prixCroissant, prixDecroissant, poidsAsc, noteDesc }

enum WeightFilter { all, light, medium, heavy }

enum PriceFilter { all, cheap, mid, expensive }

enum DeliveryFilter { all, delivery, pickup }

class CatalogueController extends GetxController {
  // ── Recherche ─────────────────────────────────────────────────
  final searchQuery = ''.obs;

  // ── Filtres ───────────────────────────────────────────────────
  final selectedFarm = 'Toutes'.obs;
  final weightFilter = WeightFilter.all.obs;
  final priceFilter = PriceFilter.all.obs;
  final deliveryFilter = DeliveryFilter.all.obs;
  final sortOption = SortOption.noteDesc.obs;

  // ── Liste des fermes disponibles ──────────────────────────────
  List<String> get farms => [
        'Toutes',
        ...mockProducts.map((p) => p.farmName).toSet().toList()..sort(),
      ];

  // ── Produits filtrés + triés ──────────────────────────────────
  List<Product> get filteredProducts {
    var list = mockProducts.where((p) {
      // Recherche texte
      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.farmName.toLowerCase().contains(q)) {
          return false;
        }
      }

      // Filtre ferme
      if (selectedFarm.value != 'Toutes' &&
          p.farmName != selectedFarm.value) {
        return false;
      }

      // Filtre poids
      switch (weightFilter.value) {
        case WeightFilter.light:
          if (p.weightKg >= 2.0) return false;
          break;
        case WeightFilter.medium:
          if (p.weightKg < 2.0 || p.weightKg > 3.0) return false;
          break;
        case WeightFilter.heavy:
          if (p.weightKg <= 3.0) return false;
          break;
        default:
          break;
      }

      // Filtre prix
      switch (priceFilter.value) {
        case PriceFilter.cheap:
          if (p.pricefcfa >= 3000) return false;
          break;
        case PriceFilter.mid:
          if (p.pricefcfa < 3000 || p.pricefcfa > 5000) return false;
          break;
        case PriceFilter.expensive:
          if (p.pricefcfa <= 5000) return false;
          break;
        default:
          break;
      }

      // Filtre livraison
      switch (deliveryFilter.value) {
        case DeliveryFilter.delivery:
          if (!p.deliveryAvailable) return false;
          break;
        case DeliveryFilter.pickup:
          if (!p.pickupAvailable) return false;
          break;
        default:
          break;
      }

      return true;
    }).toList();

    // Tri
    switch (sortOption.value) {
      case SortOption.prixCroissant:
        list.sort((a, b) => a.pricefcfa.compareTo(b.pricefcfa));
        break;
      case SortOption.prixDecroissant:
        list.sort((a, b) => b.pricefcfa.compareTo(a.pricefcfa));
        break;
      case SortOption.poidsAsc:
        list.sort((a, b) => a.weightKg.compareTo(b.weightKg));
        break;
      case SortOption.noteDesc:
        list.sort((a, b) => b.farmRating.compareTo(a.farmRating));
        break;
    }

    return list;
  }

  // ── Méthodes de mise à jour ───────────────────────────────────
  void setSearch(String q) => searchQuery.value = q;
  void setFarm(String farm) => selectedFarm.value = farm;
  void setWeight(WeightFilter f) => weightFilter.value = f;
  void setPrice(PriceFilter f) => priceFilter.value = f;
  void setDelivery(DeliveryFilter f) => deliveryFilter.value = f;
  void setSort(SortOption s) => sortOption.value = s;

  void resetFilters() {
    searchQuery.value = '';
    selectedFarm.value = 'Toutes';
    weightFilter.value = WeightFilter.all;
    priceFilter.value = PriceFilter.all;
    deliveryFilter.value = DeliveryFilter.all;
    sortOption.value = SortOption.noteDesc;
  }

  bool get hasActiveFilters =>
      selectedFarm.value != 'Toutes' ||
      weightFilter.value != WeightFilter.all ||
      priceFilter.value != PriceFilter.all ||
      deliveryFilter.value != DeliveryFilter.all;
}
