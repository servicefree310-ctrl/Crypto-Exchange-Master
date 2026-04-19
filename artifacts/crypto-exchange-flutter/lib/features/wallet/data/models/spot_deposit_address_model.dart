import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/spot_deposit_address_entity.dart';

part 'spot_deposit_address_model.freezed.dart';
part 'spot_deposit_address_model.g.dart';

@freezed
class SpotDepositAddressModel with _$SpotDepositAddressModel {
  const factory SpotDepositAddressModel({
    required String address,
    String? tag,
    required String network,
    required String currency,
    required bool trx,
  }) = _SpotDepositAddressModel;

  factory SpotDepositAddressModel.fromJson(Map<String, dynamic> json) =>
      _$SpotDepositAddressModelFromJson(json);
}

extension SpotDepositAddressModelX on SpotDepositAddressModel {
  SpotDepositAddressEntity toEntity() {
    return SpotDepositAddressEntity(
      address: address,
      tag: tag,
      network: network,
      currency: currency,
      trx: trx,
    );
  }
}
