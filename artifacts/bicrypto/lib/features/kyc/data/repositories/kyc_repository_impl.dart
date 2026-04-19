import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/kyc_level_entity.dart';
import '../../domain/entities/kyc_application_entity.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_datasource.dart';

@Injectable(as: KycRepository)
class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource _remoteDataSource;

  KycRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<KycLevelEntity>>> getKycLevels() async {
    dev.log('🔵 KYC_REPO: Getting KYC levels');

    try {
      final levels = await _remoteDataSource.getKycLevels();
      dev.log('🟢 KYC_REPO: Successfully got ${levels.length} KYC levels');
      return Right(levels);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error getting KYC levels: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycLevelEntity>> getKycLevelById(
      String levelId) async {
    dev.log('🔵 KYC_REPO: Getting KYC level by ID: $levelId');

    try {
      final level = await _remoteDataSource.getKycLevelById(levelId);
      dev.log('🟢 KYC_REPO: Successfully got KYC level');
      return Right(level);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error getting KYC level: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KycApplicationEntity>>>
      getKycApplications() async {
    dev.log('🔵 KYC_REPO: Getting KYC applications');

    try {
      final applications = await _remoteDataSource.getKycApplications();
      dev.log(
          '🟢 KYC_REPO: Successfully got ${applications.length} KYC applications');
      return Right(applications);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error getting KYC applications: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycApplicationEntity>> getKycApplicationById(
      String applicationId) async {
    dev.log('🔵 KYC_REPO: Getting KYC application by ID: $applicationId');

    try {
      final application =
          await _remoteDataSource.getKycApplicationById(applicationId);
      dev.log('🟢 KYC_REPO: Successfully got KYC application');
      return Right(application);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error getting KYC application: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycApplicationEntity>> submitKycApplication({
    required String levelId,
    required Map<String, dynamic> fields,
  }) async {
    dev.log('🔵 KYC_REPO: Submitting KYC application for level: $levelId');

    try {
      final application = await _remoteDataSource.submitKycApplication(
        levelId: levelId,
        fields: fields,
      );
      dev.log('🟢 KYC_REPO: Successfully submitted KYC application');
      return Right(application);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error submitting KYC application: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycApplicationEntity>> updateKycApplication({
    required String applicationId,
    required Map<String, dynamic> fields,
  }) async {
    dev.log('🔵 KYC_REPO: Updating KYC application: $applicationId');

    try {
      final application = await _remoteDataSource.updateKycApplication(
        applicationId: applicationId,
        fields: fields,
      );
      dev.log('🟢 KYC_REPO: Successfully updated KYC application');
      return Right(application);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error updating KYC application: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadKycDocument({
    required String filePath,
    String? oldPath,
  }) async {
    dev.log('🔵 KYC_REPO: Uploading KYC document');

    try {
      final fileUrl = await _remoteDataSource.uploadKycDocument(
        filePath: filePath,
        oldPath: oldPath,
      );
      dev.log('🟢 KYC_REPO: Successfully uploaded KYC document');
      return Right(fileUrl);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      dev.log('🔴 KYC_REPO: Unexpected error uploading KYC document: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
