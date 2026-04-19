import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';

@injectable
class OrderRemoteDataSource {
  const OrderRemoteDataSource(this._client);

  final DioClient _client;

  Map<String, String> _extractCurrencyPair(String symbol) {
    if (symbol.contains('/')) {
      final parts = symbol.split('/');
      return {
        'currency': parts.first,
        'pair': parts.length > 1 ? parts[1] : '',
      };
    }

    final compact = symbol.trim().toUpperCase();
    final knownQuotes = ['USDT', 'USDC', 'BUSD', 'BTC', 'ETH'];
    for (final quote in knownQuotes) {
      if (compact.endsWith(quote) && compact.length > quote.length) {
        return {
          'currency': compact.substring(0, compact.length - quote.length),
          'pair': quote,
        };
      }
    }

    return {
      'currency': symbol,
      'pair': '',
    };
  }

  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is! Map<String, dynamic>) return const [];

    final directData = data['data'];
    if (directData is List) return directData;

    if (directData is Map<String, dynamic>) {
      final nestedItems = directData['items'];
      if (nestedItems is List) return nestedItems;

      final nestedData = directData['data'];
      if (nestedData is List) return nestedData;
    }

    final result = data['result'];
    if (result is List) return result;

    return const [];
  }

  Future<OrderModel> createOrder({
    required String currency,
    required String pair,
    required String type,
    required String side,
    required double amount,
    double? price,
    double? stopPrice,
  }) async {
    final body = {
      'currency': currency,
      'pair': pair,
      'type': type,
      'side': side,
      'amount': amount,
    };
    if (price != null) body['price'] = price;
    if (stopPrice != null) body['stopPrice'] = stopPrice;

    final Response response = await _client.post(
      ApiConstants.createOrder,
      data: body,
    );

    Map<String, dynamic>? data;
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map['id'] != null) {
        data = map;
      } else if (map['data'] is Map<String, dynamic>) {
        data = map['data'] as Map<String, dynamic>;
      }
    }

    data ??= {
      'id': 'pending-${DateTime.now().millisecondsSinceEpoch}',
      'symbol': '$currency/$pair',
      'type': type,
      'side': side,
      'amount': amount,
      'price': price ?? 0,
      'cost': (price ?? 0) * amount,
      'status': 'OPEN',
      'createdAt': DateTime.now().toIso8601String(),
    };

    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> fetchOpenOrders({required String symbol}) async {
    final pairInfo = _extractCurrencyPair(symbol);

    final Response response = await _client.get(
      ApiConstants.orders,
      queryParameters: {
        'currency': pairInfo['currency'],
        'pair': pairInfo['pair'],
        'status': 'OPEN',
        'type': 'OPEN',
      },
    );

    final List<dynamic> items = _extractItems(response.data);

    return items
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderModel>> fetchOrderHistory({required String symbol}) async {
    final pairInfo = _extractCurrencyPair(symbol);

    final Response response = await _client.get(
      ApiConstants.orderHistory,
      queryParameters: {
        'currency': pairInfo['currency'],
        'pair': pairInfo['pair'],
        'status': 'CLOSED',
        'type': 'CLOSED',
      },
    );

    final List<dynamic> items = _extractItems(response.data);

    return items
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelOrder({required String orderId}) async {
    await _client.delete('${ApiConstants.cancelOrder}/$orderId');
  }
}
