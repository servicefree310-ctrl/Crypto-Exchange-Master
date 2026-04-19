import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/spot_currency_entity.dart';

part 'spot_currency_model.freezed.dart';
part 'spot_currency_model.g.dart';

@freezed
class SpotCurrencyModel with _$SpotCurrencyModel {
  const factory SpotCurrencyModel({
    required String value,
    required String label,
    String? icon,
  }) = _SpotCurrencyModel;

  factory SpotCurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$SpotCurrencyModelFromJson(json);
}

extension SpotCurrencyModelX on SpotCurrencyModel {
  SpotCurrencyEntity toEntity() {
    return SpotCurrencyEntity(
      value: value,
      label: label,
      icon: icon,
    );
  }
}
