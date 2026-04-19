import 'package:injectable/injectable.dart';

import '../../../../core/services/trading_websocket_service.dart';
import '../../../market/domain/entities/market_data_entity.dart';

@injectable
class GetRealtimeTickerUseCase {
  const GetRealtimeTickerUseCase(this._tradingWebSocketService);

  final TradingWebSocketService _tradingWebSocketService;

  Stream<MarketDataEntity> call(String symbol) {
    return _tradingWebSocketService.subscribeToSymbolTicker(symbol);
  }

  Future<void> unsubscribe(String symbol) {
    return _tradingWebSocketService.unsubscribeFromSymbol(symbol);
  }
}
