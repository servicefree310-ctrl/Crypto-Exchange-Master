import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';

abstract class CurrencyPriceRemoteDataSource {
  Future<double> getCurrencyPrice({
    required String currency,
    required String walletType,
  });

  Future<double> getWalletBalance({
    required String currency,
    required String walletType,
  });
}

@Injectable(as: CurrencyPriceRemoteDataSource)
class CurrencyPriceRemoteDataSourceImpl
    implements CurrencyPriceRemoteDataSource {
  final DioClient _client;

  const CurrencyPriceRemoteDataSourceImpl(this._client);

  @override
  Future<double> getCurrencyPrice({
    required String currency,
    required String walletType,
  }) async {
    try {
      dev.log('🔵 CURRENCY_PRICE_DS: Fetching price for $currency ($walletType)');

      final response = await _client.get(
        '/api/finance/currency/price',
        queryParameters: {
          'currency': currency,
          'type': walletType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final price = (data['data'] as num?)?.toDouble() ?? 0.0;

        dev.log('✅ CURRENCY_PRICE_DS: Price for $currency: \$$price');
        return price;
      } else {
        throw ServerException(
            'Failed to fetch currency price: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('❌ CURRENCY_PRICE_DS: Error fetching price: $e');
      throw ServerException('Failed to fetch currency price: $e');
    }
  }

  @override
  Future<double> getWalletBalance({
    required String currency,
    required String walletType,
  }) async {
    try {
      dev.log(
          '🔵 CURRENCY_PRICE_DS: Fetching balance for $currency ($walletType)');

      // Use existing wallet endpoint
      final response = await _client.get(
        '/api/finance/wallet',
        queryParameters: {
          'currency': currency,
          'type': walletType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Extract balance from wallet data
        double balance = 0.0;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('items') && data['items'] is List) {
            final items = data['items'] as List;
            if (items.isNotEmpty) {
              final wallet = items.first as Map<String, dynamic>;
              balance = (wallet['balance'] as num?)?.toDouble() ?? 0.0;
            }
          } else if (data.containsKey('balance')) {
            balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          }
        }

        dev.log('✅ CURRENCY_PRICE_DS: Balance for $currency: $balance');
        return balance;
      } else {
        throw ServerException(
            'Failed to fetch wallet balance: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('❌ CURRENCY_PRICE_DS: Error fetching balance: $e');
      throw ServerException('Failed to fetch wallet balance: $e');
    }
  }
}
