import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/kyc_level_model.dart';
import '../models/kyc_application_model.dart';

abstract class KycRemoteDataSource {
  Future<List<KycLevelModel>> getKycLevels();
  Future<KycLevelModel> getKycLevelById(String levelId);
  Future<List<KycApplicationModel>> getKycApplications();
  Future<KycApplicationModel> getKycApplicationById(String applicationId);
  Future<KycApplicationModel> submitKycApplication({
    required String levelId,
    required Map<String, dynamic> fields,
  });
  Future<KycApplicationModel> updateKycApplication({
    required String applicationId,
    required Map<String, dynamic> fields,
  });
  Future<String> uploadKycDocument({
    required String filePath,
    String? oldPath,
  });
}

@Injectable(as: KycRemoteDataSource)
class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final DioClient _dioClient;

  KycRemoteDataSourceImpl(this._dioClient);

  /// Extract a List from a potentially wrapped response.
  List _extractList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      for (final key in ['data', 'items', 'result']) {
        if (map.containsKey(key) && map[key] is List) {
          return map[key] as List;
        }
      }
    }
    throw const FormatException('Invalid response format: expected a list');
  }

  /// Extract a Map from a potentially wrapped response.
  Map<String, dynamic> _extractMap(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      if (map.containsKey('id')) return map;
      for (final key in ['data', 'result']) {
        if (map.containsKey(key) && map[key] is Map) {
          return Map<String, dynamic>.from(map[key]);
        }
      }
      return map;
    }
    throw const FormatException('Invalid response format: expected a map');
  }

  @override
  Future<List<KycLevelModel>> getKycLevels() async {
    dev.log('🔵 KYC_REMOTE: Getting KYC levels');

    try {
      final response = await _dioClient.get(ApiConstants.kycLevels);
      dev.log('🟢 KYC_REMOTE: Got KYC levels response');

      final dataList = _extractList(response.data);
      return dataList
          .map((json) =>
              KycLevelModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error getting KYC levels: $e');
      rethrow;
    }
  }

  @override
  Future<KycLevelModel> getKycLevelById(String levelId) async {
    dev.log('🔵 KYC_REMOTE: Getting KYC level by ID: $levelId');

    try {
      final response =
          await _dioClient.get('${ApiConstants.kycLevelById}/$levelId');
      dev.log('🟢 KYC_REMOTE: Got KYC level response');

      final data = _extractMap(response.data);
      return KycLevelModel.fromJson(data);
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error getting KYC level: $e');
      rethrow;
    }
  }

  @override
  Future<List<KycApplicationModel>> getKycApplications() async {
    dev.log('🔵 KYC_REMOTE: Getting KYC applications');

    try {
      final response = await _dioClient.get(ApiConstants.kycApplications);
      dev.log('🟢 KYC_REMOTE: Got KYC applications response');

      final dataList = _extractList(response.data);
      return dataList
          .map((json) =>
              KycApplicationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error getting KYC applications: $e');
      rethrow;
    }
  }

  @override
  Future<KycApplicationModel> getKycApplicationById(
      String applicationId) async {
    dev.log('🔵 KYC_REMOTE: Getting KYC application by ID: $applicationId');

    try {
      final response = await _dioClient
          .get('${ApiConstants.kycApplicationById}/$applicationId');
      dev.log('🟢 KYC_REMOTE: Got KYC application response');

      final data = _extractMap(response.data);
      return KycApplicationModel.fromJson(data);
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error getting KYC application: $e');
      rethrow;
    }
  }

  @override
  Future<KycApplicationModel> submitKycApplication({
    required String levelId,
    required Map<String, dynamic> fields,
  }) async {
    dev.log('🔵 KYC_REMOTE: Submitting KYC application for level: $levelId');

    try {
      final data = {
        'levelId': levelId,
        'fields': fields,
      };

      final response = await _dioClient.post(
        ApiConstants.submitKycApplication,
        data: data,
      );

      dev.log('🟢 KYC_REMOTE: Submitted KYC application');

      // Backend returns { message, application }
      final responseData = response.data;
      if (responseData is Map && responseData.containsKey('application')) {
        return KycApplicationModel.fromJson(
            Map<String, dynamic>.from(responseData['application']));
      }
      final appData = _extractMap(responseData);
      return KycApplicationModel.fromJson(appData);
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error submitting KYC application: $e');
      rethrow;
    }
  }

  @override
  Future<KycApplicationModel> updateKycApplication({
    required String applicationId,
    required Map<String, dynamic> fields,
  }) async {
    dev.log('🔵 KYC_REMOTE: Updating KYC application: $applicationId');

    try {
      final data = {
        'fields': fields,
      };

      final response = await _dioClient.put(
        '${ApiConstants.updateKycApplication}/$applicationId',
        data: data,
      );

      dev.log('🟢 KYC_REMOTE: Updated KYC application');

      final responseData = response.data;
      if (responseData is Map && responseData.containsKey('application')) {
        return KycApplicationModel.fromJson(
            Map<String, dynamic>.from(responseData['application']));
      }
      final appData = _extractMap(responseData);
      return KycApplicationModel.fromJson(appData);
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error updating KYC application: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadKycDocument({
    required String filePath,
    String? oldPath,
  }) async {
    dev.log('🔵 KYC_REMOTE: Uploading KYC document: $filePath');

    try {
      // Read file and convert to base64 (backend expects JSON, not multipart)
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      // Determine MIME type
      final mimeType =
          lookupMimeType(filePath) ?? 'application/octet-stream';
      final base64WithPrefix = 'data:$mimeType;base64,$base64String';

      final filename = p.basename(filePath);

      final data = {
        'dir': 'kyc',
        'file': base64WithPrefix,
        'filename': filename,
        if (oldPath != null) 'oldPath': oldPath,
      };

      final response = await _dioClient.post(
        ApiConstants.kycDocumentUpload,
        data: data,
      );

      dev.log('🟢 KYC_REMOTE: Uploaded KYC document');

      // Backend returns { url, filename, size, mimeType }
      final responseData = response.data;
      if (responseData is Map) {
        return responseData['url'] as String? ?? '';
      }
      return '';
    } catch (e) {
      dev.log('🔴 KYC_REMOTE: Error uploading KYC document: $e');
      rethrow;
    }
  }
}
