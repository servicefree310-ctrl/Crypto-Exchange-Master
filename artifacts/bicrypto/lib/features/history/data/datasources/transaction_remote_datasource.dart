import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<TransactionListModel> getTransactions({
    TransactionFilterEntity? filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<TransactionModel> getTransactionById(String id);

  Future<TransactionListModel> searchTransactions({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  Future<Map<String, dynamic>> getTransactionStats();
}

@Injectable(as: TransactionRemoteDataSource)
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  const TransactionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TransactionListModel> getTransactions({
    TransactionFilterEntity? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'perPage': pageSize, // Backend expects 'perPage', not 'pageSize'
      };

      // Add filter parameters if provided
      if (filter != null) {
        final filterParams = filter.toQueryParameters();
        queryParameters.addAll(filterParams);
      }

      final response = await _apiClient.get(
        ApiConstants.transactions,
        queryParameters: queryParameters,
      );

      dev.log(
          '🔄 TRANSACTION_DATASOURCE: Response type: ${response.data?.runtimeType}');
      dev.log(
          '🔄 TRANSACTION_DATASOURCE: Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'Not a Map'}');

      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }

      // Parse the backend response structure: { items: [...], pagination: {...} }
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response has backend structure with items
        if (responseData.containsKey('items')) {
          dev.log('🔄 TRANSACTION_DATASOURCE: Found items in response');

          try {
            // Extract transactions from items array
            final itemsList = responseData['items'] as List;
            final transactions = itemsList
                .map((json) =>
                    TransactionModel.fromJson(json as Map<String, dynamic>))
                .toList();

            // Extract pagination data (with fallbacks)
            final paginationData =
                responseData['pagination'] as Map<String, dynamic>?;
            final totalItems =
                paginationData?['totalItems'] ?? transactions.length;
            final currentPage = paginationData?['currentPage'] ?? page;
            final perPage = paginationData?['perPage'] ?? pageSize;
            final totalPages = paginationData?['totalPages'] ?? 1;

            dev.log(
                '🔄 TRANSACTION_DATASOURCE: Parsed ${transactions.length} transactions');
            dev.log(
                '🔄 TRANSACTION_DATASOURCE: Pagination - page $currentPage of $totalPages');

            return TransactionListModel(
              items: transactions,
              pagination: TransactionPaginationModel(
                totalItems: totalItems,
                currentPage: currentPage,
                perPage: perPage,
                totalPages: totalPages,
              ),
            );
          } catch (e) {
            dev.log(
                '❌ TRANSACTION_DATASOURCE: Error parsing items structure - $e');
            throw ServerException(
                message: 'Failed to parse transaction data: $e');
          }
        }
        // Fallback: Check if response has a data field (alternative structure)
        else if (responseData.containsKey('data')) {
          dev.log('🔄 TRANSACTION_DATASOURCE: Found data field in response');
          final transactions = (responseData['data'] as List)
              .map((json) =>
                  TransactionModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return TransactionListModel(
            items: transactions,
            pagination: TransactionPaginationModel(
              totalItems: responseData['totalCount'] ?? transactions.length,
              currentPage: responseData['currentPage'] ?? page,
              perPage: responseData['pageSize'] ?? pageSize,
              totalPages: responseData['totalPages'] ?? 1,
            ),
          );
        }
        // Fallback: Direct transaction array in response
        else {
          dev.log('🔄 TRANSACTION_DATASOURCE: Using fallback parsing');
          final transactions = (responseData['transactions'] as List? ?? [])
              .map((json) =>
                  TransactionModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return TransactionListModel(
            items: transactions,
            pagination: TransactionPaginationModel(
              totalItems: transactions.length,
              currentPage: page,
              perPage: pageSize,
              totalPages: 1,
            ),
          );
        }
      } else if (response.data is List) {
        // Direct array response
        final transactions = (response.data as List)
            .map((json) =>
                TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return TransactionListModel(
          items: transactions,
          pagination: TransactionPaginationModel(
            totalItems: transactions.length,
            currentPage: page,
            perPage: pageSize,
            totalPages: 1,
          ),
        );
      } else {
        throw ServerException(message: 'Invalid response format');
      }
    } on DioException catch (e) {
      dev.log('❌ TRANSACTION_DATASOURCE: Dio error - ${e.type}: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Transactions not found');
      } else {
        final message = e.response?.data?['message'] ??
            e.message ??
            'Server error occurred';
        throw ServerException(message: message);
      }
    } catch (e) {
      dev.log('❌ TRANSACTION_DATASOURCE: Unexpected error - $e');
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.transactions}/$id');

      dev.log(
          '🔄 TRANSACTION_DATASOURCE: Get transaction by ID response: ${response.data}');

      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }

      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      dev.log(
          '❌ TRANSACTION_DATASOURCE: Dio error getting transaction $id - ${e.type}: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Transaction not found');
      } else {
        final message = e.response?.data?['message'] ??
            e.message ??
            'Server error occurred';
        throw ServerException(message: message);
      }
    } catch (e) {
      dev.log('❌ TRANSACTION_DATASOURCE: Unexpected error - $e');
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<TransactionListModel> searchTransactions({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'search': query,
        'page': page,
        'perPage': pageSize, // Backend expects 'perPage', not 'pageSize'
      };

      final response = await _apiClient.get(
        ApiConstants.transactions,
        queryParameters: queryParameters,
      );

      dev.log(
          '🔄 TRANSACTION_DATASOURCE: Search transactions response: ${response.data}');

      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }

      // Parse the backend response structure: { items: [...], pagination: {...} }
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response has backend structure with items and pagination
        if (responseData.containsKey('items') &&
            responseData.containsKey('pagination')) {
          return TransactionListModel.fromJson(responseData);
        }
        // Fallback: Check if response has a data field (alternative structure)
        else if (responseData.containsKey('data')) {
          final transactions = (responseData['data'] as List)
              .map((json) =>
                  TransactionModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return TransactionListModel(
            items: transactions,
            pagination: TransactionPaginationModel(
              totalItems: responseData['totalCount'] ?? transactions.length,
              currentPage: responseData['currentPage'] ?? page,
              perPage: responseData['pageSize'] ?? pageSize,
              totalPages: responseData['totalPages'] ?? 1,
            ),
          );
        }
        // Fallback: Direct transaction array in response
        else {
          final transactions = (responseData['transactions'] as List? ?? [])
              .map((json) =>
                  TransactionModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return TransactionListModel(
            items: transactions,
            pagination: TransactionPaginationModel(
              totalItems: transactions.length,
              currentPage: page,
              perPage: pageSize,
              totalPages: 1,
            ),
          );
        }
      } else if (response.data is List) {
        final transactions = (response.data as List)
            .map((json) =>
                TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return TransactionListModel(
          items: transactions,
          pagination: TransactionPaginationModel(
            totalItems: transactions.length,
            currentPage: page,
            perPage: pageSize,
            totalPages: 1,
          ),
        );
      } else {
        throw ServerException(message: 'Invalid response format');
      }
    } on DioException catch (e) {
      dev.log(
          '❌ TRANSACTION_DATASOURCE: Dio error searching - ${e.type}: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'No transactions found');
      } else {
        final message = e.response?.data?['message'] ??
            e.message ??
            'Server error occurred';
        throw ServerException(message: message);
      }
    } catch (e) {
      dev.log('❌ TRANSACTION_DATASOURCE: Unexpected error - $e');
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionStats() async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.transactions}/stats');

      dev.log(
          '🔄 TRANSACTION_DATASOURCE: Get transaction stats response: ${response.data}');

      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      dev.log(
          '❌ TRANSACTION_DATASOURCE: Dio error getting stats - ${e.type}: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Stats not found');
      } else {
        final message = e.response?.data?['message'] ??
            e.message ??
            'Server error occurred';
        throw ServerException(message: message);
      }
    } catch (e) {
      dev.log('❌ TRANSACTION_DATASOURCE: Unexpected error - $e');
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }
}
