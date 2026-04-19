import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/transfer_response_entity.dart';

part 'transfer_response_model.freezed.dart';
part 'transfer_response_model.g.dart';

@freezed
class TransferResponseModel with _$TransferResponseModel {
  const factory TransferResponseModel({
    required String message,
    required TransferTransactionModel fromTransfer,
    required TransferTransactionModel toTransfer,
    required String fromType,
    required String toType,
    required String fromCurrency,
    required String toCurrency,
  }) = _TransferResponseModel;

  factory TransferResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseModelFromJson(json);
}

@freezed
class TransferTransactionModel with _$TransferTransactionModel {
  const factory TransferTransactionModel({
    required String id,
    required String userId,
    required String walletId,
    required String type,
    required double amount,
    required double fee,
    required String status,
    required String description,
    required String? metadata,
    required String createdAt,
    required String updatedAt,
  }) = _TransferTransactionModel;

  factory TransferTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransferTransactionModelFromJson(json);
}

extension TransferResponseModelX on TransferResponseModel {
  TransferResponseEntity toEntity() {
    return TransferResponseEntity(
      message: message,
      fromTransfer: fromTransfer.toEntity(),
      toTransfer: toTransfer.toEntity(),
      fromType: fromType,
      toType: toType,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }
}

extension TransferTransactionModelX on TransferTransactionModel {
  TransferTransactionEntity toEntity() {
    return TransferTransactionEntity(
      id: id,
      userId: userId,
      walletId: walletId,
      type: type,
      amount: amount,
      fee: fee,
      status: status,
      description: description,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
