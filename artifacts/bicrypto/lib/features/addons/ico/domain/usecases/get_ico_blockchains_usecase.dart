import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/ico_blockchain_entity.dart';
import '../repositories/ico_repository.dart';

@injectable
class GetIcoBlockchainsUseCase
    implements UseCase<List<IcoBlockchainEntity>, NoParams> {
  const GetIcoBlockchainsUseCase(this._repository);

  final IcoRepository _repository;

  @override
  Future<Either<Failure, List<IcoBlockchainEntity>>> call(
      NoParams params) async {
    return await _repository.getBlockchains();
  }
}
