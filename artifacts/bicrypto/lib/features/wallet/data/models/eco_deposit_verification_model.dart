import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';
import 'eco_transaction_model.dart';
import 'eco_wallet_model.dart';

part 'eco_deposit_verification_model.freezed.dart';
part 'eco_deposit_verification_model.g.dart';

@freezed
class EcoDepositVerificationModel with _$EcoDepositVerificationModel {
  const factory EcoDepositVerificationModel({
    required String status,
    required String message,
    EcoTransactionModel? transaction,
    EcoWalletModel? wallet,
    Map<String, dynamic>? trx,
    double? balance,
    String? currency,
    String? chain,
    String? method,
  }) = _EcoDepositVerificationModel;

  factory EcoDepositVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$EcoDepositVerificationModelFromJson(json);
}

extension EcoDepositVerificationModelX on EcoDepositVerificationModel {
  EcoDepositVerificationEntity toEntity() {
    return EcoDepositVerificationEntity(
      status: status,
      message: message,
      transaction: transaction?.toEntity(),
      wallet: wallet?.toEntity(),
      trx: trx,
      balance: balance,
      currency: currency,
      chain: chain,
      method: method,
    );
  }
}
