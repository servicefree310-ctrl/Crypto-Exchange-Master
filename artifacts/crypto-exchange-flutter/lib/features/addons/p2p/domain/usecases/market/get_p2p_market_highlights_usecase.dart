import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_market_stats_entity.dart';
import '../../repositories/p2p_market_repository.dart';

@injectable
class GetP2PMarketHighlightsUseCase
    implements UseCase<List<P2PMarketHighlightEntity>, NoParams> {
  const GetP2PMarketHighlightsUseCase(this._repository);

  final P2PMarketRepository _repository;

  @override
  Future<Either<Failure, List<P2PMarketHighlightEntity>>> call(
      NoParams params) async {
    return _repository.getMarketHighlights();
  }
}
