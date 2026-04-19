import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../models/legal_page_model.dart';

abstract class LegalRemoteDataSource {
  Future<LegalPageModel> getLegalPage(String pageId);
}

@Injectable(as: LegalRemoteDataSource)
class LegalRemoteDataSourceImpl implements LegalRemoteDataSource {
  final DioClient _dioClient;

  const LegalRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LegalPageModel> getLegalPage(String pageId) async {
    try {
      // Call V5 backend API: GET /api/content/default-page/{pageId}
      dev.log('🔍 Fetching legal page: $pageId');
      final response = await _dioClient.get('/api/content/default-page/$pageId');

      dev.log('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle response data properly - ensure it's a Map
        final responseData = response.data;

        dev.log('📦 Response data type: ${responseData.runtimeType}');

        // Log the full response for debugging (truncate if too long)
        final dataString = responseData.toString();
        dev.log('📦 Response data: ${dataString.length > 500 ? '${dataString.substring(0, 500)}...[truncated]' : dataString}');

        if (responseData is Map<String, dynamic>) {
          dev.log('✅ Response is a valid Map, parsing...');
          try {
            return LegalPageModel.fromJson(responseData);
          } catch (e) {
            dev.log('❌ Error parsing JSON: $e');
            dev.log('🔍 Response keys: ${responseData.keys.toList()}');
            dev.log('🔍 Meta field type: ${responseData['meta']?.runtimeType}');
            dev.log('🔍 Meta field value: ${responseData['meta']}');
            rethrow;
          }
        } else if (responseData is String) {
          // If the response is a string, try to parse it as JSON
          dev.log('⚠️ Response is a String, attempting JSON parse');
          throw Exception('Unexpected string response. API should return JSON object.');
        } else {
          dev.log('❌ Unexpected response type');
          throw Exception('Unexpected response type: ${responseData.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch legal page: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log('❌ DioException: ${e.message}');
      dev.log('❌ Response data: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw Exception('Legal page not found: $pageId');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      dev.log('❌ Error: $e');
      dev.log('❌ Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }
}
