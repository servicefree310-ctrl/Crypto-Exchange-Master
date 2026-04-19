import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/kyc_level_entity.dart';
import '../entities/kyc_application_entity.dart';

abstract class KycRepository {
  /// Get all available KYC levels
  Future<Either<Failure, List<KycLevelEntity>>> getKycLevels();

  /// Get specific KYC level by ID
  Future<Either<Failure, KycLevelEntity>> getKycLevelById(String levelId);

  /// Get current user's KYC applications
  Future<Either<Failure, List<KycApplicationEntity>>> getKycApplications();

  /// Get specific KYC application by ID
  Future<Either<Failure, KycApplicationEntity>> getKycApplicationById(
      String applicationId);

  /// Submit new KYC application
  Future<Either<Failure, KycApplicationEntity>> submitKycApplication({
    required String levelId,
    required Map<String, dynamic> fields,
  });

  /// Update existing KYC application
  Future<Either<Failure, KycApplicationEntity>> updateKycApplication({
    required String applicationId,
    required Map<String, dynamic> fields,
  });

  /// Upload document for KYC (base64 JSON upload)
  Future<Either<Failure, String>> uploadKycDocument({
    required String filePath,
    String? oldPath,
  });
}
