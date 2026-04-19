import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../transfer/data/models/currency_option_model.dart';
import '../models/withdraw_method_model.dart';
import '../models/withdraw_request_model.dart';
import '../models/withdraw_response_model.dart';
import 'withdraw_remote_datasource.dart';

@Injectable(as: WithdrawRemoteDataSource)
class WithdrawRemoteDataSourceImpl implements WithdrawRemoteDataSource {
  final DioClient _dioClient;

  const WithdrawRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CurrencyOptionModel>> getWithdrawCurrencies({
    required String walletType,
  }) async {
    try {
      dev.log('📍 Fetching withdraw currencies for wallet type: $walletType');

      final response = await _dioClient.get(
        ApiConstants.withdrawCurrencies,
        queryParameters: {
          'action': 'withdraw',
          'walletType': walletType,
        },
      );

      dev.log('✅ Response received');
      dev.log('📦 Response data: ${response.data}');
      dev.log('📦 Response type: ${response.data.runtimeType}');

      if (response.data == null) {
        dev.log('⚠️ Response data is null');
        return [];
      }

      // Handle different response structures
      List<dynamic> currencyList = [];

      if (response.data is Map) {
        dev.log('📦 Response is Map');
        final responseMap = response.data as Map<String, dynamic>;

        // Check for 'data' field first
        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          currencyList = responseMap['data'] as List;
          dev.log('📦 Found data field with ${currencyList.length} items');
        }
        // Check if the response itself contains currency data
        else if (responseMap.containsKey('currencies') &&
            responseMap['currencies'] is List) {
          currencyList = responseMap['currencies'] as List;
          dev.log(
              '📦 Found currencies field with ${currencyList.length} items');
        }
        // Handle single currency response
        else if (responseMap.containsKey('value') &&
            responseMap.containsKey('label')) {
          currencyList = [responseMap];
          dev.log('📦 Single currency response');
        }
      } else if (response.data is List) {
        currencyList = response.data as List;
        dev.log('📦 Response is List with ${currencyList.length} items');
      }

      if (currencyList.isEmpty) {
        dev.log('⚠️ No currencies found in response');
        return [];
      }

      dev.log('💰 Found ${currencyList.length} currencies for $walletType');
      return currencyList.map((json) {
        final currencyData = json as Map<String, dynamic>;

        // Extract balance from label if not provided separately
        double? balance;
        if (currencyData['balance'] != null) {
          balance = (currencyData['balance'] as num).toDouble();
        } else if (currencyData['label'] != null) {
          // Label format: "USD - 5323.6" or "BTC - 33.8"
          final labelParts = currencyData['label'].toString().split(' - ');
          if (labelParts.length > 1) {
            balance = double.tryParse(labelParts[1]);
            dev.log(
                '💵 Extracted balance from label: ${currencyData['value']} = $balance');
          }
        }

        // Create model with extracted balance
        return CurrencyOptionModel(
          value: currencyData['value'] ?? '',
          label: currencyData['label'] ?? '',
          icon: currencyData['icon'],
          balance: balance,
        );
      }).toList();
    } on DioException catch (e) {
      dev.log('❌ DioException fetching currencies for $walletType:');
      dev.log('   Status Code: ${e.response?.statusCode}');
      dev.log('   Message: ${e.response?.data}');
      dev.log('   Error Type: ${e.type}');

      if (e.response?.statusCode == 404) {
        dev.log('🔍 No wallets with balance found for $walletType');
        return [];
      }

      throw ServerException(e.response?.data?['message'] ??
          e.response?.data?.toString() ??
          'Failed to fetch currencies for $walletType');
    } catch (e) {
      dev.log('❌ Unexpected error fetching currencies for $walletType: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<WithdrawMethodModel>> getWithdrawMethods({
    required String walletType,
    required String currency,
  }) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.withdrawMethods}/$walletType/$currency',
        queryParameters: {
          'action': 'withdraw',
        },
      );

      final rawMethods = _extractWithdrawMethods(response.data, walletType);

      return rawMethods.map((item) {
        final normalized = _normalizeWithdrawMethodData(item);
        var method = WithdrawMethodModel.fromJson(normalized);

        // Backward compatibility: if backend doesn't provide fields metadata.
        if (walletType != 'FIAT' &&
            !_hasMeaningfulCustomFields(method.customFields)) {
          method = method.copyWith(
            customFields: _generateCustomFieldsForNetwork({
              'network': method.network,
              ...item,
            }),
          );
        }

        return method;
      }).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch withdrawal methods',
      );
    }
  }

  @override
  Future<WithdrawResponseModel> submitWithdrawal(
    WithdrawRequestModel request,
  ) async {
    try {
      String endpoint;
      Map<String, dynamic> requestBody = {};

      if (request.walletType == 'FIAT') {
        endpoint = ApiConstants.withdrawFiat;
        requestBody = {
          'methodId': request.methodId,
          'amount': request.amount,
          'currency': request.currency,
          'customFields': request.customFields ?? {},
        };
      } else if (request.walletType == 'SPOT' || request.walletType == 'ECO') {
        endpoint = request.walletType == 'SPOT'
            ? ApiConstants.withdrawSpot
            : ApiConstants.ecoWithdraw;

        // Extract address from custom fields if needed
        String? toAddress = request.toAddress;
        if (toAddress == null && request.customFields != null) {
          final addressField = request.customFields!.keys.firstWhere(
            (key) => key.toLowerCase().contains('address'),
            orElse: () => '',
          );
          if (addressField.isNotEmpty) {
            toAddress = request.customFields![addressField];
          }
        }

        requestBody = {
          'currency': request.currency,
          'chain': request.chain ?? request.methodId,
          'amount': request.amount,
          'toAddress': toAddress,
          if (request.memo != null) 'memo': request.memo,
          ...?request.customFields,
        };
      } else {
        throw ServerException('Unsupported wallet type: ${request.walletType}');
      }

      final response = await _dioClient.post(
        endpoint,
        data: requestBody,
      );

      return WithdrawResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          e.response?.data?['message'] ?? 'Invalid withdrawal request',
        );
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthException('Insufficient permissions');
      } else {
        throw ServerException(
          e.response?.data?['message'] ?? 'Failed to process withdrawal',
        );
      }
    }
  }

  List<Map<String, dynamic>> _extractWithdrawMethods(
    dynamic responseData,
    String walletType,
  ) {
    List<dynamic> methods = [];

    if (walletType == 'FIAT') {
      if (responseData is Map<String, dynamic>) {
        final rawMethods = responseData['methods'];
        if (rawMethods is List) {
          methods = rawMethods;
        }
      }
    } else {
      if (responseData is List) {
        methods = responseData;
      } else if (responseData is Map<String, dynamic>) {
        final rawMethods = responseData['methods'];
        final rawNetworks = responseData['networks'];
        if (rawMethods is List) {
          methods = rawMethods;
        } else if (rawNetworks is List) {
          methods = rawNetworks;
        }
      }
    }

    return methods
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _normalizeWithdrawMethodData(
    Map<String, dynamic> data,
  ) {
    final feeData = data['fee'];
    final limitsData = data['limits'];
    final feesData = data['fees'];
    final withdrawLimits = limitsData is Map ? limitsData['withdraw'] : null;

    var fixedFee = _toDouble(data['fixedFee']);
    var percentageFee = _toDouble(data['percentageFee']);

    fixedFee ??= _toDouble(data['fee']) ??
        _toDouble(feesData is Map ? feesData['withdraw'] : null) ??
        _toDouble((feeData is Map ? feeData['min'] : null));

    percentageFee ??= _toDouble(feeData is Map ? feeData['percentage'] : null);

    final minAmount = _toDouble(data['minAmount']) ??
        _toDouble(data['min_withdraw']) ??
        _toDouble(withdrawLimits is Map ? withdrawLimits['min'] : null);

    final maxAmount = _toDouble(data['maxAmount']) ??
        _toDouble(data['max_withdraw']) ??
        _toDouble(withdrawLimits is Map ? withdrawLimits['max'] : null);

    final network = (data['network'] ?? data['chain'])?.toString();

    dynamic customFields = data['customFields'];
    if (customFields is List || customFields is Map) {
      customFields = json.encode(customFields);
    }

    return {
      'id': (data['id'] ?? data['network'] ?? data['chain'] ?? '').toString(),
      'title': (data['title'] ??
              data['name'] ??
              data['network'] ??
              data['chain'] ??
              '')
          .toString(),
      'instructions': data['instructions']?.toString(),
      'fixedFee': fixedFee,
      'percentageFee': percentageFee,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'network': network,
      'customFields': customFields is String ? customFields : null,
      'image': (data['image'] ?? data['icon'])?.toString(),
      'isActive': data['isActive'] ?? data['active'] ?? true,
    };
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _hasMeaningfulCustomFields(String? customFields) {
    if (customFields == null || customFields.trim().isEmpty) {
      return false;
    }
    return customFields.trim() != '[]';
  }

  // Helper method to generate custom fields JSON string for network-based withdrawals
  String _generateCustomFieldsForNetwork(Map<String, dynamic> networkData) {
    final fields = [
      {
        'name': 'address',
        'title': 'Withdrawal Address',
        'type': 'text',
        'required': true,
        'placeholder': 'Enter your ${networkData['network'] ?? ''} address',
      },
    ];

    // Add memo field if supported - check various possible field names
    final supportsMemo = networkData['supportsMemo'] == true ||
        networkData['hasMemo'] == true ||
        networkData['has_memo'] == true ||
        networkData['requires_memo'] == true ||
        networkData['requiresMemo'] == true;

    if (supportsMemo) {
      fields.add({
        'name': 'memo',
        'title': 'Memo/Tag',
        'type': 'text',
        'required': networkData['requires_memo'] == true ||
            networkData['requiresMemo'] == true,
        'placeholder': 'Enter memo or tag if required by the exchange',
      });
    }

    return json.encode(fields);
  }
}
