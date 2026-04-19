import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_loading_overlay.dart';

class TwoFactorVerificationPage extends StatefulWidget {
  final String userId;
  final String twoFactorType;

  const TwoFactorVerificationPage({
    super.key,
    required this.userId,
    required this.twoFactorType,
  });

  @override
  State<TwoFactorVerificationPage> createState() =>
      _TwoFactorVerificationPageState();
}

class _TwoFactorVerificationPageState
    extends State<TwoFactorVerificationPage> {
  final GlobalKey<State<OtpInputField>> _otpKey = GlobalKey();
  String _otpValue = '';
  String? _errorText;
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _errorText = state.message;
            });
            HapticFeedback.mediumImpact();
          } else if (state is AuthAuthenticated) {
            // Successfully verified 2FA, pop back to previous screen
            // The main app will handle the authenticated state
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return PremiumLoadingOverlay(
            isLoading: state is AuthLoading,
            loadingText: 'Verifying code...',
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildVerificationForm(),
                    const SizedBox(height: 20),
                    _buildResendSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Simplified icon - no glow effect
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.15),
                context.colors.primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user,
            size: 28,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Verification Required',
          style: context.textTheme.headlineMedium?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getInstructionText(),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
            letterSpacing: 0.1,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getInstructionText() {
    switch (widget.twoFactorType.toUpperCase()) {
      case 'SMS':
        return 'Enter the 6-digit code sent to your phone';
      case 'EMAIL':
        return 'Enter the 6-digit code sent to your email';
      case 'APP':
        return 'Enter the code from your authenticator app';
      default:
        return 'Enter the 6-digit verification code';
    }
  }

  Widget _buildVerificationForm() {
    return Column(
      children: [
        OtpInputField(
          key: _otpKey,
          onCompleted: _handleOtpCompleted,
          onChanged: (value) {
            setState(() {
              _otpValue = value;
              _errorText = null; // Clear error on change
            });
          },
          errorText: _errorText,
        ),
        const SizedBox(height: 24),
        PremiumButton.gradient(
          text: 'Verify Code',
          onPressed: _otpValue.length == 6 ? _handleVerify : null,
          gradientColors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.8),
          ],
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    // Don't show resend for APP type (authenticator app)
    if (widget.twoFactorType.toUpperCase() == 'APP') {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code? ',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: _isResending ? null : _handleResendCode,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isResending ? 'Sending...' : 'Resend',
            style: TextStyle(
              color: _isResending
                  ? context.textSecondary
                  : context.colors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleOtpCompleted(String otp) {
    // Auto-submit when OTP is complete
    _handleVerify();
  }

  void _handleVerify() {
    if (_otpValue.length != 6) {
      setState(() {
        _errorText = 'Please enter a complete 6-digit code';
      });
      return;
    }

    HapticFeedback.lightImpact();

    // Dispatch verification event to BLoC
    context.read<AuthBloc>().add(
          AuthTwoFactorVerifyRequested(
            userId: widget.userId,
            otp: _otpValue,
          ),
        );
  }

  void _handleResendCode() async {
    setState(() {
      _isResending = true;
      _errorText = null;
    });

    HapticFeedback.lightImpact();

    try {
      final authDataSource = getIt<AuthRemoteDataSource>();
      await authDataSource.resendTwoFactorCode(
        userId: widget.userId,
        type: widget.twoFactorType,
      );

      if (mounted) {
        setState(() {
          _isResending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Code sent successfully',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: context.colors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
          _errorText = 'Failed to resend code. Please try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to resend code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
