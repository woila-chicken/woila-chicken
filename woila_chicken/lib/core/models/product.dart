class Product {
  final String id;
  final String name;
  final double weightKg;
  final double pricefcfa;
  final String farmName;
  final double farmRating;
  final bool hasSanitaryCert;
  final bool deliveryAvailable;
  final bool pickupAvailable;
  final String availability; // 'immediate' | 'tomorrow' | 'next_week'
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.pricefcfa,
    required this.farmName,
    required this.farmRating,
    required this.hasSanitaryCert,
    required this.deliveryAvailable,
    required this.pickupAvailable,
    required this.availability,
    this.imageUrl,
  });

  String get formattedPrice =>
      '${pricefcfa.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';

  String get availabilityLabel {
    switch (availability) {
      case 'immediate':
        return 'Disponible maintenant';
      case 'tomorrow':
        return 'Disponible demain';
      case 'next_week':
        return 'Disponible la semaine prochaine';
      default:
        return 'Disponibilité inconnue';
    }
  }
}

// ─── Données mock (seront remplacées par Firebase) ────────────────
const mockProducts = [
  Product(
    id: 'p1',
    name: 'Poulet fermier',
    weightKg: 2.0,
    pricefcfa: 3500,
    farmName: 'Ferme Koné',
    farmRating: 4.9,
    hasSanitaryCert: true,
    deliveryAvailable: true,
    pickupAvailable: true,
    availability: 'immediate',
  ),
  Product(
    id: 'p2',
    name: 'Poulet local',
    weightKg: 1.8,
    pricefcfa: 2800,
    farmName: 'Ferme Alhadji',
    farmRating: 4.7,
    hasSanitaryCert: true,
    deliveryAvailable: false,
    pickupAvailable: true,
    availability: 'immediate',
  ),
  Product(
    id: 'p3',
    name: 'Gros poulet',
    weightKg: 2.5,
    pricefcfa: 4200,
    farmName: 'Ferme Bougué',
    farmRating: 4.8,
    hasSanitaryCert: true,
    deliveryAvailable: true,
    pickupAvailable: true,
    availability: 'tomorrow',
  ),
  Product(
    id: 'p4',
    name: 'Poulet label rouge',
    weightKg: 2.2,
    pricefcfa: 3900,
    farmName: 'Ferme Sadou',
    farmRating: 4.6,
    hasSanitaryCert: true,
    deliveryAvailable: true,
    pickupAvailable: false,
    availability: 'immediate',
  ),
  Product(
    id: 'p5',
    name: 'Poulet bio',
    weightKg: 2.2,
    pricefcfa: 4500,
    farmName: 'Ferme Hamidou',
    farmRating: 5.0,
    hasSanitaryCert: true,
    deliveryAvailable: true,
    pickupAvailable: true,
    availability: 'immediate',
  ),
  Product(
    id: 'p6',
    name: 'Poulet standard',
    weightKg: 1.5,
    pricefcfa: 2200,
    farmName: 'Ferme Koné',
    farmRating: 4.5,
    hasSanitaryCert: false,
    deliveryAvailable: true,
    pickupAvailable: true,
    availability: 'next_week',
  ),
  Product(
    id: 'p7',
    name: 'Poulet de chair',
    weightKg: 3.0,
    pricefcfa: 5100,
    farmName: 'Ferme Alhadji',
    farmRating: 4.7,
    hasSanitaryCert: true,
    deliveryAvailable: false,
    pickupAvailable: true,
    availability: 'immediate',
  ),
  Product(
    id: 'p8',
    name: 'Poulet fermier XL',
    weightKg: 3.5,
    pricefcfa: 5800,
    farmName: 'Ferme Bougué',
    farmRating: 4.8,
    hasSanitaryCert: true,
    deliveryAvailable: true,
    pickupAvailable: true,
    availability: 'tomorrow',
  ),
];
