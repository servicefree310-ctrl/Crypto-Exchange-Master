import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../entities/p2p_market_stats_entity.dart';

abstract class P2PMarketRepository {
  /// Get P2P market statistics (total trades, volume, average trade size)
  Future<Either<Failure, P2PMarketStatsEntity>> getMarketStats();

  /// Get top cryptocurrencies by P2P trading volume
  Future<Either<Failure, List<P2PTopCryptoEntity>>> getTopCurrencies({
    int limit = 5,
  });

  /// Get P2P market highlights (active offers)
  Future<Either<Failure, List<P2PMarketHighlightEntity>>> getMarketHighlights();
}
