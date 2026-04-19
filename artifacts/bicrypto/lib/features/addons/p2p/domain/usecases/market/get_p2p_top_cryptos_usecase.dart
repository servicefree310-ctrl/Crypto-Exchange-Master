import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_market_stats_entity.dart';
import '../../repositories/p2p_market_repository.dart';

@injectable
class GetP2PTopCryptosUseCase
    implements UseCase<List<P2PTopCryptoEntity>, NoParams> {
  const GetP2PTopCryptosUseCase(this._repository);

  final P2PMarketRepository _repository;

  @override
  Future<Either<Failure, List<P2PTopCryptoEntity>>> call(
      NoParams params) async {
    return _repository.getTopCurrencies();
  }
}
