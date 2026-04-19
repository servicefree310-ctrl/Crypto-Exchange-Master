import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency_option_entity.dart';
import '../repositories/deposit_repository.dart';

@injectable
class GetCurrencyOptionsUseCase
    implements UseCase<List<CurrencyOptionEntity>, GetCurrencyOptionsParams> {
  const GetCurrencyOptionsUseCase(this._repository);

  final DepositRepository _repository;

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> call(
      GetCurrencyOptionsParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Execute business logic
    return await _repository.getCurrencyOptions(params.walletType);
  }

  ValidationFailure? _validateParams(GetCurrencyOptionsParams params) {
    // Validate wallet type
    final validWalletTypes = ['FIAT', 'SPOT', 'ECO', 'FUTURES'];
    if (!validWalletTypes.contains(params.walletType)) {
      return ValidationFailure(
          'Invalid wallet type. Must be FIAT, SPOT, ECO, or FUTURES');
    }
    return null;
  }
}

class GetCurrencyOptionsParams {
  const GetCurrencyOptionsParams({
    required this.walletType,
  });

  final String walletType;
}
