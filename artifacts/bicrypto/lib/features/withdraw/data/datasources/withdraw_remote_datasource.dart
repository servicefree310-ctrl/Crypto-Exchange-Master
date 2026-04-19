import '../../../transfer/data/models/currency_option_model.dart';
import '../models/withdraw_method_model.dart';
import '../models/withdraw_request_model.dart';
import '../models/withdraw_response_model.dart';

abstract class WithdrawRemoteDataSource {
  /// Get available currencies for withdrawal by wallet type
  Future<List<CurrencyOptionModel>> getWithdrawCurrencies({
    required String walletType,
  });

  /// Get withdrawal methods for specific wallet type and currency
  Future<List<WithdrawMethodModel>> getWithdrawMethods({
    required String walletType,
    required String currency,
  });

  /// Submit withdrawal request
  Future<WithdrawResponseModel> submitWithdrawal(
    WithdrawRequestModel request,
  );
}
