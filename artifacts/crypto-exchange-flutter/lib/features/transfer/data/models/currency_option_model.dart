import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/currency_option_entity.dart';

part 'currency_option_model.freezed.dart';
part 'currency_option_model.g.dart';

@freezed
class CurrencyOptionModel with _$CurrencyOptionModel {
  const factory CurrencyOptionModel({
    required String value, // Currency code (BTC, ETH, USD)
    required String label, // Display label
    String? icon, // Currency icon URL
    double? balance, // Available balance
  }) = _CurrencyOptionModel;

  factory CurrencyOptionModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyOptionModelFromJson(json);
}

extension CurrencyOptionModelX on CurrencyOptionModel {
  CurrencyOptionEntity toEntity() {
    return CurrencyOptionEntity(
      value: value,
      label: label,
      icon: icon,
      balance: balance,
    );
  }
}
