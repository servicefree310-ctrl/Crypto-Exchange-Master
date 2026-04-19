import '../../domain/entities/currency_option_entity.dart';

class CurrencyOptionModel {
  const CurrencyOptionModel({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final String? icon;

  factory CurrencyOptionModel.fromJson(Map<String, dynamic> json) {
    return CurrencyOptionModel(
      value: json['value'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      if (icon != null) 'icon': icon,
    };
  }

  CurrencyOptionEntity toEntity() {
    return CurrencyOptionEntity(
      value: value,
      label: label,
      icon: icon,
    );
  }

  CurrencyOptionModel copyWith({
    String? value,
    String? label,
    String? icon,
  }) {
    return CurrencyOptionModel(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
    );
  }
}
