import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.available,
    this.userId,
    this.processingTime,
    this.fees,
    this.instructions,
    this.popularityRank,
  });

  final String id;
  final String? userId; // Present for custom methods
  final String name;
  final String icon;
  final String description;
  final String? processingTime;
  final String? fees;
  final String? instructions; // For custom methods
  final bool available;
  final int? popularityRank;

  // Derived properties
  bool get isCustom => userId != null;
  String get type => 'payment_method'; // Default type for compatibility

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        icon,
        description,
        processingTime,
        fees,
        instructions,
        available,
        popularityRank,
      ];

  PaymentMethodEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? description,
    String? processingTime,
    String? fees,
    String? instructions,
    bool? available,
    int? popularityRank,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      processingTime: processingTime ?? this.processingTime,
      fees: fees ?? this.fees,
      instructions: instructions ?? this.instructions,
      available: available ?? this.available,
      popularityRank: popularityRank ?? this.popularityRank,
    );
  }
}
