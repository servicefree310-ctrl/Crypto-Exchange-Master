import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/futures_order_model.dart';

abstract class FuturesOrderRemoteDataSource {
  Future<FuturesOrderModel> placeOrder({
    required String currency,
    required String pair,
    required String type,
    required String side,
    required double amount,
    double? price,
    required double leverage,
    double? stopLossPrice,
    double? takeProfitPrice,
  });

  Future<List<FuturesOrderModel>> getOrders({
    required String symbol,
    String? status,
  });

  Future<FuturesOrderModel> cancelOrder(
    String id, {
    required DateTime createdAt,
  });
}

@Injectable(as: FuturesOrderRemoteDataSource)
class FuturesOrderRemoteDataSourceImpl implements FuturesOrderRemoteDataSource {
  const FuturesOrderRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<FuturesOrderModel> placeOrder({
    required String currency,
    required String pair,
    required String type,
    required String side,
    required double amount,
    double? price,
    required double leverage,
    double? stopLossPrice,
    double? takeProfitPrice,
  }) async {
    final data = {
      'currency': currency,
      'pair': pair,
      'type': type,
      'side': side,
      'amount': amount,
      'leverage': leverage,
    };

    if (price != null) data['price'] = price;
    if (stopLossPrice != null) data['stopLossPrice'] = stopLossPrice;
    if (takeProfitPrice != null) data['takeProfitPrice'] = takeProfitPrice;

    final response = await _client.post(
      ApiConstants.futuresOrders,
      data: data,
    );

    final responseData = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>);
    return FuturesOrderModel.fromJson(responseData);
  }

  @override
  Future<List<FuturesOrderModel>> getOrders({
    required String symbol,
    String? status,
  }) async {
    final parts = symbol.split('/');
    final currency = parts.first;
    final pair = parts.length > 1 ? parts[1] : '';

    final queryParams = <String, dynamic>{
      'currency': currency,
      'pair': pair,
    };

    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _client.get(
      ApiConstants.futuresOrders,
      queryParameters: queryParams,
    );

    final List<dynamic> items = response.data is List
        ? response.data as List<dynamic>
        : (response.data['data'] as List<dynamic>? ?? []);

    return items
        .map((e) => FuturesOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FuturesOrderModel> cancelOrder(
    String id, {
    required DateTime createdAt,
  }) async {
    final timestamp = createdAt.millisecondsSinceEpoch;
    final response = await _client.delete(
      '${ApiConstants.futuresOrders}/$id',
      queryParameters: {'timestamp': timestamp},
    );

    final responseData = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>);
    return FuturesOrderModel.fromJson(responseData);
  }
}
