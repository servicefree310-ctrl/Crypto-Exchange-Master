import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spot_currency_entity.dart';
import '../repositories/spot_deposit_repository.dart';

@injectable
class GetSpotCurrenciesUseCase
    implements UseCase<List<SpotCurrencyEntity>, NoParams> {
  const GetSpotCurrenciesUseCase(this._repository);

  final SpotDepositRepository _repository;

  @override
  Future<Either<Failure, List<SpotCurrencyEntity>>> call(NoParams params) {
    return _repository.getSpotCurrencies();
  }
}
