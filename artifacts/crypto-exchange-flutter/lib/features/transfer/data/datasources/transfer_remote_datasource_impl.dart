import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transfer_request_model.dart';
import '../models/transfer_response_model.dart';
import '../models/transfer_option_model.dart';
import '../models/currency_option_model.dart';
import 'transfer_remote_datasource.dart';

@Injectable(as: TransferRemoteDataSource)
class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final DioClient _dioClient;

  const TransferRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TransferOptionModel>> getTransferOptions() async {
    try {
      final response = await _dioClient.get(ApiConstants.transferOptions);

      // Response structure: { "types": [{"id": "FIAT", "name": "Fiat"}, ...] }
      final List<dynamic> types = response.data['types'] as List<dynamic>;

      return types
          .map((json) =>
              TransferOptionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch transfer options: ${e.message}');
    }
  }

  @override
  Future<List<CurrencyOptionModel>> getCurrencies({
    required String walletType,
    String? targetWalletType,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'action': 'transfer',
        'walletType': walletType,
      };

      if (targetWalletType != null) {
        queryParams['targetWalletType'] = targetWalletType;
      }

      final response = await _dioClient.get(
        ApiConstants.transferCurrency,
        queryParameters: queryParams,
      );

      // The API always returns: { "from": [...], "to": [...] }
      final data = response.data;

      if (targetWalletType != null) {
        // For wallet-to-wallet transfers, return 'to' currencies (target currencies)
        final List<dynamic> toCurrencies = data['to'] as List<dynamic>;
        return toCurrencies
            .map((json) =>
                CurrencyOptionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // For source wallet selection, return 'from' currencies (source currencies)
        final List<dynamic> fromCurrencies = data['from'] as List<dynamic>;
        return fromCurrencies
            .map((json) =>
                CurrencyOptionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch currencies: ${e.message}');
    }
  }

  @override
  Future<List<CurrencyOptionModel>> getWalletBalance({
    required String walletType,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.transferCurrency,
        queryParameters: {
          'action': 'transfer',
          'walletType': walletType,
        },
      );

      // The API always returns: { "from": [...], "to": [...] }
      final data = response.data;
      final List<dynamic> fromCurrencies = data['from'] as List<dynamic>;

      return fromCurrencies
          .map((json) =>
              CurrencyOptionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch wallet balance: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> validateRecipient(String uuid) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.transferValidate,
        queryParameters: {'uuid': uuid},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'exists': false, 'message': 'Recipient not found'};
      }
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to validate recipient',
      );
    }
  }

  @override
  Future<TransferResponseModel> createTransfer(
    TransferRequestModel request,
  ) async {
    try {
      // For client transfers, toType defaults to fromType (same wallet type)
      // and toCurrency defaults to fromCurrency (same currency)
      final effectiveToType = request.toType ??
          (request.transferType == 'client' ? request.fromType : null);

      if (effectiveToType == null) {
        throw Exception('toType is required for transfer');
      }

      final Map<String, dynamic> requestBody = {
        'fromType': request.fromType,
        'toType': effectiveToType,
        'fromCurrency': request.fromCurrency,
        'toCurrency': request.toCurrency ?? request.fromCurrency,
        'amount': request.amount,
        'transferType': request.transferType,
      };

      // Add clientId for client transfers
      if (request.transferType == 'client' && request.clientId != null) {
        requestBody['clientId'] = request.clientId;
      }

      final response =
          await _dioClient.post('/api/finance/transfer', data: requestBody);

      final normalized = _normalizeTransferResponse(
        response.data,
        fallbackFromType: request.fromType,
        fallbackToType: effectiveToType,
        fallbackFromCurrency: request.fromCurrency,
        fallbackToCurrency: request.toCurrency ?? request.fromCurrency,
        fallbackAmount: request.amount,
      );

      return TransferResponseModel.fromJson(normalized);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          e.response?.data?['message'] ?? 'Invalid transfer request',
        );
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthException('Insufficient permissions');
      } else {
        throw ServerException(
          e.response?.data?['message'] ?? 'Unexpected error occurred',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  Map<String, dynamic> _normalizeTransferResponse(
    dynamic raw, {
    required String fallbackFromType,
    required String fallbackToType,
    required String fallbackFromCurrency,
    required String fallbackToCurrency,
    required double fallbackAmount,
  }) {
    final payload = _asMap(raw);
    final now = DateTime.now().toIso8601String();

    final fromTransfer = _normalizeTransferTransaction(
      payload['fromTransfer'],
      fallbackAmount: fallbackAmount,
      fallbackType: 'OUTGOING_TRANSFER',
      fallbackStatus: 'PENDING',
      fallbackDescription: 'Transfer sent',
      fallbackTimestamp: now,
    );

    final toTransfer = _normalizeTransferTransaction(
      payload['toTransfer'] ?? payload['fromTransfer'],
      fallbackAmount: fallbackAmount,
      fallbackType: 'INCOMING_TRANSFER',
      fallbackStatus: fromTransfer['status'] as String,
      fallbackDescription: 'Transfer received',
      fallbackTimestamp: now,
    );

    return {
      'message':
          (payload['message'] ?? 'Transfer initiated successfully').toString(),
      'fromTransfer': fromTransfer,
      'toTransfer': toTransfer,
      'fromType': (payload['fromType'] ?? fallbackFromType).toString(),
      'toType': (payload['toType'] ?? fallbackToType).toString(),
      'fromCurrency':
          (payload['fromCurrency'] ?? fallbackFromCurrency).toString(),
      'toCurrency': (payload['toCurrency'] ?? fallbackToCurrency).toString(),
    };
  }

  Map<String, dynamic> _normalizeTransferTransaction(
    dynamic raw, {
    required double fallbackAmount,
    required String fallbackType,
    required String fallbackStatus,
    required String fallbackDescription,
    required String fallbackTimestamp,
  }) {
    final payload = _asMap(raw);
    final transactionId = payload['id']?.toString() ??
        'txn_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'id': transactionId,
      'userId': payload['userId']?.toString() ?? '',
      'walletId': payload['walletId']?.toString() ?? '',
      'type': (payload['type'] ?? fallbackType).toString(),
      'amount': _toDouble(payload['amount'], fallbackAmount),
      'fee': _toDouble(payload['fee'], 0),
      'status': (payload['status'] ?? fallbackStatus).toString(),
      'description': (payload['description'] ?? fallbackDescription).toString(),
      'metadata': _normalizeMetadata(payload['metadata']),
      'createdAt': (payload['createdAt'] ?? fallbackTimestamp).toString(),
      'updatedAt':
          (payload['updatedAt'] ?? payload['createdAt'] ?? fallbackTimestamp)
              .toString(),
    };
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
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

  String? _normalizeMetadata(dynamic metadata) {
    if (metadata == null) {
      return null;
    }
    if (metadata is String) {
      return metadata;
    }
    if (metadata is Map || metadata is List) {
      return jsonEncode(metadata);
    }
    return metadata.toString();
  }
}
