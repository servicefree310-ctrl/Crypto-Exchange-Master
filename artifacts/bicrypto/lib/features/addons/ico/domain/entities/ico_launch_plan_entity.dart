import 'package:equatable/equatable.dart';

class IcoLaunchPlanEntity extends Equatable {
  const IcoLaunchPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isActive = true,
    this.isPopular = false,
    this.discount,
    this.maxOfferings,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // in days
  final List<String> features;
  final bool isActive;
  final bool isPopular;
  final double? discount;
  final int? maxOfferings;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        duration,
        features,
        isActive,
        isPopular,
        discount,
        maxOfferings,
      ];
}
