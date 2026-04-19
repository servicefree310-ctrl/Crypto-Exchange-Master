import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/futures_market_model.dart';

abstract class FuturesMarketRemoteDataSource {
  Future<List<FuturesMarketModel>> getFuturesMarkets();
}

@Injectable(as: FuturesMarketRemoteDataSource)
class FuturesMarketRemoteDataSourceImpl
    implements FuturesMarketRemoteDataSource {
  const FuturesMarketRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<FuturesMarketModel>> getFuturesMarkets() async {
    final response = await _apiClient.get(ApiConstants.futuresMarkets);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['data'] as List<dynamic>? ?? []);

    return data
        .map(
            (json) => FuturesMarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
