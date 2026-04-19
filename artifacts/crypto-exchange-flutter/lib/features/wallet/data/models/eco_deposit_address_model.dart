import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/eco_deposit_address_entity.dart';

part 'eco_deposit_address_model.freezed.dart';
part 'eco_deposit_address_model.g.dart';

@freezed
class EcoDepositAddressModel with _$EcoDepositAddressModel {
  const factory EcoDepositAddressModel({
    required String address,
    required String currency,
    required String chain,
    required String contractType,
    String? network,
    @Default(false) bool locked, // For NO_PERMIT tracking
    String? id,
    String? status,
  }) = _EcoDepositAddressModel;

  factory EcoDepositAddressModel.fromJson(Map<String, dynamic> json) =>
      _$EcoDepositAddressModelFromJson(json);
}

extension EcoDepositAddressModelX on EcoDepositAddressModel {
  EcoDepositAddressEntity toEntity() {
    return EcoDepositAddressEntity(
      address: address,
      currency: currency,
      chain: chain,
      contractType: contractType,
      network: network,
      locked: locked,
      id: id,
      status: status,
    );
  }
}
