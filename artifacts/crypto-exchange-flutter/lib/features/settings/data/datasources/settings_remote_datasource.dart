import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/settings_model.dart';
import '../../domain/entities/settings_params.dart';

@injectable
class SettingsRemoteDataSource {
  const SettingsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<SettingsModel> getSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.settings);

      // Handle the response structure from v5 backend
      final data = response.data;

      // Extract settings array and extensions array
      final settingsList = (data['settings'] as List<dynamic>)
          .map((item) => SettingItemModel(
                key: item['key'] as String,
                value: item['value'] as String,
              ))
          .toList();

      final extensionsList = (data['extensions'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [];

      return SettingsModel(
        settings: settingsList,
        extensions: extensionsList,
      );
    } on DioException catch (e) {
      throw Exception('Failed to fetch settings: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching settings: $e');
    }
  }

  Future<SettingsModel> updateSettings(UpdateSettingsParams params) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.settings,
        data: params.settings,
      );

      // Handle the response structure from v5 backend
      final data = response.data;

      // Extract settings array and extensions array
      final settingsList = (data['settings'] as List<dynamic>)
          .map((item) => SettingItemModel(
                key: item['key'] as String,
                value: item['value'] as String,
              ))
          .toList();

      final extensionsList = (data['extensions'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [];

      return SettingsModel(
        settings: settingsList,
        extensions: extensionsList,
      );
    } on DioException catch (e) {
      throw Exception('Failed to update settings: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating settings: $e');
    }
  }
}
