import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
    String? recaptchaToken,
  });

  /// Logout current user
  Future<Either<Failure, Unit>> logout();

  /// Get cached user data
  Future<Either<Failure, UserEntity?>> getCachedUser();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Verify two-factor authentication (for setup/profile)
  Future<Either<Failure, UserEntity>> verifyTwoFactor({
    required String userId,
    required String code,
  });

  /// Verify two-factor authentication during login
  Future<Either<Failure, UserEntity>> verifyTwoFactorLogin({
    required String userId,
    required String otp,
  });

  /// Refresh authentication token
  Future<Either<Failure, Unit>> refreshToken();

  /// Request password reset
  Future<Either<Failure, Unit>> requestPasswordReset({
    required String email,
  });

  /// Reset password with token
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Change password for authenticated user
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Verify email with token
  Future<Either<Failure, Unit>> verifyEmail({
    required String token,
  });

  /// Resend email verification
  Future<Either<Failure, Unit>> resendEmailVerification();

  /// Google sign in
  Future<Either<Failure, UserEntity>> googleSignIn({
    required String idToken,
  });

  /// Enable two-factor authentication
  Future<Either<Failure, Map<String, dynamic>>> enableTwoFactor({
    required String type,
  });

  /// Disable two-factor authentication
  Future<Either<Failure, Unit>> disableTwoFactor({
    required String code,
  });

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  });
} 