import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/spot_deposit_transaction_entity.dart';

part 'spot_deposit_transaction_model.freezed.dart';
part 'spot_deposit_transaction_model.g.dart';

@freezed
class SpotDepositTransactionModel with _$SpotDepositTransactionModel {
  const factory SpotDepositTransactionModel({
    required String id,
    required String userId,
    required String walletId,
    required String type,
    required double amount,
    required String status,
    required String currency,
    required String chain,
    required String referenceId,
    Map<String, dynamic>? metadata,
    String? description,
    required DateTime createdAt,
  }) = _SpotDepositTransactionModel;

  factory SpotDepositTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$SpotDepositTransactionModelFromJson(json);
}

extension SpotDepositTransactionModelX on SpotDepositTransactionModel {
  SpotDepositTransactionEntity toEntity() {
    return SpotDepositTransactionEntity(
      id: id,
      userId: userId,
      walletId: walletId,
      type: type,
      amount: amount,
      status: status,
      currency: currency,
      chain: chain,
      referenceId: referenceId,
      metadata: metadata,
      description: description,
      createdAt: createdAt,
    );
  }
}
