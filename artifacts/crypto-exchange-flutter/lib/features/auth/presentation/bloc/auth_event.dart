part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();

  @override
  List<Object> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? referralCode;
  final String? recaptchaToken;

  const AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.referralCode,
    this.recaptchaToken,
  });

  @override
  List<Object?> get props =>
      [firstName, lastName, email, password, referralCode, recaptchaToken];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthTwoFactorRequested extends AuthEvent {
  final String userId;
  final String code;

  const AuthTwoFactorRequested({
    required this.userId,
    required this.code,
  });

  @override
  List<Object> get props => [userId, code];
}

class AuthTwoFactorVerifyRequested extends AuthEvent {
  final String userId;
  final String otp;

  const AuthTwoFactorVerifyRequested({
    required this.userId,
    required this.otp,
  });

  @override
  List<Object> get props => [userId, otp];
}

class AuthUserUpdated extends AuthEvent {
  final UserEntity user;

  const AuthUserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();

  @override
  List<Object> get props => [];
}
