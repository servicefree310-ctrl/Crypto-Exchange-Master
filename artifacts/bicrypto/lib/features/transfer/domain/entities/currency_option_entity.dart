import 'package:equatable/equatable.dart';

class CurrencyOptionEntity extends Equatable {
  final String value; // Currency code (BTC, ETH, USD)
  final String label; // Display label
  final String? icon; // Currency icon URL
  final double? balance; // Available balance

  const CurrencyOptionEntity({
    required this.value,
    required this.label,
    this.icon,
    this.balance,
  });

  @override
  List<Object?> get props => [value, label, icon, balance];

  CurrencyOptionEntity copyWith({
    String? value,
    String? label,
    String? icon,
    double? balance,
  }) {
    return CurrencyOptionEntity(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
    );
  }
}
