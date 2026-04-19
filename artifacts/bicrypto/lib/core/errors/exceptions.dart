/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Unauthorized access exception
class UnauthorizedException extends AuthException {
  const UnauthorizedException(super.message, [super.code]);
}

/// Two-factor authentication required exception
class TwoFactorRequiredException extends AuthException {
  final String userId;
  final String twoFactorType;

  const TwoFactorRequiredException({
    required this.userId,
    required this.twoFactorType,
  }) : super('Two-factor authentication required', '2FA_REQUIRED');
}

/// Forbidden access exception
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, [super.code]);
}

/// Bad request exception
class BadRequestException extends AppException {
  const BadRequestException(super.message, [super.code]);
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}

/// Validation exception with field errors
class ValidationException extends AppException {
  final Map<String, dynamic>? fieldErrors;

  const ValidationException(
    super.message, [
    this.fieldErrors,
    super.code,
  ]);
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Format related exceptions
class FormatException extends AppException {
  const FormatException(super.message, [super.code]);
}

/// Timeout exception
class TimeoutException extends NetworkException {
  const TimeoutException(super.message, [super.code]);
}

/// Connection exception
class ConnectionException extends NetworkException {
  const ConnectionException(super.message, [super.code]);
} 