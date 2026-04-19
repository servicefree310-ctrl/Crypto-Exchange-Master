class LaunchPlanEntity {
  const LaunchPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.walletType,
    required this.features,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String walletType;
  final Map<String, dynamic> features; // parsed JSON features
}
