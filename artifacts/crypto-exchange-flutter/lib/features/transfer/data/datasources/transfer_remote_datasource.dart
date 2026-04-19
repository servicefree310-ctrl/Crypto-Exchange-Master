import '../models/currency_option_model.dart';
import '../models/transfer_option_model.dart';
import '../models/transfer_request_model.dart';
import '../models/transfer_response_model.dart';

abstract class TransferRemoteDataSource {
  /// Get available wallet types for transfers
  Future<List<TransferOptionModel>> getTransferOptions();

  /// Get available currencies for a wallet type and optional target wallet type
  Future<List<CurrencyOptionModel>> getCurrencies({
    required String walletType,
    String? targetWalletType,
  });

  /// Get wallet balance for specific wallet type
  Future<List<CurrencyOptionModel>> getWalletBalance({
    required String walletType,
  });

  /// Validate recipient UUID exists and is eligible
  Future<Map<String, dynamic>> validateRecipient(String uuid);

  /// Create a transfer transaction
  Future<TransferResponseModel> createTransfer(
    TransferRequestModel request,
  );
}
