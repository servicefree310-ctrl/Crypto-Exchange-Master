import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, void>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    ProfileInfoEntity? profile,
    NotificationSettingsEntity? settings,
  });
  Future<Either<Failure, void>> toggleTwoFactor(bool enabled);
  Future<Either<Failure, Map<String, dynamic>>> generateTwoFactorSecret({
    required String type,
    String? phoneNumber,
  });
  Future<Either<Failure, void>> verifyTwoFactorSetup({
    required String secret,
    required String code,
    required String type,
  });
  Future<Either<Failure, Map<String, dynamic>>> saveTwoFactorSetup({
    required String secret,
    required String type,
  });
}
