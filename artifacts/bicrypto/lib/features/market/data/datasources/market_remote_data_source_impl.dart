import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/market_model.dart';
import '../models/ticker_model.dart';
import 'market_remote_data_source.dart';

@Injectable(as: MarketRemoteDataSource)
class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  const MarketRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<MarketModel>> getMarkets() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.markets,
        queryParameters: const {'eco': 'true'},
      );

      if (response.data is List) {
        final dataList = response.data as List;
        final markets = <MarketModel>[];

        for (final item in dataList) {
          try {
            if (item is Map<String, dynamic>) {
              final market = MarketModel.fromJson(item);
              markets.add(market);
            }
          } catch (e) {
            continue;
          }
        }

        return markets;
      } else {
        throw Exception('Invalid response format: Expected List');
      }
    } catch (e) {
      throw Exception('Failed to fetch markets: $e');
    }
  }

  @override
  Future<Map<String, TickerModel>> getTickers() async {
    try {
      final response = await _dioClient.get(ApiConstants.ticker);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final tickerMap = <String, TickerModel>{};

        for (final entry in data.entries) {
          try {
            final symbol = entry.key;
            final tickerData = entry.value;

            if (tickerData is Map<String, dynamic>) {
              final completeTickerData = <String, dynamic>{
                'symbol': symbol,
                ...tickerData,
              };
              final ticker = TickerModel.fromJson(completeTickerData);
              tickerMap[symbol] = ticker;
            }
          } catch (e) {
            continue;
          }
        }

        return tickerMap;
      } else {
        throw Exception('Invalid response format: Expected Map');
      }
    } catch (e) {
      throw Exception('Failed to fetch tickers: $e');
    }
  }
}
