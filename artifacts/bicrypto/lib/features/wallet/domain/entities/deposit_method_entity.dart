import 'package:equatable/equatable.dart';

class DepositMethodEntity extends Equatable {
  const DepositMethodEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.instructions,
    this.image,
    this.fixedFee,
    this.percentageFee,
    this.minAmount,
    this.maxAmount,
    this.customFields,
    this.status = true,
  });

  final String id;
  final String name;
  final String title;
  final String instructions;
  final String? image;
  final double? fixedFee;
  final double? percentageFee;
  final double? minAmount;
  final double? maxAmount;
  final Map<String, dynamic>? customFields;
  final bool status;

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        instructions,
        image,
        fixedFee,
        percentageFee,
        minAmount,
        maxAmount,
        customFields,
        status,
      ];

  DepositMethodEntity copyWith({
    String? id,
    String? name,
    String? title,
    String? instructions,
    String? image,
    double? fixedFee,
    double? percentageFee,
    double? minAmount,
    double? maxAmount,
    Map<String, dynamic>? customFields,
    bool? status,
  }) {
    return DepositMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      image: image ?? this.image,
      fixedFee: fixedFee ?? this.fixedFee,
      percentageFee: percentageFee ?? this.percentageFee,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      customFields: customFields ?? this.customFields,
      status: status ?? this.status,
    );
  }
}
