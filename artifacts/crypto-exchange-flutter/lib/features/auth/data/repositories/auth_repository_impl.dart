import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    dev.log('🔵 AUTH_REPO: Starting login for email: $email');
    
    try {
      dev.log('🔵 AUTH_REPO: Calling remote data source login');
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      dev.log('🔵 AUTH_REPO: Login successful, saving tokens and caching user locally');
      
      // Save tokens to secure storage
      final accessToken = (remoteDataSource as AuthRemoteDataSourceImpl).lastAccessToken;
      final sessionId = (remoteDataSource as AuthRemoteDataSourceImpl).lastSessionId;
      final csrfToken = (remoteDataSource as AuthRemoteDataSourceImpl).lastCsrfToken;
      
      if (accessToken != null && accessToken.isNotEmpty) {
        dev.log('🔵 AUTH_REPO: Saving tokens to local storage');
        await localDataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: 'placeholder', // Not provided in this response
          sessionId: sessionId ?? '',
          csrfToken: csrfToken ?? '',
        );
        dev.log('🔵 AUTH_REPO: Tokens saved successfully');
      }
      
      // Cache user data locally
      await localDataSource.cacheUser(user);
      dev.log('🟢 AUTH_REPO: Login completed successfully');

      return Right(user);
    } on TwoFactorRequiredException catch (e) {
      dev.log('🟡 AUTH_REPO: 2FA verification required - userId: ${e.userId}, type: ${e.twoFactorType}');
      return Left(TwoFactorRequiredFailure(
        userId: e.userId,
        twoFactorType: e.twoFactorType,
        message: e.message,
        code: e.code,
      ));
    } on AuthException catch (e) {
      dev.log('🔴 AUTH_REPO: AuthException caught: ${e.message}');
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      dev.log('🔴 AUTH_REPO: ValidationException caught: ${e.message}');
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      dev.log('🔴 AUTH_REPO: UnauthorizedException caught: ${e.message}');
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      dev.log('🔴 AUTH_REPO: NetworkException caught: ${e.message}');
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      dev.log('🔴 AUTH_REPO: ServerException caught: ${e.message}');
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      dev.log('🔴 AUTH_REPO: Unexpected exception during login: $e');
      return Left(ServerFailure('Unexpected error during login'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
    String? recaptchaToken,
  }) async {
    dev.log('🔵 AUTH_REPO: Starting registration for email: $email');
    dev.log('🔵 AUTH_REPO: Registration details: firstName=$firstName, lastName=$lastName, hasRecaptcha=${recaptchaToken != null}');

    try {
      dev.log('🔵 AUTH_REPO: Calling remote data source register');
      final user = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        referralCode: referralCode,
        recaptchaToken: recaptchaToken,
      );

      dev.log('🔵 AUTH_REPO: Registration successful, saving tokens and caching user locally');

      // Save tokens to secure storage (same as login)
      final accessToken = (remoteDataSource as AuthRemoteDataSourceImpl).lastAccessToken;
      final sessionId = (remoteDataSource as AuthRemoteDataSourceImpl).lastSessionId;
      final csrfToken = (remoteDataSource as AuthRemoteDataSourceImpl).lastCsrfToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        dev.log('🔵 AUTH_REPO: Saving tokens to local storage');
        await localDataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: 'placeholder', // Not provided in this response
          sessionId: sessionId ?? '',
          csrfToken: csrfToken ?? '',
        );
        dev.log('🔵 AUTH_REPO: Tokens saved successfully');
      }

      // Cache user data locally
      await localDataSource.cacheUser(user);
      dev.log('🟢 AUTH_REPO: Registration completed successfully');

      return Right(user);
    } on AuthException catch (e) {
      dev.log('🔴 AUTH_REPO: Registration AuthException caught: ${e.message}');
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      dev.log('🔴 AUTH_REPO: Registration ValidationException caught: ${e.message}');
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on BadRequestException catch (e) {
      dev.log('🔴 AUTH_REPO: Registration BadRequestException caught: ${e.message}');
      return Left(ValidationFailure(e.message, null, e.code));
    } on NetworkException catch (e) {
      dev.log('🔴 AUTH_REPO: Registration NetworkException caught: ${e.message}');
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      dev.log('🔴 AUTH_REPO: Registration ServerException caught: ${e.message}');
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      dev.log('🔴 AUTH_REPO: Unexpected exception during registration: $e');
      return Left(ServerFailure('Unexpected error during registration'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      
      // Clear local data
      await Future.wait([
        localDataSource.clearUserData(),
        localDataSource.clearTokens(),
      ]);

      return const Right(unit);
    } on NetworkException catch (e) {
      // Even if network call fails, clear local data
      await Future.wait([
        localDataSource.clearUserData(),
        localDataSource.clearTokens(),
      ]);
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      // Even if server call fails, clear local data
      await Future.wait([
        localDataSource.clearUserData(),
        localDataSource.clearTokens(),
      ]);
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      // Always clear local data on logout attempt
      await Future.wait([
        localDataSource.clearUserData(),
        localDataSource.clearTokens(),
      ]);
      return Left(ServerFailure('Unexpected error during logout'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    dev.log('🔵 AUTH_REPO: Checking authentication status');
    
    try {
      dev.log('🔵 AUTH_REPO: Checking for valid tokens');
      final hasTokens = await localDataSource.hasValidTokens();
      
      dev.log('🔵 AUTH_REPO: Getting cached user');
      final user = await localDataSource.getCachedUser();
      
      final isAuth = hasTokens && user != null;
      dev.log('🔵 AUTH_REPO: Is authenticated: $isAuth (hasTokens: $hasTokens, hasUser: ${user != null})');
      
      return Right(isAuth);
    } on CacheException catch (e) {
      dev.log('🔴 AUTH_REPO: CacheException in isAuthenticated: ${e.message}');
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      dev.log('🔴 AUTH_REPO: Unexpected exception in isAuthenticated: $e');
      return Left(CacheFailure('Failed to check authentication status'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyTwoFactor({
    required String userId,
    required String code,
  }) async {
    try {
      final user = await remoteDataSource.verifyTwoFactor(
        userId: userId,
        code: code,
      );

      // Cache user data locally
      await localDataSource.cacheUser(user);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during 2FA verification'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyTwoFactorLogin({
    required String userId,
    required String otp,
  }) async {
    dev.log('🔵 AUTH_REPO: Starting 2FA login verification for user: $userId');

    try {
      dev.log('🔵 AUTH_REPO: Calling remote data source verifyTwoFactorLogin');
      final user = await remoteDataSource.verifyTwoFactorLogin(
        userId: userId,
        otp: otp,
      );

      dev.log('🔵 AUTH_REPO: 2FA verification successful, saving tokens and caching user locally');

      // Save tokens to secure storage
      final accessToken = (remoteDataSource as AuthRemoteDataSourceImpl).lastAccessToken;
      final sessionId = (remoteDataSource as AuthRemoteDataSourceImpl).lastSessionId;
      final csrfToken = (remoteDataSource as AuthRemoteDataSourceImpl).lastCsrfToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        dev.log('🔵 AUTH_REPO: Saving tokens to local storage');
        await localDataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: 'placeholder',
          sessionId: sessionId ?? '',
          csrfToken: csrfToken ?? '',
        );
        dev.log('🔵 AUTH_REPO: Tokens saved successfully');
      }

      // Cache user data locally
      await localDataSource.cacheUser(user);
      dev.log('🟢 AUTH_REPO: 2FA login verification completed successfully');

      return Right(user);
    } on AuthException catch (e) {
      dev.log('🔴 AUTH_REPO: AuthException caught during 2FA: ${e.message}');
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      dev.log('🔴 AUTH_REPO: ValidationException caught during 2FA: ${e.message}');
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      dev.log('🔴 AUTH_REPO: UnauthorizedException caught during 2FA: ${e.message}');
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      dev.log('🔴 AUTH_REPO: NetworkException caught during 2FA: ${e.message}');
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      dev.log('🔴 AUTH_REPO: ServerException caught during 2FA: ${e.message}');
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      dev.log('🔴 AUTH_REPO: Unexpected exception during 2FA verification: $e');
      return Left(ServerFailure('Unexpected error during 2FA verification'));
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshToken() async {
    try {
      await remoteDataSource.refreshToken();
      return const Right(unit);
    } on UnauthorizedException catch (e) {
      // Clear tokens if refresh fails
      await localDataSource.clearTokens();
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during token refresh'));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestPasswordReset({
    required String email,
  }) async {
    dev.log('🔵 AUTH_REPO: Starting password reset request for email: $email');
    
    try {
      dev.log('🔵 AUTH_REPO: Calling remote data source requestPasswordReset');
      await remoteDataSource.requestPasswordReset(email: email);
      dev.log('🟢 AUTH_REPO: Password reset request completed successfully');
      return const Right(unit);
    } on ValidationException catch (e) {
      dev.log('🔴 AUTH_REPO: Password reset ValidationException: ${e.message}');
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on NetworkException catch (e) {
      dev.log('🔴 AUTH_REPO: Password reset NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      dev.log('🔴 AUTH_REPO: Password reset ServerException: ${e.message}');
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      dev.log('🔴 AUTH_REPO: Unexpected exception during password reset request: $e');
      return Left(ServerFailure('Unexpected error during password reset request'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during password reset'));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during password change'));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyEmail({required String token}) async {
    try {
      await remoteDataSource.verifyEmail(token: token);
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during email verification'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendEmailVerification() async {
    try {
      await remoteDataSource.resendEmailVerification();
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during email verification resend'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleSignIn({
    required String idToken,
  }) async {
    try {
      final user = await remoteDataSource.googleSignIn(idToken: idToken);

      // Cache user data locally
      await localDataSource.cacheUser(user);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during Google sign in'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> enableTwoFactor({
    required String type,
  }) async {
    try {
      final result = await remoteDataSource.enableTwoFactor(type: type);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during 2FA enable'));
    }
  }

  @override
  Future<Either<Failure, Unit>> disableTwoFactor({required String code}) async {
    try {
      await remoteDataSource.disableTwoFactor(code: code);
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during 2FA disable'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatar: avatar,
      );

      // Update cached user data
      await localDataSource.cacheUser(user);

      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during profile update'));
    }
  }
} 