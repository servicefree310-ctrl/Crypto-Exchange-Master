import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/forgot_password_page.dart';
import '../../data/services/profile_service.dart';
import '../bloc/profile_bloc.dart';
import 'two_factor_setup_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final ProfileService _profileService = getIt<ProfileService>();

  @override
  Widget build(BuildContext context) {
    dev.log('🔵 SECURITY_PAGE: Building security page');

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security',
          style: context.h5,
        ),
      ),
      body: BlocProvider.value(
        value: getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: context.horizontalPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityCard(context),
                  const SizedBox(height: 24),
                  _buildSecurityScoreSection(context),
                  const SizedBox(height: 24),
                  _buildTwoFactorSection(context, state),
                  const SizedBox(height: 24),
                  _buildPasswordSection(context),
                  const SizedBox(height: 24),
                  _buildSecurityRecommendations(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.security,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Account Security',
            style: context.h5.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account security settings and two-factor authentication',
            textAlign: TextAlign.center,
            style: context.bodyS.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreSection(BuildContext context) {
    final securityScore = _profileService.securityScore;
    final scoreText = _profileService.getSecurityScoreText();
    final scoreColor = _profileService.getSecurityScoreColor();
    final progressColor = _profileService.getSecurityScoreProgressColor();

    return Container(
      width: double.infinity,
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Security Score',
                style: context.h5.copyWith(color: context.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: context.colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.borderColor,
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: securityScore / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(scoreColor),
                        ),
                      ),
                    ),
                    // Score text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$securityScore',
                          style: context.h4.copyWith(
                            color: _getScoreColor(scoreColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/100',
                          style: context.labelS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Score details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scoreText,
                      style: context.h5.copyWith(
                        color: _getScoreColor(scoreColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      securityScore < 80
                          ? 'Improve your security by enabling 2FA'
                          : 'Your account is well protected',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityScoreBreakdown(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreBreakdown(BuildContext context) {
    final has2FA = _profileService.isTwoFactorEnabled;
    final hasEmail = _profileService.isEmailVerified;
    final hasPhone = _profileService.isPhoneVerified;

    return Column(
      children: [
        _buildScoreItem(
          context,
          'Two-Factor Authentication',
          has2FA,
          has2FA ? '+30 points' : '+0 points',
        ),
        const SizedBox(height: 8),
        _buildScoreItem(
          context,
          'Email Verification',
          hasEmail,
          hasEmail ? '+20 points' : '+0 points',
        ),
        const SizedBox(height: 8),
        _buildScoreItem(
          context,
          'Phone Verification',
          hasPhone,
          hasPhone ? '+20 points' : '+0 points',
        ),
      ],
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String title,
    bool isEnabled,
    String points,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isEnabled
                ? context.priceUpColor.withValues(alpha: 0.1)
                : context.priceDownColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isEnabled ? Icons.check : Icons.close,
            size: 12,
            color: isEnabled ? context.priceUpColor : context.priceDownColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        Text(
          points,
          style: context.labelS.copyWith(
            color: isEnabled ? context.priceUpColor : context.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(String colorName) {
    switch (colorName) {
      case 'green':
        return context.priceUpColor;
      case 'amber':
        return context.warningColor;
      case 'red':
        return context.priceDownColor;
      default:
        return context.textPrimary;
    }
  }

  Widget _buildTwoFactorSection(BuildContext context, ProfileState state) {
    // Get 2FA status from ProfileService or ProfileState
    bool twoFactorEnabled = false;
    String? twoFactorType;

    if (state is ProfileLoaded) {
      twoFactorEnabled = state.profile.twoFactor?.enabled ?? false;
      twoFactorType = state.profile.twoFactor?.type;
    } else if (_profileService.currentProfile != null) {
      twoFactorEnabled = _profileService.isTwoFactorEnabled;
      twoFactorType = _profileService.currentProfile?.twoFactor?.type;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Two-Factor Authentication',
          style: context.h5,
        ),
        const SizedBox(height: 4),
        Text(
          'Add an extra layer of security to your account',
          style: context.bodyS.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              _buildSecurityItem(
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                subtitle: twoFactorEnabled
                    ? 'Enabled with ${_getMethodDisplayName(twoFactorType)} - Your account is protected'
                    : 'Disabled - Set up 2FA to secure your account',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: twoFactorEnabled
                            ? context.priceUpColor.withValues(alpha: 0.1)
                            : context.priceDownColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: twoFactorEnabled
                              ? context.priceUpColor.withValues(alpha: 0.3)
                              : context.priceDownColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        twoFactorEnabled ? 'Enabled' : 'Disabled',
                        style: context.labelS.copyWith(
                          color: twoFactorEnabled
                              ? context.priceUpColor
                              : context.priceDownColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: context.textTertiary,
                      size: 16,
                    ),
                  ],
                ),
                onTap: () => _handleTwoFactorTap(context, twoFactorEnabled),
              ),
              if (twoFactorEnabled) ...[
                Divider(color: context.dividerColor, height: 1, indent: 56),
                _buildSecurityItem(
                  icon: Icons.backup,
                  title: 'Recovery Codes',
                  subtitle: 'View or regenerate your backup recovery codes',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: context.textTertiary,
                    size: 16,
                  ),
                  onTap: () => _showRecoveryCodes(context),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return _buildSection(
      title: 'Password & Login',
      subtitle: 'Manage your login credentials',
      children: [
        _buildSecurityItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          trailing: Icon(Icons.arrow_forward_ios,
              color: context.textTertiary, size: 16),
          onTap: () => _changePassword(context),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.h5,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: context.bodyS.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? context.priceDownColor.withValues(alpha: 0.1)
                      : context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? context.priceDownColor
                      : context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.labelL.copyWith(
                        color: isDestructive
                            ? context.priceDownColor
                            : context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          context.bodyS.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _getMethodDisplayName(String? method) {
    switch (method) {
      case 'APP':
        return 'Authenticator App';
      case 'SMS':
        return 'SMS';
      case 'EMAIL':
        return 'Email';
      default:
        return 'Unknown Method';
    }
  }

  void _handleTwoFactorTap(BuildContext context, bool isEnabled) {
    if (isEnabled) {
      _showDisableTwoFactorDialog(context);
    } else {
      _navigateToTwoFactorSetup(context);
    }
  }

  void _navigateToTwoFactorSetup(BuildContext context) {
    dev.log('🔵 SECURITY_PAGE: Navigating to 2FA setup');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TwoFactorSetupPage(),
      ),
    ).then((_) {
      // Refresh profile to get updated 2FA status
      context
          .read<ProfileBloc>()
          .add(const ProfileLoadRequested(forceRefresh: true));
    });
  }

  void _showDisableTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Disable Two-Factor Authentication',
          style: context.h5.copyWith(color: context.textPrimary),
        ),
        content: Text(
          'Are you sure you want to disable two-factor authentication? This will make your account less secure.',
          style: context.bodyL.copyWith(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.labelL.copyWith(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disableTwoFactor(context);
            },
            child: Text(
              'Disable',
              style: context.labelL.copyWith(color: context.priceDownColor),
            ),
          ),
        ],
      ),
    );
  }

  void _disableTwoFactor(BuildContext context) {
    dev.log('🔵 SECURITY_PAGE: Disabling 2FA');

    // Use ProfileBloc to toggle 2FA off
    context
        .read<ProfileBloc>()
        .add(const ProfileTwoFactorToggleRequested(false));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: context.warningColor),
            const SizedBox(width: 12),
            Text('Two-factor authentication disabled'),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showRecoveryCodes(BuildContext context) {
    dev.log('🔵 SECURITY_PAGE: Showing recovery codes');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: context.colors.primary),
            const SizedBox(width: 12),
            Text('Recovery codes feature coming soon'),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    dev.log('🔵 SECURITY_PAGE: Change password tapped - showing V5-style dialog');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: context.warningColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Change Password',
              style: context.h5.copyWith(color: context.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For maximum security, password changes require email verification.',
              style: context.bodyL.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'You will be:',
              style: context.labelL.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildStepItem('1', 'Logged out from your account'),
            _buildStepItem('2', 'Redirected to the login page'),
            _buildStepItem('3', 'Asked to click "Forgot Password"'),
            _buildStepItem('4', 'Receive a reset email'),
            _buildStepItem('5', 'Set your new password securely'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This approach prevents unauthorized password changes and follows security best practices.',
                      style: context.bodyS.copyWith(
                        color: context.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.labelL.copyWith(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logoutAndResetPassword(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.warningColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log Out & Reset',
              style: context.labelL.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: context.labelS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.bodyM.copyWith(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _logoutAndResetPassword(BuildContext context) {
    dev.log('🔵 SECURITY_PAGE: Logging out and navigating to reset password');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Logging out...',
              style: context.labelL.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing to redirect you to the password reset page',
              style: context.bodyS.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Close the dialog and navigate immediately
    Navigator.of(context).pop(); // Close the loading dialog

    // Navigate to forgot password page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => getIt<AuthBloc>(),
          child: const ForgotPasswordPage(),
        ),
      ),
      (route) => false, // Remove all previous routes
    );

    // Log out the user (this will happen after navigation is complete)
    getIt<AuthBloc>().add(AuthLogoutRequested());
  }

  Widget _buildSecurityRecommendations(BuildContext context) {
    final has2FA = _profileService.isTwoFactorEnabled;
    final hasEmail = _profileService.isEmailVerified;
    final hasPhone = _profileService.isPhoneVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Recommendations',
          style: context.h5,
        ),
        const SizedBox(height: 4),
        Text(
          'Follow these recommendations to improve your account security',
          style: context.bodyS.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              if (!has2FA) ...[
                _buildRecommendationItem(
                  context,
                  icon: Icons.security,
                  title: 'Enable Two-Factor Authentication',
                  description: 'Add an extra layer of security to your account',
                  actionText: 'Enable 2FA',
                  onAction: () => _navigateToTwoFactorSetup(context),
                  isUrgent: true,
                ),
                if (hasEmail || hasPhone)
                  Divider(color: context.dividerColor, height: 1),
              ],
              if (!hasEmail) ...[
                _buildRecommendationItem(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Verify Your Email Address',
                  description: 'Email verification helps secure your account',
                  actionText: 'Verify Email',
                  onAction: () => _showEmailVerificationInfo(context),
                  isUrgent: false,
                ),
                if (hasPhone) Divider(color: context.dividerColor, height: 1),
              ],
              if (!hasPhone) ...[
                _buildRecommendationItem(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Add Phone Number',
                  description:
                      'Phone verification provides additional security',
                  actionText: 'Add Phone',
                  onAction: () => _showPhoneVerificationInfo(context),
                  isUrgent: false,
                ),
              ],
              if (has2FA && hasEmail && hasPhone) ...[
                _buildRecommendationItem(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'Your Account is Well Protected',
                  description:
                      'You\'ve enabled all recommended security features',
                  actionText: null,
                  onAction: null,
                  isUrgent: false,
                  isCompleted: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    String? actionText,
    VoidCallback? onAction,
    required bool isUrgent,
    bool isCompleted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? context.priceUpColor.withValues(alpha: 0.1)
                  : isUrgent
                      ? context.warningColor.withValues(alpha: 0.1)
                      : context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted
                  ? context.priceUpColor
                  : isUrgent
                      ? context.warningColor
                      : context.colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelL.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isUrgent ? context.warningColor : context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionText,
                style: context.labelS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEmailVerificationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Email Verification',
          style: context.h5.copyWith(color: context.textPrimary),
        ),
        content: Text(
          'Email verification helps secure your account and is required for password resets. Please contact support to verify your email address.',
          style: context.bodyL.copyWith(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: context.labelL.copyWith(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerificationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Phone Verification',
          style: context.h5.copyWith(color: context.textPrimary),
        ),
        content: Text(
          'Phone verification provides an additional layer of security. Please contact support to add and verify your phone number.',
          style: context.bodyL.copyWith(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: context.labelL.copyWith(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
