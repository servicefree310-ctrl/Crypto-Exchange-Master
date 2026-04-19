import 'dart:developer' as dev;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_cached_user_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/verify_two_factor_login_usecase.dart';
import '../../../profile/data/services/profile_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyTwoFactorLoginUseCase verifyTwoFactorLoginUseCase;
  final ProfileService profileService;
  GoogleSignIn? _googleSignIn;

  AuthBloc({
    required this.loginUseCase,
    required this.loginWithGoogleUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCachedUserUseCase,
    required this.checkAuthStatusUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyTwoFactorLoginUseCase,
    required this.profileService,
  }) : super(AuthInitial()) {
    // Initialize GoogleSignIn with server client ID from config.
    // Skip on web: google_sign_in_web v6 loads GIS via TrustedTypes and uses
    // its own initialization stream that fires unhandled "Bad state" /
    // "Null check operator" errors during DI on web (and signIn() requires
    // the renderButton widget anyway, not the imperative call below).
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn(
        serverClientId: AppConfig.instance.googleServerClientId.isNotEmpty
            ? AppConfig.instance.googleServerClientId
            : null,
      );
    }

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthTwoFactorRequested>(_onAuthTwoFactorRequested);
    on<AuthTwoFactorVerifyRequested>(_onAuthTwoFactorVerifyRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthErrorCleared>(_onAuthErrorCleared);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    dev.log('🔵 AUTH_BLOC: AuthCheckRequested event received');
    emit(AuthLoading());

    dev.log('🔵 AUTH_BLOC: Calling checkAuthStatusUseCase');
    final result = await checkAuthStatusUseCase(NoParams());

    await result.fold(
      (failure) async {
        dev.log('🔴 AUTH_BLOC: Auth check failed: ${failure.message}');
        emit(AuthUnauthenticated());
      },
      (isAuthenticated) async {
        dev.log('🔵 AUTH_BLOC: Auth check result: $isAuthenticated');
        if (isAuthenticated) {
          dev.log('🔵 AUTH_BLOC: User is authenticated, getting cached user');
          final userResult = await getCachedUserUseCase(NoParams());

          await userResult.fold(
            (failure) async {
              dev.log(
                  '🔴 AUTH_BLOC: Failed to get cached user: ${failure.message}');
              emit(AuthUnauthenticated());
            },
            (user) async {
              if (user != null) {
                dev.log('🟢 AUTH_BLOC: Cached user found: ${user.email}');
                emit(AuthAuthenticated(user: user));
              } else {
                dev.log('🔴 AUTH_BLOC: No cached user found');
                emit(AuthUnauthenticated());
              }
            },
          );
        } else {
          dev.log('🔵 AUTH_BLOC: User is not authenticated');
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    dev.log(
        '🔵 AUTH_BLOC: AuthLoginRequested event received for email: ${event.email}');
    emit(AuthLoading());

    dev.log('🔵 AUTH_BLOC: Calling loginUseCase');
    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 AUTH_BLOC: Login failed with failure: ${failure.runtimeType} - ${failure.message}');

        // Check if 2FA is required (matches V5 behavior)
        if (failure is TwoFactorRequiredFailure) {
          dev.log('🟡 AUTH_BLOC: 2FA verification required - userId: ${failure.userId}, type: ${failure.twoFactorType}');
          emit(AuthTwoFactorRequired(
            userId: failure.userId,
            twoFactorType: failure.twoFactorType,
          ));
        } else {
          final errorMessage = _mapFailureToMessage(failure);
          dev.log('🔴 AUTH_BLOC: Emitting AuthError with message: $errorMessage');
          emit(AuthError(message: errorMessage));
        }
      },
      (user) {
        dev.log('🟢 AUTH_BLOC: Login successful for user: ${user.email}');
        emit(AuthAuthenticated(user: user));

        // Auto-fetch complete profile including author status
        dev.log('🔵 AUTH_BLOC: Auto-fetching complete profile after login');
        profileService.autoFetchProfile();
      },
    );
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (_googleSignIn == null) {
        emit(const AuthError(message: 'Google sign-in is not available on this platform.'));
        return;
      }
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        // User cancelled the login
        emit(AuthUnauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        emit(const AuthError(message: 'Failed to get Google ID token.'));
        return;
      }

      final result =
          await loginWithGoogleUseCase(GoogleLoginParams(idToken: idToken));

      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    } catch (error) {
      await _googleSignIn?.signOut();
      emit(AuthError(message: error.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    dev.log(
        '🔵 AUTH_BLOC: AuthRegisterRequested event received for email: ${event.email}');
    dev.log(
        '🔵 AUTH_BLOC: Registration details: ${event.firstName} ${event.lastName}, hasRecaptcha: ${event.recaptchaToken != null}');
    emit(AuthLoading());

    dev.log('🔵 AUTH_BLOC: Calling registerUseCase');
    final result = await registerUseCase(
      RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        referralCode: event.referralCode,
        recaptchaToken: event.recaptchaToken,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 AUTH_BLOC: Registration failed with failure: ${failure.runtimeType} - ${failure.message}');
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('🔴 AUTH_BLOC: Emitting AuthError with message: $errorMessage');
        emit(AuthError(message: errorMessage));
      },
      (user) {
        dev.log('🟢 AUTH_BLOC: Registration successful for user: ${user.email}');
        emit(AuthAuthenticated(user: user));

        // Auto-fetch complete profile including author status
        dev.log(
            '🔵 AUTH_BLOC: Auto-fetching complete profile after registration');
        profileService.autoFetchProfile();
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    dev.log('🔵 AUTH_BLOC: AuthLogoutRequested event received');

    try {
      dev.log('🔵 AUTH_BLOC: Starting logout process');

      // Call logout use case (this handles API call and local cleanup)
      // Do NOT emit loading state - just do the logout silently
      final result = await logoutUseCase(NoParams());

      result.fold(
        (failure) {
          dev.log('🔴 AUTH_BLOC: Logout API failed: ${failure.message}');
          // Even if API call fails, we should still clear local data for security
          dev.log('🟢 AUTH_BLOC: Local cleanup completed despite API failure');
        },
        (_) {
          dev.log('🟢 AUTH_BLOC: Logout completed successfully');
        },
      );
    } catch (e) {
      dev.log('🔴 AUTH_BLOC: Unexpected error during logout: $e');
      // Continue to logout even on error for security
    } finally {
      // ALWAYS emit AuthUnauthenticated in finally block to guarantee it executes
      dev.log('🔵 AUTH_BLOC: Emitting AuthUnauthenticated (guaranteed in finally)');
      emit(AuthUnauthenticated());
      dev.log('✅ AUTH_BLOC: AuthUnauthenticated emitted successfully');
    }

    dev.log('🟢 AUTH_BLOC: Logout process completed');
  }

  Future<void> _onAuthTwoFactorRequested(
    AuthTwoFactorRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // This handler is deprecated - use AuthTwoFactorVerifyRequested instead
    emit(const AuthError(message: '2FA verification not implemented yet'));
  }

  Future<void> _onAuthTwoFactorVerifyRequested(
    AuthTwoFactorVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    dev.log(
        '🔵 AUTH_BLOC: AuthTwoFactorVerifyRequested event received for user: ${event.userId}');
    emit(AuthLoading());

    dev.log('🔵 AUTH_BLOC: Calling verifyTwoFactorLoginUseCase');
    final result = await verifyTwoFactorLoginUseCase(
      VerifyTwoFactorLoginParams(
        userId: event.userId,
        otp: event.otp,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 AUTH_BLOC: 2FA verification failed: ${failure.runtimeType} - ${failure.message}');
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('🔴 AUTH_BLOC: Emitting AuthError with message: $errorMessage');
        emit(AuthError(message: errorMessage));
      },
      (user) {
        dev.log(
            '🟢 AUTH_BLOC: 2FA verification successful for user: ${user.email}');
        emit(AuthAuthenticated(user: user));

        // Auto-fetch complete profile including author status
        dev.log('🔵 AUTH_BLOC: Auto-fetching complete profile after 2FA');
        profileService.autoFetchProfile();
      },
    );
  }

  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(user: event.user));
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    dev.log(
        '🔵 AUTH_BLOC: AuthForgotPasswordRequested event received for email: ${event.email}');
    emit(AuthLoading());

    dev.log('🔵 AUTH_BLOC: Calling forgotPasswordUseCase');
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 AUTH_BLOC: Forgot password failed with failure: ${failure.runtimeType} - ${failure.message}');
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('🔴 AUTH_BLOC: Emitting AuthError with message: $errorMessage');
        emit(AuthError(message: errorMessage));
      },
      (_) {
        dev.log(
            '🟢 AUTH_BLOC: Forgot password email sent successfully for: ${event.email}');
        emit(AuthForgotPasswordSent(email: event.email));
      },
    );
  }

  Future<void> _onAuthErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) async {
    dev.log('🔵 AUTH_BLOC: AuthErrorCleared event received');
    emit(AuthUnauthenticated());
    dev.log('🟢 AUTH_BLOC: Error cleared, emitted AuthUnauthenticated');
  }

  String _mapFailureToMessage(Failure failure) {
    // ALWAYS prioritize the API error message if available (matches V5 behavior)
    if (failure.message.isNotEmpty) {
      dev.log('🔵 AUTH_BLOC: Using API error message: ${failure.message}');
      return failure.message;
    }

    // Only use generic fallback messages if API didn't provide one
    dev.log('🔵 AUTH_BLOC: No API message, using fallback for: ${failure.runtimeType}');
    switch (failure) {
      case NetworkFailure():
        return 'Network error. Please check your internet connection.';
      case ServerFailure():
        return 'Server error occurred.';
      case AuthFailure():
        return 'Authentication failed.';
      case ValidationFailure():
        return 'Invalid input provided.';
      case UnauthorizedFailure():
        return 'Unauthorized access. Please login again.';
      case ForbiddenFailure():
        return 'Access denied.';
      case NotFoundFailure():
        return 'Resource not found.';
      case CacheFailure():
        return 'Local storage error occurred.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
