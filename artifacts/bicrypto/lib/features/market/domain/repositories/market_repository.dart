import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/websocket_service.dart';
import '../entities/market_data_entity.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<MarketDataEntity>>> getMarkets();
  Future<Either<Failure, List<MarketDataEntity>>> getTrendingMarkets();
  Future<Either<Failure, List<MarketDataEntity>>> getHotMarkets();
  Future<Either<Failure, List<MarketDataEntity>>> getGainersMarkets();
  Future<Either<Failure, List<MarketDataEntity>>> getLosersMarkets();
  Future<Either<Failure, List<MarketDataEntity>>> getHighVolumeMarkets();
  Future<Either<Failure, List<MarketDataEntity>>> searchMarkets(String query);
  Future<Either<Failure, List<MarketDataEntity>>> getMarketsByCategory(
      String category);

  // Real-time data streaming
  Stream<List<MarketDataEntity>> getRealtimeMarkets();
  Future<Either<Failure, void>> startRealtimeUpdates();
  Future<Either<Failure, void>> stopRealtimeUpdates();
  Stream<WebSocketConnectionStatus> getConnectionStatus();
}
