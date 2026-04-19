import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/currency_price_repository.dart';

class GetWalletBalanceParams {
  final String currency;
  final String walletType;

  const GetWalletBalanceParams({
    required this.currency,
    required this.walletType,
  });
}

@injectable
class GetCurrencyWalletBalanceUseCase
    implements UseCase<double, GetWalletBalanceParams> {
  final CurrencyPriceRepository _repository;

  const GetCurrencyWalletBalanceUseCase(this._repository);

  @override
  Future<Either<Failure, double>> call(GetWalletBalanceParams params) async {
    try {
      // Validate parameters
      if (params.currency.isEmpty) {
        return const Left(ValidationFailure('Currency is required'));
      }
      if (params.walletType.isEmpty) {
        return const Left(ValidationFailure('Wallet type is required'));
      }

      return await _repository.getWalletBalance(
        currency: params.currency,
        walletType: params.walletType,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
