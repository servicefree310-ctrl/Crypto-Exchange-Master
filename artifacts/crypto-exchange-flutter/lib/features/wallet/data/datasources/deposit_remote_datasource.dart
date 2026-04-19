import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../models/deposit_gateway_model.dart';
import '../models/deposit_method_model.dart';
import '../models/deposit_transaction_model.dart';
import '../models/currency_option_model.dart';

abstract class DepositRemoteDataSource {
  Future<List<CurrencyOptionModel>> fetchCurrencyOptions(String walletType);
  Future<Map<String, dynamic>> fetchDepositMethods(String currency);
  Future<DepositTransactionModel> createFiatDeposit({
    required String methodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> customFields,
  });
  Future<Map<String, dynamic>> createStripePaymentIntent({
    required double amount,
    required String currency,
  });
  Future<DepositTransactionModel> verifyStripePayment({
    required String paymentIntentId,
  });

  // PayPal deposit methods
  Future<Map<String, dynamic>> createPayPalOrder({
    required double amount,
    required String currency,
  });

  Future<DepositTransactionModel> verifyPayPalPayment({
    required String orderId,
  });
}

@Injectable(as: DepositRemoteDataSource)
class DepositRemoteDataSourceImpl implements DepositRemoteDataSource {
  const DepositRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<CurrencyOptionModel>> fetchCurrencyOptions(
      String walletType) async {
    dev.log('🔵 DEPOSIT_REMOTE_DS: Fetching currency options for $walletType');

    try {
      final response = await _dioClient.get(
        '/api/finance/currency',
        queryParameters: {
          'action': 'deposit',
          'walletType': walletType,
        },
      );

      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Currency options response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Currency options response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = _extractList(response.data);
        final currencyOptions = data
            .map((json) =>
                CurrencyOptionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        dev.log(
            '🟢 DEPOSIT_REMOTE_DS: Found ${currencyOptions.length} currency options');
        return currencyOptions;
      } else {
        throw Exception(
            'Failed to fetch currency options: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log('🔴 DEPOSIT_REMOTE_DS: DioException: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      dev.log('🔴 DEPOSIT_REMOTE_DS: Unexpected error: $e');
      throw Exception('Failed to fetch currency options: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDepositMethods(String currency) async {
    dev.log('🔵 DEPOSIT_REMOTE_DS: Fetching deposit methods for $currency');

    try {
      final response = await _dioClient.get(
        '/api/finance/currency/FIAT/$currency',
        queryParameters: {'action': 'deposit'},
      );

      dev.log('🔵 DEPOSIT_REMOTE_DS: Response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Response data keys: ${_extractMap(response.data).keys.toList()}');
      dev.log('🔵 DEPOSIT_REMOTE_DS: Full response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = _extractPayloadMap(response.data);

        // Parse gateways
        final gatewaysData = _extractList(data['gateways']);
        dev.log('🔵 DEPOSIT_REMOTE_DS: Raw gateways data: $gatewaysData');

        final gateways = <DepositGatewayModel>[];
        for (var i = 0; i < gatewaysData.length; i++) {
          try {
            final gateway = DepositGatewayModel.fromJson(
              _extractMap(gatewaysData[i]),
            );
            gateways.add(gateway);
            dev.log(
                '🟢 DEPOSIT_REMOTE_DS: Successfully parsed gateway ${i + 1}: ${gateway.name}');
          } catch (e) {
            dev.log('🔴 DEPOSIT_REMOTE_DS: Error parsing gateway ${i + 1}: $e');
            dev.log('🔴 DEPOSIT_REMOTE_DS: Gateway data: ${gatewaysData[i]}');
          }
        }

        // Parse methods
        final methodsData = _extractList(data['methods']);
        dev.log('🔵 DEPOSIT_REMOTE_DS: Raw methods data: $methodsData');

        final methods = <DepositMethodModel>[];
        for (var i = 0; i < methodsData.length; i++) {
          try {
            final method = DepositMethodModel.fromJson(
              _extractMap(methodsData[i]),
            );
            methods.add(method);
            dev.log(
                '🟢 DEPOSIT_REMOTE_DS: Successfully parsed method ${i + 1}: ${method.title}');
          } catch (e) {
            dev.log('🔴 DEPOSIT_REMOTE_DS: Error parsing method ${i + 1}: $e');
            dev.log('🔴 DEPOSIT_REMOTE_DS: Method data: ${methodsData[i]}');
          }
        }

        dev.log(
            '🟢 DEPOSIT_REMOTE_DS: Found ${gateways.length} gateways and ${methods.length} methods');

        return {
          'gateways': gateways,
          'methods': methods,
        };
      } else {
        throw Exception(
            'Failed to fetch deposit methods: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log('🔴 DEPOSIT_REMOTE_DS: DioException: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      dev.log('🔴 DEPOSIT_REMOTE_DS: Unexpected error: $e');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Stack trace: ${StackTrace.current}');
      throw Exception('Failed to fetch deposit methods: $e');
    }
  }

  @override
  Future<DepositTransactionModel> createFiatDeposit({
    required String methodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> customFields,
  }) async {
    dev.log('🔵 DEPOSIT_REMOTE_DS: Creating FIAT deposit');
    dev.log(
        '🔵 DEPOSIT_REMOTE_DS: Method: $methodId, Amount: $amount, Currency: $currency');

    try {
      final response = await _dioClient.post(
        '/api/finance/deposit/fiat',
        data: {
          'methodId': methodId,
          'amount': amount,
          'currency': currency,
          'customFields': customFields,
        },
      );

      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Create deposit response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Create deposit response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractPayloadMap(response.data);
        final transactionData = _extractMap(payload['transaction']).isNotEmpty
            ? _extractMap(payload['transaction'])
            : payload;

        final normalizedTransaction = _normalizeTransactionData(
          transactionData,
          defaultCurrency: (payload['currency'] ?? currency).toString(),
          defaultMethod: (payload['method'] ?? 'Unknown').toString(),
        );

        final transaction =
            DepositTransactionModel.fromJson(normalizedTransaction);
        dev.log(
            '🟢 DEPOSIT_REMOTE_DS: Successfully created deposit transaction: ${transaction.id}');

        return transaction;
      } else {
        throw Exception('Failed to create deposit: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: DioException creating deposit: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');

      // Extract error message from response if available
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Deposit failed: $errorMessage');
    } catch (e) {
      dev.log('🔴 DEPOSIT_REMOTE_DS: Unexpected error creating deposit: $e');
      throw Exception('Failed to create deposit: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createStripePaymentIntent({
    required double amount,
    required String currency,
  }) async {
    dev.log(
        '🔵 DEPOSIT_REMOTE_DS: Creating Stripe payment intent for $amount $currency');

    try {
      final response = await _dioClient.post(
        '/api/finance/deposit/fiat/stripe',
        data: {
          'amount': amount,
          'currency': currency,
          'intent': true, // This is crucial for Flutter/mobile
        },
      );

      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Stripe payment intent response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Stripe payment intent response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('id') && data.containsKey('clientSecret')) {
          dev.log(
              '🟢 DEPOSIT_REMOTE_DS: Stripe payment intent created successfully');
          return data;
        } else {
          throw Exception(
              'Invalid Stripe response: missing id or clientSecret');
        }
      } else {
        throw Exception(
            'Failed to create Stripe payment intent: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: DioException creating Stripe payment intent: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: Unexpected error creating Stripe payment intent: $e');
      throw Exception('Failed to create Stripe payment intent: $e');
    }
  }

  @override
  Future<DepositTransactionModel> verifyStripePayment({
    required String paymentIntentId,
  }) async {
    dev.log(
        '🔵 DEPOSIT_REMOTE_DS: Verifying Stripe payment intent: $paymentIntentId');

    try {
      final response = await _dioClient.post(
        '/api/finance/deposit/fiat/stripe/verify-intent',
        queryParameters: {
          'intentId': paymentIntentId,
        },
      );

      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Stripe verification response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: Stripe verification response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractPayloadMap(response.data);
        final transactionData = _extractMap(payload['transaction']).isNotEmpty
            ? _extractMap(payload['transaction'])
            : payload;

        final normalizedTransaction = _normalizeTransactionData(
          transactionData,
          defaultCurrency: payload['currency']?.toString() ?? 'USD',
          defaultMethod: payload['method']?.toString() ?? 'Stripe',
        );

        final transaction =
            DepositTransactionModel.fromJson(normalizedTransaction);
        dev.log(
            '🟢 DEPOSIT_REMOTE_DS: Stripe payment verified successfully - Transaction ID: ${transaction.id}');
        return transaction;
      } else {
        throw Exception(
            'Failed to verify Stripe payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: DioException verifying Stripe payment: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');

      // Extract error message from response if available
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Network error: $errorMessage');
    } catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: Unexpected error verifying Stripe payment: $e');
      throw Exception('Failed to verify payment: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createPayPalOrder({
    required double amount,
    required String currency,
  }) async {
    dev.log(
        '🔵 DEPOSIT_REMOTE_DS: Creating PayPal order for $amount $currency');

    try {
      final response = await _dioClient.post(
        '/api/finance/deposit/fiat/paypal',
        data: {
          'amount': amount,
          'currency': currency,
        },
      );

      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: PayPal order response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: PayPal order response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = _extractPayloadMap(response.data);

        if (data.containsKey('id') && data.containsKey('links')) {
          dev.log('🟢 DEPOSIT_REMOTE_DS: PayPal order created successfully');
          return data;
        } else {
          throw Exception('Invalid PayPal response: missing id or links');
        }
      } else {
        throw Exception(
            'Failed to create PayPal order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: DioException creating PayPal order: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: Unexpected error creating PayPal order: $e');
      throw Exception('Failed to create PayPal order: $e');
    }
  }

  @override
  Future<DepositTransactionModel> verifyPayPalPayment({
    required String orderId,
  }) async {
    dev.log(
        '🔵 DEPOSIT_REMOTE_DS: Verifying PayPal payment for order: $orderId');

    try {
      final response = await _dioClient.post(
        '/api/finance/deposit/fiat/paypal/verify',
        queryParameters: {
          'orderId': orderId,
        },
      );

      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: PayPal verification response status: ${response.statusCode}');
      dev.log(
          '🔵 DEPOSIT_REMOTE_DS: PayPal verification response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractPayloadMap(response.data);
        final transactionData = _extractMap(payload['transaction']).isNotEmpty
            ? _extractMap(payload['transaction'])
            : payload;

        final normalizedTransaction = _normalizeTransactionData(
          transactionData,
          defaultCurrency: payload['currency']?.toString() ?? 'USD',
          defaultMethod: 'PayPal',
          defaultMetadata: {
            'orderId': orderId,
            'method': 'PAYPAL',
          },
        );

        return DepositTransactionModel.fromJson(normalizedTransaction);
      } else {
        throw Exception(
            'Failed to verify PayPal payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: DioException verifying PayPal payment: ${e.message}');
      dev.log('🔴 DEPOSIT_REMOTE_DS: Response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      dev.log(
          '🔴 DEPOSIT_REMOTE_DS: Unexpected error verifying PayPal payment: $e');
      throw Exception('Failed to verify PayPal payment: $e');
    }
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    final map = _extractMap(raw);
    if (map['data'] is List) {
      return map['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  Map<String, dynamic> _extractPayloadMap(dynamic raw) {
    final map = _extractMap(raw);
    if (map['data'] is Map) {
      return _extractMap(map['data']);
    }
    return map;
  }

  Map<String, dynamic> _normalizeTransactionData(
    Map<String, dynamic> raw, {
    required String defaultCurrency,
    required String defaultMethod,
    Map<String, dynamic>? defaultMetadata,
  }) {
    final now = DateTime.now().toIso8601String();
    final id =
        raw['id']?.toString() ?? 'txn_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'id': id,
      'userId': raw['userId']?.toString() ?? 'unknown_user',
      'walletId': raw['walletId']?.toString() ?? 'unknown_wallet',
      'type': (raw['type'] ?? 'DEPOSIT').toString(),
      'amount': _toDouble(raw['amount'], 0),
      'status': (raw['status'] ?? 'PENDING').toString(),
      'currency': (raw['currency'] ?? defaultCurrency).toString(),
      'method': (raw['method'] ?? defaultMethod).toString(),
      'fee': raw['fee'] == null ? null : _toDouble(raw['fee'], 0),
      'metadata': raw['metadata'] ?? defaultMetadata,
      'description': raw['description']?.toString(),
      'createdAt': (raw['createdAt'] ?? now).toString(),
    };
  }

  double _toDouble(dynamic raw, double fallback) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw) ?? fallback;
    }
    return fallback;
  }
}
