import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_market_repository.dart';
import '../../entities/p2p_market_stats_entity.dart';

/// Use case for retrieving P2P market statistics
///
/// Matches v5 backend: GET /api/ext/p2p/market/stats
/// - Returns aggregated market statistics from all P2P trades
/// - Includes total trades, volume, and average trade size
/// - No authentication required (public data)
/// - Used for market overview and analytics
@injectable
class GetMarketStatsUseCase implements UseCase<P2PMarketStatsEntity, NoParams> {
  const GetMarketStatsUseCase(this._repository);

  final P2PMarketRepository _repository;

  @override
  Future<Either<Failure, P2PMarketStatsEntity>> call(NoParams params) async {
    // No validation needed for public market stats
    return await _repository.getMarketStats();
  }
}
