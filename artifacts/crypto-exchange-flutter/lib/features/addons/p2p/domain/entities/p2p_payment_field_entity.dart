import 'package:equatable/equatable.dart';

enum PaymentMethodFieldType {
  text,
  number,
  email,
  phone,
  select,
  textarea,
  file,
  date,
}

class PaymentMethodField extends Equatable {
  const PaymentMethodField({
    required this.key,
    required this.type,
    required this.label,
    this.placeholder,
    this.required = false,
    this.options,
    this.validation,
  });

  final String key;
  final PaymentMethodFieldType type;
  final String label;
  final String? placeholder;
  final bool required;
  final List<String>? options; // For select type
  final Map<String, dynamic>? validation;

  @override
  List<Object?> get props => [
        key,
        type,
        label,
        placeholder,
        required,
        options,
        validation,
      ];

  PaymentMethodField copyWith({
    String? key,
    PaymentMethodFieldType? type,
    String? label,
    String? placeholder,
    bool? required,
    List<String>? options,
    Map<String, dynamic>? validation,
  }) {
    return PaymentMethodField(
      key: key ?? this.key,
      type: type ?? this.type,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      required: required ?? this.required,
      options: options ?? this.options,
      validation: validation ?? this.validation,
    );
  }
}
