import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/eco_deposit_repository.dart';

@injectable
class GetEcoCurrenciesUseCase implements UseCase<List<String>, NoParams> {
  final EcoDepositRepository _repository;

  const GetEcoCurrenciesUseCase(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return _repository.getEcoCurrencies();
  }
}
