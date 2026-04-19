import 'package:equatable/equatable.dart';

class CurrencyOptionEntity extends Equatable {
  const CurrencyOptionEntity({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final String? icon;

  @override
  List<Object?> get props => [value, label, icon];

  CurrencyOptionEntity copyWith({
    String? value,
    String? label,
    String? icon,
  }) {
    return CurrencyOptionEntity(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
    );
  }
}
