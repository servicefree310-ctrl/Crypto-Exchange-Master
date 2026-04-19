import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/futures_position_model.dart';

abstract class FuturesPositionRemoteDataSource {
  Future<List<FuturesPositionModel>> getPositions({required String symbol});
  Future<FuturesPositionModel> closePosition({
    required String symbol,
    required String side,
  });
  Future<FuturesPositionModel> updateLeverage({
    required String symbol,
    required double leverage,
  });
}

@Injectable(as: FuturesPositionRemoteDataSource)
class FuturesPositionRemoteDataSourceImpl
    implements FuturesPositionRemoteDataSource {
  const FuturesPositionRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<FuturesPositionModel>> getPositions(
      {required String symbol}) async {
    final parts = symbol.split('/');
    final currency = parts.first;
    final pair = parts.length > 1 ? parts[1] : '';

    final response = await _client.get(
      ApiConstants.futuresPositions,
      queryParameters: {
        'currency': currency,
        'pair': pair,
      },
    );

    final List<dynamic> items = response.data is List
        ? response.data as List<dynamic>
        : (response.data['data'] as List<dynamic>);

    return items
        .map((e) => FuturesPositionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FuturesPositionModel> closePosition({
    required String symbol,
    required String side,
  }) async {
    final parts = symbol.split('/');
    final currency = parts.first;
    final pair = parts.length > 1 ? parts[1] : '';

    final response = await _client.delete(
      ApiConstants.futuresPositions,
      data: {
        'currency': currency,
        'pair': pair,
        'side': side,
      },
    );
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>);
    return FuturesPositionModel.fromJson(data);
  }

  @override
  Future<FuturesPositionModel> updateLeverage({
    required String symbol,
    required double leverage,
  }) async {
    final parts = symbol.split('/');
    final currency = parts.first;
    final pair = parts.length > 1 ? parts[1] : '';

    final response = await _client.put(
      ApiConstants.futuresLeverage,
      data: {
        'currency': currency,
        'pair': pair,
        'leverage': leverage,
      },
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>);
    return FuturesPositionModel.fromJson(data);
  }
}
