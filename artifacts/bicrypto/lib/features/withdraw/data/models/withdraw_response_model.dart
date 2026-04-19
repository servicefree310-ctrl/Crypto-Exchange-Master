import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/withdraw_response_entity.dart';

part 'withdraw_response_model.freezed.dart';
part 'withdraw_response_model.g.dart';

@freezed
class WithdrawResponseModel with _$WithdrawResponseModel {
  const WithdrawResponseModel._();

  const factory WithdrawResponseModel({
    required String message,
    WithdrawTransactionModel? transaction,
    String? currency,
    String? method,
    double? balance,
  }) = _WithdrawResponseModel;

  factory WithdrawResponseModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawResponseModelFromJson(json);
}

@freezed
class WithdrawTransactionModel with _$WithdrawTransactionModel {
  const WithdrawTransactionModel._();

  const factory WithdrawTransactionModel({
    required String id,
    required String userId,
    required String walletId,
    required String type,
    required double amount,
    required double fee,
    required String status,
    String? description,
    Map<String, dynamic>? metadata,
    String? referenceId,
    required String createdAt,
    String? updatedAt,
  }) = _WithdrawTransactionModel;

  factory WithdrawTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawTransactionModelFromJson(json);
}

extension WithdrawResponseModelX on WithdrawResponseModel {
  WithdrawResponseEntity toEntity() {
    return WithdrawResponseEntity(
      message: message,
      transaction: transaction?.toEntity(),
      currency: currency,
      method: method,
      balance: balance,
    );
  }
}

extension WithdrawTransactionModelX on WithdrawTransactionModel {
  WithdrawTransactionEntity toEntity() {
    return WithdrawTransactionEntity(
      id: id,
      userId: userId,
      walletId: walletId,
      type: type,
      amount: amount,
      fee: fee,
      status: status,
      description: description,
      metadata: metadata,
      referenceId: referenceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
