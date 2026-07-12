class Product {
  final String id;
  final String farmId;
  final String name;
  final double weightKg;
  final double pricefcfa;
  final String farmName;
  final double farmRating;
  final bool hasSanitaryCert;
  final bool deliveryAvailable;
  final bool pickupAvailable;
  final String availability;
  final String? imageUrl;
  final int stockQuantity;

  const Product({
    required this.id,
    this.farmId = '',
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
    this.stockQuantity = 0,
  });
}
