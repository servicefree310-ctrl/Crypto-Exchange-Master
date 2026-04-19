import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

@singleton
class DioClient {
  final Dio _dio;
  final FlutterSecureStorage? _secureStorage;

  DioClient(
    this._dio, {
    FlutterSecureStorage? secureStorage,
    SharedPreferences? preferences,
  }) : _secureStorage = secureStorage {
    _dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout =
          const Duration(milliseconds: AppConstants.connectTimeoutDuration)
      ..options.receiveTimeout =
          const Duration(milliseconds: AppConstants.receiveTimeoutDuration)
      ..options.responseType = ResponseType.json
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  // GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timeout');
        case DioExceptionType.badResponse:
          return _handleServerError(error);
        case DioExceptionType.cancel:
          return NetworkException('Request cancelled');
        case DioExceptionType.connectionError:
          return NetworkException('No internet connection');
        default:
          return NetworkException('Unexpected error occurred');
      }
    }
    return NetworkException('Unexpected error occurred');
  }

  Exception _handleServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          data?['message'] ?? 'Bad request',
        );
      case 401:
        return UnauthorizedException(
          data?['message'] ?? 'Unauthorized access',
        );
      case 403:
        return ForbiddenException(
          data?['message'] ?? 'Access forbidden',
        );
      case 404:
        return NotFoundException(
          data?['message'] ?? 'Resource not found',
        );
      case 422:
        return ValidationException(
          data?['message'] ?? 'Validation failed',
          data?['errors'],
        );
      case 500:
        return ServerException(
          data?['message'] ?? 'Internal server error',
        );
      default:
        return ServerException(
          data?['message'] ?? 'Server error occurred',
        );
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage? _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_secureStorage != null) {
      final accessToken = await _readTokenSafe(AppConstants.accessTokenKey);
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      final csrfToken = await _readTokenSafe(AppConstants.csrfTokenKey);
      if (csrfToken != null) {
        options.headers['X-CSRF-Token'] = csrfToken;
      }

      final sessionId = await _readTokenSafe(AppConstants.sessionIdKey);
      if (sessionId != null) {
        options.headers['sessionid'] = sessionId;
      }
    }

    handler.next(options);
  }

  // Mirrors the web fallback used in AuthLocalDataSource: on Flutter web,
  // read tokens from SharedPreferences (stable) instead of FSS (Web Crypto
  // OperationError). On native, fall back to FSS.
  Future<String?> _readTokenSafe(String key) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('_tok_$key');
      }
      return await _secureStorage!.read(key: key);
    } catch (_) {
      return null;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      // Implement token refresh logic here
    }
    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only log non-market API calls to reduce noise
    if (!options.path.contains('/exchange/') &&
        !options.path.contains('/finance/wallet')) {
      dev.log('🌐 ${options.method} ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only log non-market API responses to reduce noise
    if (!response.requestOptions.path.contains('/exchange/') &&
        !response.requestOptions.path.contains('/finance/wallet')) {
      dev.log(
          '✅ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log(
        '❌ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.method} ${err.requestOptions.path}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle global errors here
    handler.next(err);
  }
}
