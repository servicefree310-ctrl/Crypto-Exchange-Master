import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/p2p_market_stats_model.dart';

abstract class P2PMarketRemoteDataSource {
  Future<P2PMarketStatsModel> getMarketStats();
  Future<List<P2PTopCryptoModel>> getTopCryptos();
  Future<List<P2PMarketHighlightModel>> getMarketHighlights();
}

@Injectable(as: P2PMarketRemoteDataSource)
class P2PMarketRemoteDataSourceImpl implements P2PMarketRemoteDataSource {
  const P2PMarketRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9\-]'), '');
      if (cleaned.isEmpty || cleaned == '-') return 0;
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.\-]'), '');
      if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') return 0.0;
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Map<String, dynamic> _asMapOrJson(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        return _asMap(decoded);
      } catch (_) {
        return const <String, dynamic>{};
      }
    }
    return _asMap(value);
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<P2PMarketStatsModel> getMarketStats() async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.p2pBaseUrl}/market/stats');
      final data = _asMap(response.data);
      final nested = _asMap(data['data']);
      final source = nested.isNotEmpty ? nested : data;
      final topCurrenciesRaw = source['topCurrencies'];
      final topCurrencies = topCurrenciesRaw is List
          ? topCurrenciesRaw
              .map((entry) {
                if (entry is Map) {
                  final item = entry.cast<String, dynamic>();
                  return (item['currency'] ?? item['symbol'] ?? '').toString();
                }
                return entry.toString();
              })
              .where((item) => item.isNotEmpty)
              .toList()
          : <String>[];

      return P2PMarketStatsModel.fromJson({
        'totalTrades': _toInt(source['totalTrades']),
        'totalVolume': _toDouble(source['totalVolume']),
        'avgTradeSize': _toDouble(source['avgTradeSize']),
        'activeTrades': _toInt(source['activeTrades']),
        'last24hTrades': _toInt(source['last24hTrades']),
        'last24hVolume': _toDouble(source['last24hVolume']),
        'topCurrencies': topCurrencies,
      });
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['message'] ?? 'Failed to get P2P market stats');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<P2PTopCryptoModel>> getTopCryptos() async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.p2pBaseUrl}/market/top');
      final data = _asMap(response.data);
      final raw = _asListOfMap(data['data']).isNotEmpty
          ? _asListOfMap(data['data'])
          : _asListOfMap(response.data);

      return raw.map((item) {
        final symbol = (item['symbol'] ?? item['currency'] ?? '').toString();
        return P2PTopCryptoModel.fromJson({
          'symbol': symbol,
          'name': (item['name'] ?? symbol).toString(),
          'volume24h': _toDouble(item['volume24h'] ?? item['totalVolume']),
          'tradeCount': _toInt(
              item['tradeCount'] ?? item['trades'] ?? item['totalTrades']),
          'avgPrice': _toDouble(item['avgPrice']),
        });
      }).toList();
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['message'] ?? 'Failed to get top cryptocurrencies');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<P2PMarketHighlightModel>> getMarketHighlights() async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.p2pBaseUrl}/market/highlight');
      final data = _asMap(response.data);
      final raw = _asListOfMap(data['data']).isNotEmpty
          ? _asListOfMap(data['data'])
          : _asListOfMap(response.data);

      return raw.map((item) {
        final priceConfig = _asMapOrJson(item['priceConfig']);
        final amountConfig = _asMapOrJson(item['amountConfig']);
        final paymentMethods = item['paymentMethods'] is List
            ? item['paymentMethods'] as List
            : const <dynamic>[];
        final paymentMethod = paymentMethods.isNotEmpty
            ? paymentMethods.first is Map
                ? (paymentMethods.first as Map)['name']?.toString()
                : paymentMethods.first.toString()
            : item['paymentMethod']?.toString();
        final locationSettings = _asMapOrJson(item['locationSettings']);
        final amount = _toDouble(
          amountConfig['total'] ??
              amountConfig['amount'] ??
              amountConfig['max'] ??
              item['amount'],
        );
        final price = _toDouble(
          priceConfig['finalPrice'] ?? priceConfig['value'] ?? item['price'],
        );

        return P2PMarketHighlightModel.fromJson({
          'id': (item['id'] ?? '').toString(),
          'type': (item['type'] ?? 'BUY').toString().toUpperCase(),
          'currency': (item['currency'] ?? '').toString(),
          'price': price,
          'amount': amount,
          'paymentMethod': paymentMethod ?? 'Unknown',
          'country':
              (locationSettings['country'] ?? item['country'] ?? 'Global')
                  .toString(),
          'createdAt': item['createdAt'],
          'views': _toInt(item['views']),
          'matchScore': _toDouble(item['matchScore']),
        });
      }).toList();
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['message'] ?? 'Failed to get market highlights');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
