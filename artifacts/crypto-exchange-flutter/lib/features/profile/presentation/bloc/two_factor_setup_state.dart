part of 'two_factor_setup_bloc.dart';

abstract class TwoFactorSetupState extends Equatable {
  const TwoFactorSetupState();

  @override
  List<Object?> get props => [];
}

class TwoFactorSetupInitial extends TwoFactorSetupState {
  const TwoFactorSetupInitial();
}

class TwoFactorMethodSelectedState extends TwoFactorSetupState {
  final String method;
  final String? phoneNumber;

  const TwoFactorMethodSelectedState({
    required this.method,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [method, phoneNumber];
}

class TwoFactorSecretGenerating extends TwoFactorSetupState {
  const TwoFactorSecretGenerating();
}

class TwoFactorSecretGenerated extends TwoFactorSetupState {
  final String method;
  final String secret;
  final String? qrCode;
  final String? phoneNumber;

  const TwoFactorSecretGenerated({
    required this.method,
    required this.secret,
    this.qrCode,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [method, secret, qrCode, phoneNumber];
}

class TwoFactorCodeVerifying extends TwoFactorSetupState {
  const TwoFactorCodeVerifying();
}

class TwoFactorCodeVerified extends TwoFactorSetupState {
  final String method;
  final String secret;

  const TwoFactorCodeVerified({
    required this.method,
    required this.secret,
  });

  @override
  List<Object?> get props => [method, secret];
}

class TwoFactorSetupSaving extends TwoFactorSetupState {
  const TwoFactorSetupSaving();
}

class TwoFactorSetupCompleted extends TwoFactorSetupState {
  final String method;
  final List<String> recoveryCodes;

  const TwoFactorSetupCompleted({
    required this.method,
    required this.recoveryCodes,
  });

  @override
  List<Object?> get props => [method, recoveryCodes];
}

class TwoFactorSetupError extends TwoFactorSetupState {
  final String message;

  const TwoFactorSetupError(this.message);

  @override
  List<Object?> get props => [message];
}
