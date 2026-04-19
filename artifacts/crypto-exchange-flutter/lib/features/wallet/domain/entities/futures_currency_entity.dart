import 'package:equatable/equatable.dart';

class FuturesCurrencyEntity extends Equatable {
  const FuturesCurrencyEntity({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final String icon;

  @override
  List<Object?> get props => [value, label, icon];

  FuturesCurrencyEntity copyWith({
    String? value,
    String? label,
    String? icon,
  }) {
    return FuturesCurrencyEntity(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
    );
  }
}
