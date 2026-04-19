import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../legal/domain/entities/legal_page_entity.dart';
import '../../../legal/presentation/pages/legal_page.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/premium_text_field.dart';
import '../widgets/premium_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _referralCodeFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _referralCodeFocus.dispose();

    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          dev.log('🔵 REGISTER_PAGE: State transition - Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
          // Only listen if the state actually changed (not just rebuilt)
          if (current is AuthError && previous is AuthError) {
            return current.message != previous.message;
          }
          if (current is AuthAuthenticated && previous is AuthAuthenticated) {
            return false; // Don't listen if already authenticated
          }
          return current is AuthError || current is AuthAuthenticated;
        },
        listener: (context, state) {
          if (state is AuthError) {
            dev.log('🔴 REGISTER_PAGE: Error state: ${state.message}');

            // Check if this is an email verification message (success case, not error)
            final message = state.message.toLowerCase();
            final isVerificationMessage = message.contains('verify') ||
                                         message.contains('verification') ||
                                         message.contains('check your email');

            if (isVerificationMessage) {
              dev.log('🟢 REGISTER_PAGE: Email verification required');
              _showSuccessSnackBar(context, state.message);
              // Navigate back to login after showing success message
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) Navigator.pop(context);
              });
            } else {
              dev.log('🔴 REGISTER_PAGE: Showing error: ${state.message}');
              _showErrorSnackBar(context, state.message);
            }
          } else if (state is AuthAuthenticated) {
            dev.log('🟢 REGISTER_PAGE: Registration successful, user authenticated');
            _showSuccessSnackBar(context, 'Registration successful! Welcome!');
            // Pop the register page so the main app's AuthWrapper can show home
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && Navigator.canPop(context)) {
                dev.log('🟢 REGISTER_PAGE: Popping register page');
                Navigator.pop(context);
              }
            });
          }
        },
        buildWhen: (previous, current) {
          dev.log('🔵 REGISTER_PAGE: buildWhen - Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
          return true;
        },
        builder: (context, state) {
          dev.log('🔵 REGISTER_PAGE: Rebuilding UI with state: ${state.runtimeType}');

          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints:
                    BoxConstraints(minHeight: context.screenHeight * 0.9),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildRegistrationForm(isLoading),
                      const SizedBox(height: 20),
                      _buildSocialLogin(isLoading),
                      const SizedBox(height: 20),
                      _buildBottomSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              const AppLogo.textOnly(
                fontSize: 24,
                style: LogoStyle.elegant,
              ),
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join ${AppConstants.appName} to start trading',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegistrationForm(bool isLoading) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          PremiumTextField(
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            labelText: 'First Name',
            hintText: 'Enter first name',
            prefixIcon: Icons.person_outline,
            enabled: !isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'First name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PremiumTextField(
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            labelText: 'Last Name',
            hintText: 'Enter last name',
            prefixIcon: Icons.person_outline,
            enabled: !isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Last name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PremiumTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            enabled: !isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PremiumTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            labelText: 'Password',
            hintText: 'Create a strong password',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            enabled: !isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.textSecondary,
                size: 20,
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() => _obscurePassword = !_obscurePassword);
                      HapticFeedback.lightImpact();
                    },
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Password is required';
              }
              // Match V5 backend validation requirements
              if (value!.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Password must contain an uppercase letter';
              }
              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return 'Password must contain a lowercase letter';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Password must contain a number';
              }
              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return 'Password must contain a special character';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PremiumTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            obscureText: _obscureConfirmPassword,
            prefixIcon: Icons.lock_outline,
            enabled: !isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.textSecondary,
                size: 20,
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword);
                      HapticFeedback.lightImpact();
                    },
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PremiumTextField(
            controller: _referralCodeController,
            focusNode: _referralCodeFocus,
            labelText: 'Referral Code (Optional)',
            hintText: 'Enter referral code',
            prefixIcon: Icons.card_giftcard_outlined,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          PremiumButton.gradient(
            text: 'Create Account',
            onPressed: isLoading ? null : _handleRegister,
            isLoading: isLoading,
            gradientColors: [
              context.colors.primary,
              context.colors.primary.withValues(alpha: 0.8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin(bool isLoading) {
    final config = AppConfig.instance;
    final showGoogleAuth = config.googleAuthEnabled;

    // Don't show section if Google auth is not enabled
    if (!showGoogleAuth) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: context.borderColor.withValues(alpha: 0.4),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: context.borderColor.withValues(alpha: 0.4),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PremiumButton.outline(
          text: 'Continue with Google',
          onPressed: isLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
                },
          icon: SvgPicture.network(
            'https://www.vectorlogo.zone/logos/google/google-icon.svg',
            height: 18,
            width: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: context.textSecondary.withValues(alpha: 0.6),
                fontSize: 11,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: 'By creating an account, you agree to our '),
                TextSpan(
                  text: 'Terms',
                  style: TextStyle(
                    color: context.colors.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LegalPage(
                            pageType: LegalPageType.terms,
                          ),
                        ),
                      );
                    },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: context.colors.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LegalPage(
                            pageType: LegalPageType.privacy,
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    dev.log('🔵 REGISTER_PAGE: Create Account button pressed');

    // Unfocus any text fields to dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    final isValid = _formKey.currentState?.validate() ?? false;
    dev.log('🔵 REGISTER_PAGE: Form validation result: $isValid');

    if (!isValid) {
      dev.log('🔴 REGISTER_PAGE: Form validation failed');
      HapticFeedback.mediumImpact();
      return;
    }

    // Trigger haptic feedback
    HapticFeedback.lightImpact();

    final email = _emailController.text.trim();

    dev.log('🔵 REGISTER_PAGE: Dispatching registration event for email: $email');

    if (mounted) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: email,
              password: _passwordController.text.trim(),
              referralCode: _referralCodeController.text.trim().isNotEmpty
                  ? _referralCodeController.text.trim()
                  : null,
              recaptchaToken: null,
            ),
          );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
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
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
    HapticFeedback.mediumImpact();
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
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
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
    HapticFeedback.lightImpact();
  }
}
