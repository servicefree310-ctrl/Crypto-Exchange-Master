import '../../domain/entities/deposit_method_entity.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class DepositMethodModel {
  const DepositMethodModel({
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

  factory DepositMethodModel.fromJson(Map<String, dynamic> json) {
    // Parse customFields - it can be either a string (JSON array/object) or an actual object
    Map<String, dynamic>? parsedCustomFields;
    if (json['customFields'] != null) {
      if (json['customFields'] is String) {
        // If it's a JSON string, parse it
        try {
          final parsed = jsonDecode(json['customFields'] as String);
          if (parsed is List) {
            // Convert array to map format
            parsedCustomFields = {
              'fields': parsed,
            };
          } else if (parsed is Map) {
            parsedCustomFields = Map<String, dynamic>.from(parsed);
          }
        } catch (e) {
          dev.log('Error parsing customFields JSON: $e');
          parsedCustomFields = null;
        }
      } else if (json['customFields'] is Map) {
        // If it's already a map, use it directly
        parsedCustomFields =
            Map<String, dynamic>.from(json['customFields'] as Map);
      }
    }

    return DepositMethodModel(
      id: json['id'] as String,
      // Use title as name if name is not provided
      name: (json['name'] ?? json['title']) as String,
      title: json['title'] as String,
      instructions: json['instructions'] as String,
      image: json['image'] as String?,
      fixedFee: json['fixedFee']?.toDouble(),
      percentageFee: json['percentageFee']?.toDouble(),
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      customFields: parsedCustomFields,
      status: json['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'instructions': instructions,
      'image': image,
      'fixedFee': fixedFee,
      'percentageFee': percentageFee,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'customFields': customFields,
      'status': status,
    };
  }
}

extension DepositMethodModelX on DepositMethodModel {
  DepositMethodEntity toEntity() {
    return DepositMethodEntity(
      id: id,
      name: name,
      title: title,
      instructions: instructions,
      image: image,
      fixedFee: fixedFee,
      percentageFee: percentageFee,
      minAmount: minAmount,
      maxAmount: maxAmount,
      customFields: customFields,
      status: status,
    );
  }
}
