part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthTwoFactorRequired extends AuthState {
  final String userId;
  final String twoFactorType;

  const AuthTwoFactorRequired({
    required this.userId,
    required this.twoFactorType,
  });

  @override
  List<Object> get props => [userId, twoFactorType];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthForgotPasswordSent extends AuthState {
  final String email;

  const AuthForgotPasswordSent({required this.email});

  @override
  List<Object> get props => [email];
} 