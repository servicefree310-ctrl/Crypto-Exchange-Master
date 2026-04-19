import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import 'futures_deposit_remote_datasource.dart';
import 'eco_deposit_remote_datasource.dart';
import '../models/eco_deposit_address_model.dart';
import '../models/eco_deposit_verification_model.dart';
import '../models/eco_token_model.dart';
import '../models/futures_currency_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

@Injectable(as: FuturesDepositRemoteDataSource)
class FuturesDepositRemoteDataSourceImpl
    implements FuturesDepositRemoteDataSource {
  final EcoDepositRemoteDataSource _ecoDataSource;
  final DioClient _dioClient;

  const FuturesDepositRemoteDataSourceImpl(
    this._ecoDataSource,
    this._dioClient,
  );

  @override
  Future<List<String>> getFuturesCurrencies() async {
    dev.log('🔵 FUTURES_REMOTE_DS: Fetching FUTURES currencies');

    try {
      final response = await _dioClient.get(
        ApiConstants.futuresCurrencies,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        dev.log('✅ FUTURES_REMOTE_DS: Fetched ${data.length} currencies');

        // Parse the {value, label, icon} format and return just the currency values
        return data
            .map((json) =>
                FuturesCurrencyModel.fromJson(json as Map<String, dynamic>))
            .map((currency) => currency.value)
            .toList();
      } else {
        throw Exception(
            'Failed to fetch FUTURES currencies: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '❌ FUTURES_REMOTE_DS: Network error fetching currencies: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('FUTURES currencies not available');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
            'Network connection failed. Please check your internet and try again.');
      }
    } catch (e) {
      dev.log('❌ FUTURES_REMOTE_DS: Unexpected error fetching currencies: $e');
      throw Exception('Failed to fetch FUTURES currencies: $e');
    }
  }

  @override
  Future<List<EcoTokenModel>> getFuturesTokens(String currency) async {
    dev.log(
        '🔵 FUTURES_REMOTE_DS: Fetching FUTURES tokens for currency: $currency');

    try {
      final response = await _dioClient.get(
        '/api/finance/currency/FUTURES/$currency',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        dev.log(
            '✅ FUTURES_REMOTE_DS: Fetched ${data.length} tokens for $currency');

        // Handle potential null values in API response
        return data.map((json) {
          final Map<String, dynamic> tokenJson = json as Map<String, dynamic>;

          // Ensure required fields have fallback values
          return EcoTokenModel.fromJson({
            ...tokenJson,
            'limits': tokenJson['limits'] ?? {},
            'fee': tokenJson['fee'] ?? {},
          });
        }).toList();
      } else {
        throw Exception('Failed to fetch tokens: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log('❌ FUTURES_REMOTE_DS: Network error fetching tokens: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception(
            '$currency currency is not available for FUTURES deposits');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
            'Network connection failed. Please check your internet and try again.');
      }
    } catch (e) {
      dev.log('❌ FUTURES_REMOTE_DS: Unexpected error fetching tokens: $e');
      throw Exception('Failed to fetch tokens for $currency: $e');
    }
  }

  @override
  Future<EcoDepositAddressModel> generateFuturesAddress(
    String currency,
    String chain,
    String contractType,
  ) async {
    dev.log(
        '🔵 FUTURES_REMOTE_DS: Generating $contractType address for $currency on $chain');

    // Use the ECO data source methods based on contract type
    // The backend will create a FUTURES wallet type internally
    switch (contractType) {
      case 'PERMIT':
        return await _ecoDataSource.generatePermitAddress(currency, chain);
      case 'NO_PERMIT':
        return await _ecoDataSource.generateNoPermitAddress(currency, chain);
      case 'NATIVE':
        return await _ecoDataSource.generateNativeAddress(currency, chain);
      default:
        throw Exception('Unknown contract type: $contractType');
    }
  }

  @override
  Stream<EcoDepositVerificationModel> monitorFuturesDeposit(
    String currency,
    String chain,
    String? address,
  ) {
    dev.log(
        '🔵 FUTURES_REMOTE_DS: Starting FUTURES deposit monitoring for $currency on $chain');

    // Use the same ECO WebSocket monitoring since backend uses same endpoint
    // The backend will automatically associate deposits with FUTURES wallet type
    return _ecoDataSource.connectToEcoWebSocket();
  }

  @override
  Future<void> unlockFuturesAddress(
    String currency,
    String chain,
    String address,
  ) async {
    dev.log(
        '🔵 FUTURES_REMOTE_DS: Unlocking FUTURES address for $currency on $chain');

    // Use the same ECO unlock endpoint since backend infrastructure is shared
    return await _ecoDataSource.unlockAddress(address);
  }
}
