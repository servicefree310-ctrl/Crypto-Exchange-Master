import 'package:equatable/equatable.dart';

class SpotCurrencyEntity extends Equatable {
  const SpotCurrencyEntity({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final String? icon;

  @override
  List<Object?> get props => [value, label, icon];

  SpotCurrencyEntity copyWith({
    String? value,
    String? label,
    String? icon,
  }) {
    return SpotCurrencyEntity(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
    );
  }
}
