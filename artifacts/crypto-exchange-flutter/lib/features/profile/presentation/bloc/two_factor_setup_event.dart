part of 'two_factor_setup_bloc.dart';

abstract class TwoFactorSetupEvent extends Equatable {
  const TwoFactorSetupEvent();

  @override
  List<Object?> get props => [];
}

class TwoFactorMethodSelected extends TwoFactorSetupEvent {
  final String method;
  final String? phoneNumber;

  const TwoFactorMethodSelected({
    required this.method,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [method, phoneNumber];
}

class TwoFactorSecretGenerateRequested extends TwoFactorSetupEvent {
  final String method;
  final String? phoneNumber;

  const TwoFactorSecretGenerateRequested({
    required this.method,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [method, phoneNumber];
}

class TwoFactorCodeVerifyRequested extends TwoFactorSetupEvent {
  final String method;
  final String secret;
  final String code;

  const TwoFactorCodeVerifyRequested({
    required this.method,
    required this.secret,
    required this.code,
  });

  @override
  List<Object?> get props => [method, secret, code];
}

class TwoFactorSetupSaveRequested extends TwoFactorSetupEvent {
  final String method;
  final String secret;

  const TwoFactorSetupSaveRequested({
    required this.method,
    required this.secret,
  });

  @override
  List<Object?> get props => [method, secret];
}

class TwoFactorSetupResetRequested extends TwoFactorSetupEvent {
  const TwoFactorSetupResetRequested();
}
