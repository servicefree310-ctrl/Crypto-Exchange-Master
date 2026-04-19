import 'package:equatable/equatable.dart';

class DepositGatewayEntity extends Equatable {
  const DepositGatewayEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.type,
    this.image,
    this.alias,
    this.currencies,
    this.fixedFee,
    this.percentageFee,
    this.minAmount,
    this.maxAmount,
    this.status = true,
    this.version,
    this.productId,
  });

  final String id;
  final String name;
  final String title;
  final String description;
  final String type; // FIAT or CRYPTO
  final String? image;
  final String? alias; // stripe, paypal, etc.
  final List<String>? currencies;
  final double? fixedFee;
  final double? percentageFee;
  final double? minAmount;
  final double? maxAmount;
  final bool status;
  final String? version;
  final String? productId;

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        description,
        type,
        image,
        alias,
        currencies,
        fixedFee,
        percentageFee,
        minAmount,
        maxAmount,
        status,
        version,
        productId,
      ];

  DepositGatewayEntity copyWith({
    String? id,
    String? name,
    String? title,
    String? description,
    String? type,
    String? image,
    String? alias,
    List<String>? currencies,
    double? fixedFee,
    double? percentageFee,
    double? minAmount,
    double? maxAmount,
    bool? status,
    String? version,
    String? productId,
  }) {
    return DepositGatewayEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      image: image ?? this.image,
      alias: alias ?? this.alias,
      currencies: currencies ?? this.currencies,
      fixedFee: fixedFee ?? this.fixedFee,
      percentageFee: percentageFee ?? this.percentageFee,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      status: status ?? this.status,
      version: version ?? this.version,
      productId: productId ?? this.productId,
    );
  }
}
