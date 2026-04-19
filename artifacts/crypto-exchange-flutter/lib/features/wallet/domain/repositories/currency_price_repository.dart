import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class CurrencyPriceRepository {
  Future<Either<Failure, double>> getCurrencyPrice({
    required String currency,
    required String walletType,
  });

  Future<Either<Failure, double>> getWalletBalance({
    required String currency,
    required String walletType,
  });
}
