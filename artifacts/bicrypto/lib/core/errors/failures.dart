import 'package:equatable/equatable.dart';

/// Base failure class for Clean Architecture
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, dynamic>? fieldErrors;

  const ValidationFailure(
    super.message, [
    this.fieldErrors,
    super.code,
  ]);

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Format failure
class FormatFailure extends Failure {
  const FormatFailure(super.message, [super.code]);
}

/// Unauthorized failure
class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure(super.message, [super.code]);
}

/// Forbidden failure
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, [super.code]);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.code]);
}

/// Timeout failure
class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure(super.message, [super.code]);
}

/// Connection failure
class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure(super.message, [super.code]);
}

/// Two-factor authentication required failure
class TwoFactorRequiredFailure extends AuthFailure {
  final String userId;
  final String twoFactorType;

  const TwoFactorRequiredFailure({
    required this.userId,
    required this.twoFactorType,
    String message = '2FA required',
    String? code,
  }) : super(message, code);

  @override
  List<Object?> get props => [message, code, userId, twoFactorType];
}

/// Unknown failure for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}
