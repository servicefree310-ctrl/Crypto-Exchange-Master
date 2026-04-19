import 'dart:developer' as dev;


import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(Map<String, dynamic> profileData);
  Future<void> toggleTwoFactor(bool enabled);
  Future<Map<String, dynamic>> generateTwoFactorSecret({
    required String type,
    String? phoneNumber,
  });
  Future<void> verifyTwoFactorSetup({
    required String secret,
    required String code,
    required String type,
  });
  Future<Map<String, dynamic>> saveTwoFactorSetup({
    required String secret,
    required String type,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ProfileModel> getProfile() async {
    dev.log('🔵 PROFILE_REMOTE_DS: Getting profile');

    try {
      final response = await dioClient.get(ApiConstants.userProfile);

      // dev.log('🔵 PROFILE_REMOTE_DS: Response status: ${response.statusCode}');
      // dev.log('🔵 PROFILE_REMOTE_DS: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final profileData = response.data;
        dev.log('🟢 PROFILE_REMOTE_DS: Successfully fetched profile');
        return ProfileModel.fromJson(profileData);
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to get profile - Status: ${response.statusCode}');
        throw Exception('Failed to get profile');
      }
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Dio error getting profile: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error getting profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    dev.log('🔵 PROFILE_REMOTE_DS: Updating profile with data: $profileData');

    try {
      final response =
          await dioClient.put(ApiConstants.updateProfile, data: profileData);

      dev.log(
          '🔵 PROFILE_REMOTE_DS: Update response status: ${response.statusCode}');
      dev.log('🔵 PROFILE_REMOTE_DS: Update response data: ${response.data}');

      if (response.statusCode == 200) {
        dev.log('🟢 PROFILE_REMOTE_DS: Profile updated successfully');
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to update profile - Status: ${response.statusCode}');
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Dio error updating profile: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleTwoFactor(bool enabled) async {
    dev.log('🔵 PROFILE_REMOTE_DS: Toggling two-factor to: $enabled');

    try {
      final response =
          await dioClient.post('${ApiConstants.userProfile}/otp/status', data: {
        'status': enabled,
      });

      dev.log(
          '🔵 PROFILE_REMOTE_DS: Toggle 2FA response status: ${response.statusCode}');
      dev.log('🔵 PROFILE_REMOTE_DS: Toggle 2FA response data: ${response.data}');

      if (response.statusCode == 200) {
        dev.log('🟢 PROFILE_REMOTE_DS: Two-factor toggled successfully');
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to toggle two-factor - Status: ${response.statusCode}');
        throw Exception('Failed to toggle two-factor authentication');
      }
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Dio error toggling 2FA: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error toggling 2FA: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> generateTwoFactorSecret({
    required String type,
    String? phoneNumber,
  }) async {
    dev.log('🔵 PROFILE_REMOTE_DS: Generating 2FA secret for type: $type');

    try {
      final Map<String, dynamic> requestData = {'type': type};
      if (phoneNumber != null) {
        requestData['phoneNumber'] = phoneNumber;
      }

      final response = await dioClient.post(
        '${ApiConstants.userProfile}/otp/secret',
        data: requestData,
      );

      dev.log(
          '🔵 PROFILE_REMOTE_DS: Generate secret response status: ${response.statusCode}');
      dev.log(
          '🔵 PROFILE_REMOTE_DS: Generate secret response data: ${response.data}');

      if (response.statusCode == 200) {
        dev.log('🟢 PROFILE_REMOTE_DS: Two-factor secret generated successfully');
        return response.data;
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to generate 2FA secret - Status: ${response.statusCode}');
        throw Exception('Failed to generate two-factor secret');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 PROFILE_REMOTE_DS: Dio error generating 2FA secret: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error generating 2FA secret: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyTwoFactorSetup({
    required String secret,
    required String code,
    required String type,
  }) async {
    dev.log('🔵 PROFILE_REMOTE_DS: Verifying 2FA setup with code: $code');

    try {
      final response =
          await dioClient.post('${ApiConstants.userProfile}/otp/verify', data: {
        'secret': secret,
        'otp': code,
        'type': type,
      });

      dev.log(
          '🔵 PROFILE_REMOTE_DS: Verify 2FA response status: ${response.statusCode}');
      dev.log('🔵 PROFILE_REMOTE_DS: Verify 2FA response data: ${response.data}');

      if (response.statusCode == 200) {
        dev.log('🟢 PROFILE_REMOTE_DS: Two-factor setup verified successfully');
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to verify 2FA setup - Status: ${response.statusCode}');
        throw Exception('Failed to verify two-factor setup');
      }
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Dio error verifying 2FA: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error verifying 2FA: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> saveTwoFactorSetup({
    required String secret,
    required String type,
  }) async {
    dev.log('🔵 PROFILE_REMOTE_DS: Saving 2FA setup');

    try {
      final response =
          await dioClient.post('${ApiConstants.userProfile}/otp', data: {
        'secret': secret,
        'type': type,
      });

      dev.log(
          '🔵 PROFILE_REMOTE_DS: Save 2FA response status: ${response.statusCode}');
      dev.log('🔵 PROFILE_REMOTE_DS: Save 2FA response data: ${response.data}');

      if (response.statusCode == 200) {
        dev.log('🟢 PROFILE_REMOTE_DS: Two-factor setup saved successfully');
        return response.data;
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to save 2FA setup - Status: ${response.statusCode}');
        throw Exception('Failed to save two-factor setup');
      }
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Dio error saving 2FA setup: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error saving 2FA setup: $e');
      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    dev.log('🔵 PROFILE_REMOTE_DS: Changing password');

    try {
      final response = await dioClient.post(
        '${ApiConstants.userProfile}/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      dev.log(
          '🔵 PROFILE_REMOTE_DS: Change password response status: ${response.statusCode}');
      dev.log(
          '🔵 PROFILE_REMOTE_DS: Change password response data: ${response.data}');

      if (response.statusCode == 200) {
        dev.log('�� PROFILE_REMOTE_DS: Password changed successfully');
      } else {
        dev.log(
            '🔴 PROFILE_REMOTE_DS: Failed to change password - Status: ${response.statusCode}');
        throw Exception('Failed to change password');
      }
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Dio error changing password: ${e.message}');
      dev.log('🔴 PROFILE_REMOTE_DS: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      dev.log('🔴 PROFILE_REMOTE_DS: Unexpected error changing password: $e');
      rethrow;
    }
  }
}
