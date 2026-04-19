import 'package:equatable/equatable.dart';

class WithdrawMethodEntity extends Equatable {
  final String id;
  final String title;
  final String? instructions;
  final double? fixedFee;
  final double? percentageFee;
  final double? minAmount;
  final double? maxAmount;
  final String? network;
  final List<CustomFieldEntity>? customFields;
  final String? image;
  final bool isActive;

  const WithdrawMethodEntity({
    required this.id,
    required this.title,
    this.instructions,
    this.fixedFee,
    this.percentageFee,
    this.minAmount,
    this.maxAmount,
    this.network,
    this.customFields,
    this.image,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        instructions,
        fixedFee,
        percentageFee,
        minAmount,
        maxAmount,
        network,
        customFields,
        image,
        isActive,
      ];

  WithdrawMethodEntity copyWith({
    String? id,
    String? title,
    String? instructions,
    double? fixedFee,
    double? percentageFee,
    double? minAmount,
    double? maxAmount,
    String? network,
    List<CustomFieldEntity>? customFields,
    String? image,
    bool? isActive,
  }) {
    return WithdrawMethodEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      fixedFee: fixedFee ?? this.fixedFee,
      percentageFee: percentageFee ?? this.percentageFee,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      network: network ?? this.network,
      customFields: customFields ?? this.customFields,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CustomFieldEntity extends Equatable {
  final String name;
  final String title;
  final String type;
  final bool required;
  final String? placeholder;
  final String? defaultValue;
  final List<String>? options;

  const CustomFieldEntity({
    required this.name,
    required this.title,
    required this.type,
    required this.required,
    this.placeholder,
    this.defaultValue,
    this.options,
  });

  @override
  List<Object?> get props => [
        name,
        title,
        type,
        required,
        placeholder,
        defaultValue,
        options,
      ];
}
