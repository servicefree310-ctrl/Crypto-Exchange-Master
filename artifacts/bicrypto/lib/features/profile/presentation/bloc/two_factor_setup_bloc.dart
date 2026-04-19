import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/generate_two_factor_secret_usecase.dart';
import '../../domain/usecases/verify_two_factor_setup_usecase.dart';
import '../../domain/usecases/save_two_factor_setup_usecase.dart';

part 'two_factor_setup_event.dart';
part 'two_factor_setup_state.dart';

@injectable
class TwoFactorSetupBloc
    extends Bloc<TwoFactorSetupEvent, TwoFactorSetupState> {
  final GenerateTwoFactorSecretUseCase _generateSecretUseCase;
  final VerifyTwoFactorSetupUseCase _verifySetupUseCase;
  final SaveTwoFactorSetupUseCase _saveSetupUseCase;

  TwoFactorSetupBloc({
    required GenerateTwoFactorSecretUseCase generateSecretUseCase,
    required VerifyTwoFactorSetupUseCase verifySetupUseCase,
    required SaveTwoFactorSetupUseCase saveSetupUseCase,
  })  : _generateSecretUseCase = generateSecretUseCase,
        _verifySetupUseCase = verifySetupUseCase,
        _saveSetupUseCase = saveSetupUseCase,
        super(TwoFactorSetupInitial()) {
    on<TwoFactorMethodSelected>(_onMethodSelected);
    on<TwoFactorSecretGenerateRequested>(_onGenerateSecret);
    on<TwoFactorCodeVerifyRequested>(_onVerifyCode);
    on<TwoFactorSetupSaveRequested>(_onSaveSetup);
    on<TwoFactorSetupResetRequested>(_onResetSetup);
  }

  void _onMethodSelected(
    TwoFactorMethodSelected event,
    Emitter<TwoFactorSetupState> emit,
  ) {
    emit(TwoFactorMethodSelectedState(
      method: event.method,
      phoneNumber: event.phoneNumber,
    ));
  }

  Future<void> _onGenerateSecret(
    TwoFactorSecretGenerateRequested event,
    Emitter<TwoFactorSetupState> emit,
  ) async {
    dev.log('🔵 TWO_FACTOR_BLOC: Generating secret for method: ${event.method}');

    emit(TwoFactorSecretGenerating());

    final result = await _generateSecretUseCase(
      GenerateTwoFactorSecretParams(
        type: event.method,
        phoneNumber: event.phoneNumber,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 TWO_FACTOR_BLOC: Failed to generate secret: ${failure.message}');
        emit(TwoFactorSetupError(failure.message));
      },
      (data) {
        dev.log('🟢 TWO_FACTOR_BLOC: Secret generated successfully');
        emit(TwoFactorSecretGenerated(
          method: event.method,
          secret: data['secret'] as String,
          qrCode: data['qrCode'] as String?,
          phoneNumber: event.phoneNumber,
        ));
      },
    );
  }

  Future<void> _onVerifyCode(
    TwoFactorCodeVerifyRequested event,
    Emitter<TwoFactorSetupState> emit,
  ) async {
    dev.log('🔵 TWO_FACTOR_BLOC: Verifying code: ${event.code}');

    emit(TwoFactorCodeVerifying());

    final result = await _verifySetupUseCase(
      VerifyTwoFactorSetupParams(
        secret: event.secret,
        code: event.code,
        type: event.method,
      ),
    );

    result.fold(
      (failure) {
        dev.log('🔴 TWO_FACTOR_BLOC: Failed to verify code: ${failure.message}');
        emit(TwoFactorSetupError(failure.message));
      },
      (_) {
        dev.log('🟢 TWO_FACTOR_BLOC: Code verified successfully');
        emit(TwoFactorCodeVerified(
          method: event.method,
          secret: event.secret,
        ));
      },
    );
  }

  Future<void> _onSaveSetup(
    TwoFactorSetupSaveRequested event,
    Emitter<TwoFactorSetupState> emit,
  ) async {
    dev.log('🔵 TWO_FACTOR_BLOC: Saving 2FA setup');

    emit(TwoFactorSetupSaving());

    final result = await _saveSetupUseCase(
      SaveTwoFactorSetupParams(
        secret: event.secret,
        type: event.method,
      ),
    );

    result.fold(
      (failure) {
        dev.log('🔴 TWO_FACTOR_BLOC: Failed to save setup: ${failure.message}');
        emit(TwoFactorSetupError(failure.message));
      },
      (data) {
        dev.log('🟢 TWO_FACTOR_BLOC: Setup saved successfully');
        emit(TwoFactorSetupCompleted(
          method: event.method,
          recoveryCodes: List<String>.from(data['recoveryCodes'] ?? []),
        ));
      },
    );
  }

  void _onResetSetup(
    TwoFactorSetupResetRequested event,
    Emitter<TwoFactorSetupState> emit,
  ) {
    dev.log('🔵 TWO_FACTOR_BLOC: Resetting setup');
    emit(TwoFactorSetupInitial());
  }
}
