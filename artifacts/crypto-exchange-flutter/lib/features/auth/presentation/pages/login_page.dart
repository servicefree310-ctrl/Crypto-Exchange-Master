import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../legal/domain/entities/legal_page_entity.dart';
import '../../../legal/presentation/pages/legal_page.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/premium_text_field.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_loading_overlay.dart';
import '../pages/register_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/two_factor_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

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

    // Clear any error state when login page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final authBloc = context.read<AuthBloc>();
          final currentState = authBloc.state;
          dev.log('🔵 LOGIN_PAGE: initState - Current BLoC state: ${currentState.runtimeType}');

          // Clear any non-unauthenticated state (including Loading, Error, etc.)
          if (currentState is! AuthUnauthenticated && !authBloc.isClosed) {
            dev.log('🔵 LOGIN_PAGE: Clearing state to AuthUnauthenticated (current: ${currentState.runtimeType})');
            authBloc.add(const AuthErrorCleared());
          }
        } catch (e) {
          dev.log('🔴 LOGIN_PAGE: Error in postFrameCallback: $e');
          // Silently ignore if BLoC is not available
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('🔵 LOGIN_PAGE: Building with state: ${context.read<AuthBloc>().state.runtimeType}');

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          dev.log('🔵 LOGIN_PAGE: State transition - Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
          // Only listen if the state actually changed (not just rebuilt)
          if (current is AuthError && previous is AuthError) {
            return current.message != previous.message;
          }
          if (current is AuthTwoFactorRequired && previous is AuthTwoFactorRequired) {
            return current.userId != previous.userId;
          }
          return current is AuthError || current is AuthTwoFactorRequired;
        },
        listener: (context, state) {
          if (state is AuthError) {
            dev.log('🔴 LOGIN_PAGE: Showing error: ${state.message}');
            _showErrorSnackBar(context, state.message);
          } else if (state is AuthTwoFactorRequired) {
            _navigateToTwoFactor(context, state.userId, state.twoFactorType);
          }
        },
        buildWhen: (previous, current) {
          dev.log('🔵 LOGIN_PAGE: buildWhen - Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
          // Rebuild on any state change
          return true;
        },
        builder: (context, state) {
          dev.log('🔵 LOGIN_PAGE: Rebuilding UI with state: ${state.runtimeType}');

          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(minHeight: context.screenHeight),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildLoginForm(isLoading),
                      const SizedBox(height: 24),
                      _buildSocialLogin(),
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
              // App Logo - simplified, no glow
              const AppLogo.textOnly(
                fontSize: 24,
                style: LogoStyle.elegant,
              ),
              const SizedBox(height: 24),
              // Simplified header text
              Text(
                'Sign In',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back to your account',
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

  Widget _buildLoginForm(bool isLoading) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          PremiumTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            enabled: !isLoading,
            onChanged: (value) {
              // Clear error state when user starts typing
              _clearErrorStateIfNeeded();
            },
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
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            enabled: !isLoading,
            onChanged: (value) {
              // Clear error state when user starts typing
              _clearErrorStateIfNeeded();
            },
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
              // Basic length validation for login (backend will validate fully)
              if (value!.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          _buildRememberMeSection(isLoading),
          const SizedBox(height: 20),
          PremiumButton.gradient(
            text: 'Sign In',
            onPressed: isLoading ? null : _handleLogin,
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

  Widget _buildRememberMeSection(bool isLoading) {
    return Row(
      children: [
        GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  setState(() => _rememberMe = !_rememberMe);
                  HapticFeedback.lightImpact();
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      _rememberMe ? context.colors.primary : Colors.transparent,
                  border: Border.all(
                    color: _rememberMe
                        ? context.colors.primary
                        : context.borderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _rememberMe
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: TextStyle(
                  color: isLoading
                      ? context.textSecondary.withValues(alpha: 0.5)
                      : context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  final authBloc = context.read<AuthBloc>();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          BlocProvider.value(
                        value: authBloc,
                        child: const ForgotPasswordPage(),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: isLoading
                  ? context.colors.primary.withValues(alpha: 0.5)
                  : context.colors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    final config = AppConfig.instance;
    final showGoogleAuth = config.googleAuthEnabled;
    final showWalletAuth = config.walletAuthEnabled;

    // Don't show section if no social login options are enabled
    if (!showGoogleAuth && !showWalletAuth) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Simplified divider
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
        if (showGoogleAuth)
          PremiumButton.outline(
            text: 'Continue with Google',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
            },
            icon: SvgPicture.network(
              'https://www.vectorlogo.zone/logos/google/google-icon.svg',
              height: 18,
              width: 18,
            ),
          ),
        if (showGoogleAuth && showWalletAuth) const SizedBox(height: 12),
        if (showWalletAuth)
          PremiumButton.outline(
            text: 'Connect Wallet',
            onPressed: () {
              // TODO: Implement wallet authentication
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Wallet authentication coming soon'),
                  backgroundColor: context.colors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
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
              "Don't have an account? ",
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
              ),
            ),
            TextButton(
              onPressed: () {
                final authBloc = context.read<AuthBloc>();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        BlocProvider.value(
                      value: authBloc,
                      child: const RegisterPage(),
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sign Up',
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
                const TextSpan(text: 'By signing in, you agree to our '),
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

  void _clearErrorStateIfNeeded() {
    try {
      final authBloc = context.read<AuthBloc>();
      if (!authBloc.isClosed && authBloc.state is AuthError) {
        dev.log('🔵 LOGIN_PAGE: Clearing error state due to user input');
        authBloc.add(const AuthErrorCleared());
      }
    } catch (e) {
      dev.log('🔴 LOGIN_PAGE: Error clearing error state: $e');
      // Silently ignore if BLoC is not available
    }
  }

  void _handleLogin() {
    dev.log('🔵 LOGIN_PAGE: Sign In button pressed');

    // Unfocus any text fields to dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    final isValid = _formKey.currentState?.validate() ?? false;
    dev.log('🔵 LOGIN_PAGE: Form validation result: $isValid');

    if (isValid) {
      // Trigger haptic feedback
      HapticFeedback.lightImpact();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      dev.log('🔵 LOGIN_PAGE: Dispatching login event for email: $email');

      // Dispatch login event with error handling
      try {
        final authBloc = context.read<AuthBloc>();
        if (!authBloc.isClosed) {
          authBloc.add(
            AuthLoginRequested(
              email: email,
              password: password,
            ),
          );
        } else {
          dev.log('🔴 LOGIN_PAGE: AuthBloc is closed, cannot dispatch login event');
          _showErrorSnackBar(context, 'An error occurred. Please restart the app.');
        }
      } catch (e) {
        dev.log('🔴 LOGIN_PAGE: Error dispatching login event: $e');
        _showErrorSnackBar(context, 'An error occurred. Please try again.');
      }
    } else {
      dev.log('🔴 LOGIN_PAGE: Form validation failed');
      // Form validation failed - show haptic feedback
      HapticFeedback.mediumImpact();
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

  void _navigateToTwoFactor(BuildContext context, String userId, String type) {
    final authBloc = context.read<AuthBloc>();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BlocProvider.value(
          value: authBloc,
          child: TwoFactorVerificationPage(
            userId: userId,
            twoFactorType: type,
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
