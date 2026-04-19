import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/transfer_request_entity.dart';

part 'transfer_request_model.freezed.dart';
part 'transfer_request_model.g.dart';

@freezed
class TransferRequestModel with _$TransferRequestModel {
  const factory TransferRequestModel({
    required String fromType, // FIAT, SPOT, ECO, FUTURES
    required String fromCurrency, // BTC, ETH, USD, etc.
    required double amount,
    required String transferType, // "wallet" or "client"

    // For wallet transfers
    String? toType, // Target wallet type
    String? toCurrency, // Target currency

    // For client transfers
    String? clientId, // Recipient UUID
  }) = _TransferRequestModel;

  factory TransferRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TransferRequestModelFromJson(json);
}

extension TransferRequestModelX on TransferRequestModel {
  TransferRequestEntity toEntity() {
    return TransferRequestEntity(
      fromType: fromType,
      fromCurrency: fromCurrency,
      amount: amount,
      transferType: transferType,
      toType: toType,
      toCurrency: toCurrency,
      clientId: clientId,
    );
  }
}

extension TransferRequestEntityX on TransferRequestEntity {
  TransferRequestModel toModel() {
    return TransferRequestModel(
      fromType: fromType,
      fromCurrency: fromCurrency,
      amount: amount,
      transferType: transferType,
      toType: toType,
      toCurrency: toCurrency,
      clientId: clientId,
    );
  }
}
