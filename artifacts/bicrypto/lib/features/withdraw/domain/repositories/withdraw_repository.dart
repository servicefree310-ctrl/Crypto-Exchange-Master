import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../transfer/domain/entities/currency_option_entity.dart';
import '../entities/withdraw_method_entity.dart';
import '../entities/withdraw_request_entity.dart';
import '../entities/withdraw_response_entity.dart';

abstract class WithdrawRepository {
  /// Get available currencies for withdrawal by wallet type
  Future<Either<Failure, List<CurrencyOptionEntity>>> getWithdrawCurrencies({
    required String walletType,
  });

  /// Get withdrawal methods for specific wallet type and currency
  Future<Either<Failure, List<WithdrawMethodEntity>>> getWithdrawMethods({
    required String walletType,
    required String currency,
  });

  /// Submit withdrawal request
  Future<Either<Failure, WithdrawResponseEntity>> submitWithdrawal(
    WithdrawRequestEntity request,
  );
}
