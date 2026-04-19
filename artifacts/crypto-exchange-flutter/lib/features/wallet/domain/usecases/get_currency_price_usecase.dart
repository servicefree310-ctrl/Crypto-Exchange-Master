import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/currency_price_repository.dart';

class GetCurrencyPriceParams {
  final String currency;
  final String walletType;

  const GetCurrencyPriceParams({
    required this.currency,
    required this.walletType,
  });
}

@injectable
class GetCurrencyPriceUseCase
    implements UseCase<double, GetCurrencyPriceParams> {
  final CurrencyPriceRepository _repository;

  const GetCurrencyPriceUseCase(this._repository);

  @override
  Future<Either<Failure, double>> call(GetCurrencyPriceParams params) async {
    try {
      // Validate parameters
      if (params.currency.isEmpty) {
        return const Left(ValidationFailure('Currency is required'));
      }
      if (params.walletType.isEmpty) {
        return const Left(ValidationFailure('Wallet type is required'));
      }

      return await _repository.getCurrencyPrice(
        currency: params.currency,
        walletType: params.walletType,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
