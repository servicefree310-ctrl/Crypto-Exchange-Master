import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/withdraw_request_entity.dart';

part 'withdraw_request_model.freezed.dart';
part 'withdraw_request_model.g.dart';

@freezed
class WithdrawRequestModel with _$WithdrawRequestModel {
  const WithdrawRequestModel._();

  const factory WithdrawRequestModel({
    required String walletType,
    required String currency,
    required double amount,
    String? methodId,
    String? toAddress,
    String? chain,
    String? memo,
    Map<String, dynamic>? customFields,
  }) = _WithdrawRequestModel;

  factory WithdrawRequestModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawRequestModelFromJson(json);
}

extension WithdrawRequestModelX on WithdrawRequestModel {
  WithdrawRequestEntity toEntity() {
    return WithdrawRequestEntity(
      walletType: walletType,
      currency: currency,
      amount: amount,
      methodId: methodId,
      toAddress: toAddress,
      chain: chain,
      memo: memo,
      customFields: customFields,
    );
  }
}

extension WithdrawRequestEntityX on WithdrawRequestEntity {
  WithdrawRequestModel toModel() {
    return WithdrawRequestModel(
      walletType: walletType,
      currency: currency,
      amount: amount,
      methodId: methodId,
      toAddress: toAddress,
      chain: chain,
      memo: memo,
      customFields: customFields,
    );
  }
}
