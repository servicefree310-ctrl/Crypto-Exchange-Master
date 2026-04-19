import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/websocket_service.dart';
import '../entities/market_data_entity.dart';
import '../repositories/market_repository.dart';

@injectable
class GetRealtimeMarketsUseCase {
  const GetRealtimeMarketsUseCase(this._repository);

  final MarketRepository _repository;

  /// Start real-time market data streaming
  Future<Either<Failure, void>> startRealtimeUpdates() async {
    return await _repository.startRealtimeUpdates();
  }

  /// Stop real-time market data streaming
  Future<Either<Failure, void>> stopRealtimeUpdates() async {
    return await _repository.stopRealtimeUpdates();
  }

  /// Get real-time market data stream
  Stream<List<MarketDataEntity>> getRealtimeMarkets() {
    return _repository.getRealtimeMarkets();
  }

  /// Get WebSocket connection status stream
  Stream<WebSocketConnectionStatus> getConnectionStatus() {
    return _repository.getConnectionStatus();
  }
}
