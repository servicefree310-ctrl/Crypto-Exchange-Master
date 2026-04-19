import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    dev.log('🔵 PROFILE_REPO: Getting profile');

    try {
      final profile = await remoteDataSource.getProfile();
      dev.log('🟢 PROFILE_REPO: Successfully got profile');
      return Right(profile);
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REPO: Dio error getting profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(UnauthorizedFailure('Authentication required'));
      } else if (e.response?.statusCode == 404) {
        return Left(NotFoundFailure('Profile not found'));
      } else {
        return Left(ServerFailure(e.message ?? 'Failed to get profile'));
      }
    } catch (e) {
      dev.log('🔴 PROFILE_REPO: Unexpected error getting profile: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    ProfileInfoEntity? profile,
    NotificationSettingsEntity? settings,
  }) async {
    dev.log('🔵 PROFILE_REPO: Updating profile');

    try {
      final Map<String, dynamic> profileData = {};

      if (firstName != null) profileData['firstName'] = firstName;
      if (lastName != null) profileData['lastName'] = lastName;
      if (phone != null) profileData['phone'] = phone;
      if (avatar != null) profileData['avatar'] = avatar;

      if (profile != null) {
        final Map<String, dynamic> profileInfo = {};
        if (profile.bio != null) profileInfo['bio'] = profile.bio;

        if (profile.location != null) {
          final Map<String, dynamic> location = {};
          if (profile.location!.address != null) {
            location['address'] = profile.location!.address;
          }
          if (profile.location!.city != null) {
            location['city'] = profile.location!.city;
          }
          if (profile.location!.country != null) {
            location['country'] = profile.location!.country;
          }
          if (profile.location!.zip != null) {
            location['zip'] = profile.location!.zip;
          }
          if (location.isNotEmpty) profileInfo['location'] = location;
        }

        if (profile.social != null) {
          final Map<String, dynamic> social = {};
          if (profile.social!.twitter != null) {
            social['twitter'] = profile.social!.twitter;
          }
          if (profile.social!.dribbble != null) {
            social['dribbble'] = profile.social!.dribbble;
          }
          if (profile.social!.instagram != null) {
            social['instagram'] = profile.social!.instagram;
          }
          if (profile.social!.github != null) {
            social['github'] = profile.social!.github;
          }
          if (profile.social!.gitlab != null) {
            social['gitlab'] = profile.social!.gitlab;
          }
          if (profile.social!.telegram != null) {
            social['telegram'] = profile.social!.telegram;
          }
          if (social.isNotEmpty) profileInfo['social'] = social;
        }

        if (profileInfo.isNotEmpty) profileData['profile'] = profileInfo;
      }

      if (settings != null) {
        final Map<String, dynamic> settingsData = {};
        if (settings.email != null) settingsData['email'] = settings.email;
        if (settings.sms != null) settingsData['sms'] = settings.sms;
        if (settings.push != null) settingsData['push'] = settings.push;
        if (settingsData.isNotEmpty) profileData['settings'] = settingsData;
      }

      await remoteDataSource.updateProfile(profileData);
      dev.log('🟢 PROFILE_REPO: Successfully updated profile');
      return const Right(null);
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REPO: Dio error updating profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(UnauthorizedFailure('Authentication required'));
      } else if (e.response?.statusCode == 400) {
        return Left(ValidationFailure(
            e.response?.data['message'] ?? 'Invalid profile data'));
      } else {
        return Left(ServerFailure(e.message ?? 'Failed to update profile'));
      }
    } catch (e) {
      dev.log('🔴 PROFILE_REPO: Unexpected error updating profile: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleTwoFactor(bool enabled) async {
    dev.log('🔵 PROFILE_REPO: Toggling two-factor to: $enabled');

    try {
      await remoteDataSource.toggleTwoFactor(enabled);
      dev.log('🟢 PROFILE_REPO: Successfully toggled two-factor');
      return const Right(null);
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REPO: Dio error toggling 2FA: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(UnauthorizedFailure('Authentication required'));
      } else {
        return Left(ServerFailure(
            e.message ?? 'Failed to toggle two-factor authentication'));
      }
    } catch (e) {
      dev.log('🔴 PROFILE_REPO: Unexpected error toggling 2FA: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateTwoFactorSecret({
    required String type,
    String? phoneNumber,
  }) async {
    dev.log('🔵 PROFILE_REPO: Generating 2FA secret for type: $type');

    try {
      final result = await remoteDataSource.generateTwoFactorSecret(
        type: type,
        phoneNumber: phoneNumber,
      );
      dev.log('🟢 PROFILE_REPO: Successfully generated 2FA secret');
      return Right(result);
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REPO: Dio error generating 2FA secret: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(UnauthorizedFailure('Authentication required'));
      } else {
        return Left(
            ServerFailure(e.message ?? 'Failed to generate two-factor secret'));
      }
    } catch (e) {
      dev.log('🔴 PROFILE_REPO: Unexpected error generating 2FA secret: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyTwoFactorSetup({
    required String secret,
    required String code,
    required String type,
  }) async {
    dev.log('🔵 PROFILE_REPO: Verifying 2FA setup');

    try {
      await remoteDataSource.verifyTwoFactorSetup(
        secret: secret,
        code: code,
        type: type,
      );
      dev.log('🟢 PROFILE_REPO: Successfully verified 2FA setup');
      return const Right(null);
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REPO: Dio error verifying 2FA: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(UnauthorizedFailure('Authentication required'));
      } else if (e.response?.statusCode == 400) {
        return Left(ValidationFailure('Invalid verification code'));
      } else {
        return Left(
            ServerFailure(e.message ?? 'Failed to verify two-factor setup'));
      }
    } catch (e) {
      dev.log('🔴 PROFILE_REPO: Unexpected error verifying 2FA: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveTwoFactorSetup({
    required String secret,
    required String type,
  }) async {
    dev.log('🔵 PROFILE_REPO: Saving 2FA setup');

    try {
      final result = await remoteDataSource.saveTwoFactorSetup(
        secret: secret,
        type: type,
      );
      dev.log('🟢 PROFILE_REPO: Successfully saved 2FA setup');
      return Right(result);
    } on DioException catch (e) {
      dev.log('🔴 PROFILE_REPO: Dio error saving 2FA setup: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Left(UnauthorizedFailure('Authentication required'));
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid 2FA data';
        return Left(ValidationFailure(message));
      } else {
        return Left(ServerFailure(e.message ?? 'Failed to save 2FA setup'));
      }
    } catch (e) {
      dev.log('🔴 PROFILE_REPO: Unexpected error saving 2FA setup: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
