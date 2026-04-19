import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/futures_currency_entity.dart';

part 'futures_currency_model.freezed.dart';
part 'futures_currency_model.g.dart';

@freezed
class FuturesCurrencyModel with _$FuturesCurrencyModel {
  const factory FuturesCurrencyModel({
    required String value,
    required String label,
    required String icon,
  }) = _FuturesCurrencyModel;

  factory FuturesCurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$FuturesCurrencyModelFromJson(json);
}

extension FuturesCurrencyModelX on FuturesCurrencyModel {
  FuturesCurrencyEntity toEntity() {
    return FuturesCurrencyEntity(
      value: value,
      label: label,
      icon: icon,
    );
  }
}
