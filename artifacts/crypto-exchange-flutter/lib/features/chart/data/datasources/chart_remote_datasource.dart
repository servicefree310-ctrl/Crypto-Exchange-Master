import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/ohlcv_model.dart';
import '../../domain/entities/chart_entity.dart';

abstract class ChartRemoteDataSource {
  Future<List<OhlcvModel>> getChartHistory({
    required String symbol,
    required ChartTimeframe interval,
    int? from,
    int? to,
    int? limit,
  });
}

@Injectable(as: ChartRemoteDataSource)
class ChartRemoteDataSourceImpl implements ChartRemoteDataSource {
  final Dio _dio;

  const ChartRemoteDataSourceImpl(this._dio);

  @override
  Future<List<OhlcvModel>> getChartHistory({
    required String symbol,
    required ChartTimeframe interval,
    int? from,
    int? to,
    int? limit,
  }) async {
    try {
      // Build query parameters following v5 backend structure
      final queryParams = <String, dynamic>{
        'symbol': symbol,
        'interval': interval.value,
      };

      // Add optional parameters
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (limit != null) queryParams['limit'] = limit;

      // v5 backend now requires a "duration" parameter (milliseconds time span).
      // If both `from` and `to` are provided we can derive it.
      if (from != null && to != null) {
        queryParams['duration'] = to - from;
      } else if (limit != null) {
        // Fallback: duration = intervalMs * limit (approx). We estimate using
        // the timeframe milliseconds helper to keep the API happy even if
        // `from`/`to` are omitted.
        queryParams['duration'] = interval.milliseconds * limit;
      }

      dev.log('🌐 CHART_API: Making request to ${ApiConstants.chartHistory}');
      dev.log('🌐 CHART_API: Query params: $queryParams');

      // Make request to v5 chart history endpoint
      final response = await _dio.get(
        ApiConstants.chartHistory,
        queryParameters: queryParams,
      );

      dev.log('🌐 CHART_API: Response status: ${response.statusCode}');
      dev.log('🌐 CHART_API: Response headers: ${response.headers}');
      dev.log('🌐 CHART_API: Response data type: ${response.data.runtimeType}');

      // Handle successful response
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        dev.log('🌐 CHART_API: Full response data: $data');

        // Check if response has the expected structure
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final chartData = data['data'];
          dev.log(
              '🌐 CHART_API: Found data key, chartData type: ${chartData.runtimeType}');
          dev.log(
              '🌐 CHART_API: chartData length: ${chartData is List ? chartData.length : 'not a list'}');

          if (chartData is List) {
            dev.log(
                '🌐 CHART_API: Converting ${chartData.length} items to OhlcvModel');
            if (chartData.isNotEmpty) {
              dev.log('🌐 CHART_API: First item sample: ${chartData.first}');
            }
            // Convert array format to OhlcvModel objects
            final models = chartData
                .map((item) => OhlcvModel.fromArray(item as List<dynamic>))
                .toList();
            dev.log(
                '🌐 CHART_API: Successfully converted to ${models.length} OhlcvModel objects');
            return models;
          }
        }

        // Handle direct array response (fallback)
        if (data is List) {
          dev.log(
              '🌐 CHART_API: Direct array response with ${data.length} items');
          if (data.isNotEmpty) {
            dev.log('🌐 CHART_API: First item sample: ${data.first}');
          }
          final models = data
              .map((item) => OhlcvModel.fromArray(item as List<dynamic>))
              .toList();
          dev.log(
              '🌐 CHART_API: Successfully converted to ${models.length} OhlcvModel objects');
          return models;
        }

        dev.log(
            '🌐 CHART_API: No valid data structure found, returning empty list');
        // Return empty list if no valid data
        return [];
      }

      throw ServerException(
        'Invalid response from chart history API',
        response.statusCode?.toString(),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          e.response?.data?['message'] ?? 'Chart history request failed',
          e.response?.statusCode?.toString(),
        );
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(
        'Unexpected error fetching chart history: $e',
        '500',
      );
    }
  }
}
