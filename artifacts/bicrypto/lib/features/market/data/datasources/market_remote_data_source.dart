import '../models/market_model.dart';
import '../models/ticker_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<MarketModel>> getMarkets();
  Future<Map<String, TickerModel>> getTickers();
}
