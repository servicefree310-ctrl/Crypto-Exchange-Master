import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/withdraw_method_entity.dart';

part 'withdraw_method_model.freezed.dart';
part 'withdraw_method_model.g.dart';

@freezed
class WithdrawMethodModel with _$WithdrawMethodModel {
  const WithdrawMethodModel._();

  const factory WithdrawMethodModel({
    required String id,
    required String title,
    String? instructions,
    double? fixedFee,
    double? percentageFee,
    double? minAmount,
    double? maxAmount,
    String? network,
    String? customFields, // JSON string
    String? image,
    @Default(true) bool isActive,
  }) = _WithdrawMethodModel;

  factory WithdrawMethodModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawMethodModelFromJson(json);
}

extension WithdrawMethodModelX on WithdrawMethodModel {
  WithdrawMethodEntity toEntity() {
    List<CustomFieldEntity>? parsedCustomFields;

    if (customFields != null && customFields!.isNotEmpty) {
      try {
        final List<dynamic> fields = json.decode(customFields!);
        parsedCustomFields = fields
            .map((field) => CustomFieldEntity(
                  name: field['name'] ?? '',
                  title: field['title'] ?? '',
                  type: field['type'] ?? 'text',
                  required: field['required'] ?? false,
                  placeholder: field['placeholder'],
                  defaultValue: field['defaultValue'],
                  options: field['options'] != null
                      ? List<String>.from(field['options'])
                      : null,
                ))
            .toList();
      } catch (e) {
        // Handle parsing error
        parsedCustomFields = null;
      }
    }

    return WithdrawMethodEntity(
      id: id,
      title: title,
      instructions: instructions,
      fixedFee: fixedFee,
      percentageFee: percentageFee,
      minAmount: minAmount,
      maxAmount: maxAmount,
      network: network,
      customFields: parsedCustomFields,
      image: image,
      isActive: isActive,
    );
  }
}
