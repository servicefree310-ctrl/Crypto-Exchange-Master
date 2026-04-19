import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';

part 'eco_wallet_model.freezed.dart';
part 'eco_wallet_model.g.dart';

@freezed
class EcoWalletModel with _$EcoWalletModel {
  const factory EcoWalletModel({
    required String id,
    required String currency,
    required double balance,
    required String type,
    Map<String, dynamic>? address,
  }) = _EcoWalletModel;

  factory EcoWalletModel.fromJson(Map<String, dynamic> json) =>
      _$EcoWalletModelFromJson(json);
}

extension EcoWalletModelX on EcoWalletModel {
  EcoWalletEntity toEntity() {
    return EcoWalletEntity(
      id: id,
      currency: currency,
      balance: balance,
      type: type,
      address: address,
    );
  }
}
