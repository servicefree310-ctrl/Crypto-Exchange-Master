import '../../domain/entities/deposit_gateway_entity.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class DepositGatewayModel {
  const DepositGatewayModel({
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
  final String type;
  final String? image;
  final String? alias;
  final List<String>? currencies;
  final double? fixedFee;
  final double? percentageFee;
  final double? minAmount;
  final double? maxAmount;
  final bool status;
  final String? version;
  final String? productId;

  factory DepositGatewayModel.fromJson(Map<String, dynamic> json) {
    // Parse currencies - it can be either a string (JSON array) or an actual array
    List<String>? parsedCurrencies;
    if (json['currencies'] != null) {
      if (json['currencies'] is String) {
        // If it's a JSON string, parse it
        try {
          final parsed = jsonDecode(json['currencies'] as String);
          if (parsed is List) {
            parsedCurrencies = List<String>.from(parsed);
          }
        } catch (e) {
          dev.log('Error parsing currencies JSON: $e');
          parsedCurrencies = null;
        }
      } else if (json['currencies'] is List) {
        // If it's already a list, use it directly
        parsedCurrencies = List<String>.from(json['currencies'] as List);
      }
    }

    return DepositGatewayModel(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
      alias: json['alias'] as String?,
      currencies: parsedCurrencies,
      fixedFee: json['fixedFee']?.toDouble(),
      percentageFee: json['percentageFee']?.toDouble(),
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      status: json['status'] as bool? ?? true,
      version: json['version'] as String?,
      productId: json['productId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'type': type,
      'image': image,
      'alias': alias,
      'currencies': currencies,
      'fixedFee': fixedFee,
      'percentageFee': percentageFee,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'status': status,
      'version': version,
      'productId': productId,
    };
  }
}

extension DepositGatewayModelX on DepositGatewayModel {
  DepositGatewayEntity toEntity() {
    return DepositGatewayEntity(
      id: id,
      name: name,
      title: title,
      description: description,
      type: type,
      image: image,
      alias: alias,
      currencies: currencies,
      fixedFee: fixedFee,
      percentageFee: percentageFee,
      minAmount: minAmount,
      maxAmount: maxAmount,
      status: status,
      version: version,
      productId: productId,
    );
  }
}
