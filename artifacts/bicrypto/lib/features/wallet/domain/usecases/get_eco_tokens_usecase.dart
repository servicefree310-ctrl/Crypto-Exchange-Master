import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/eco_token_entity.dart';
import '../repositories/eco_deposit_repository.dart';

class GetEcoTokensParams {
  final String currency;

  const GetEcoTokensParams({required this.currency});
}

@injectable
class GetEcoTokensUseCase
    implements UseCase<List<EcoTokenEntity>, GetEcoTokensParams> {
  final EcoDepositRepository _repository;

  const GetEcoTokensUseCase(this._repository);

  @override
  Future<Either<Failure, List<EcoTokenEntity>>> call(
      GetEcoTokensParams params) async {
    if (params.currency.isEmpty) {
      return const Left(ValidationFailure('Currency is required'));
    }

    return _repository.getEcoTokens(params.currency);
  }
}
