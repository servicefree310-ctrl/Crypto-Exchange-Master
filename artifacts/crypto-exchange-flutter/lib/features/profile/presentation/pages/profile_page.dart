import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection/injection.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/profile_bloc.dart';
import '../../data/services/profile_service.dart';
import 'edit_profile_page.dart';
import 'security_page.dart';
import 'notifications_page.dart';
import '../../../kyc/presentation/pages/kyc_page.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../../../theme/presentation/bloc/theme_event.dart';
import '../../../theme/presentation/bloc/theme_state.dart';
import '../../../theme/domain/entities/app_theme_entity.dart';
import '../../../support/presentation/pages/support_tickets_page.dart';
import '../../../news/presentation/pages/news_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('🔵 PROFILE_PAGE: Building profile page');

    // Ensure the existing ProfileBloc has loaded user profile data
    try {
      final profileBloc = context.read<ProfileBloc>();
      if (profileBloc.state is ProfileInitial) {
        profileBloc.add(const ProfileLoadRequested());
      }
    } catch (_) {
      // ProfileBloc not found in context – this page requires it to be provided
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        dev.log('🔵 PROFILE_PAGE: Current auth state: ${authState.runtimeType}');

        // Check the current state of AuthBloc directly to avoid initial state issues
        final authBloc = context.read<AuthBloc>();
        final currentAuthState = authBloc.state;
        dev.log(
            '🔵 PROFILE_PAGE: AuthBloc current state: ${currentAuthState.runtimeType}');

        // Use the current state instead of the builder's state for immediate check
        if (currentAuthState is! AuthAuthenticated) {
          dev.log('🔵 PROFILE_PAGE: User not authenticated, showing loading');
          return _buildLoadingState(context);
        }

        dev.log('🔵 PROFILE_PAGE: User authenticated, showing profile');
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            dev.log(
                '🔵 PROFILE_PAGE: Current profile state: ${profileState.runtimeType}');

            // Auto-load profile if not loaded yet
            if (profileState is ProfileInitial) {
              dev.log('🔵 PROFILE_PAGE: Profile not loaded, triggering load');
              context.read<ProfileBloc>().add(const ProfileLoadRequested());
            }

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
                  'Profile',
                  style: context.h5,
                ),
                actions: [
                  // Theme toggle (sun/moon)
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, themeState) {
                      IconData icon = Icons.dark_mode; // default moon

                      if (themeState is ThemeLoaded) {
                        switch (themeState.currentTheme) {
                          case AppThemeType.dark:
                            icon =
                                Icons.light_mode; // show sun -> switch to light
                            break;
                          case AppThemeType.light:
                            icon =
                                Icons.dark_mode; // show moon -> switch to dark
                            break;
                          case AppThemeType.system:
                            // Decide icon based on systemTheme fallback
                            if (themeState.systemTheme == AppThemeType.dark) {
                              icon = Icons.light_mode;
                            } else {
                              icon = Icons.dark_mode;
                            }
                            break;
                        }
                      }

                      return IconButton(
                        onPressed: () {
                          context
                              .read<ThemeBloc>()
                              .add(const ThemeToggleRequested());
                        },
                        icon: Icon(icon, color: context.colors.primary),
                        tooltip: 'Toggle Theme',
                      );
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: context.horizontalPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildUserCard(context, currentAuthState, profileState),
                      const SizedBox(height: 20),
                      _buildQuickStats(context, currentAuthState, profileState),
                      const SizedBox(height: 20),
                      _buildMenuSection(context),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(
      BuildContext context, AuthState authState, ProfileState profileState) {
    final profileService = getIt<ProfileService>();

    // Get data from profile service first, then fallback to auth data
    String displayName = 'User';
    String email = '';
    String? avatar;
    bool emailVerified = false;

    // Try to get data from ProfileService first
    if (profileService.currentProfile != null) {
      displayName = profileService.userFullName;
      email = profileService.userEmail;
      avatar = profileService.userAvatar;
      emailVerified = profileService.isEmailVerified;
      dev.log('🟢 PROFILE_PAGE: Using ProfileService data - $displayName');
    }
    // Fallback to ProfileState if available
    else if (profileState is ProfileLoaded) {
      final profile = profileState.profile;
      displayName = '${profile.firstName} ${profile.lastName}'.trim();
      if (displayName.isEmpty || displayName == ' ') {
        displayName = profile.email.split('@')[0];
      }
      email = profile.email;
      avatar = profile.avatar;
      emailVerified = profile.emailVerified;
      dev.log('🟡 PROFILE_PAGE: Using ProfileState data - $displayName');
    }
    // Final fallback to AuthState
    else if (authState is AuthAuthenticated) {
      displayName =
          '${authState.user.firstName} ${authState.user.lastName}'.trim();
      if (displayName.isEmpty || displayName == ' ') {
        displayName = authState.user.email.split('@')[0];
      }
      email = authState.user.email;
      avatar = authState.user.avatar;
      emailVerified = authState.user.emailVerified;
      dev.log('🟡 PROFILE_PAGE: Using AuthState data - $displayName');
    }

    // Fix avatar URL if it's a relative path
    String? fixedAvatarUrl = _fixAvatarUrl(avatar);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildAvatarWidget(context, avatar, displayName),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (emailVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.priceUpColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: context.priceUpColor,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Verified',
                              style: context.labelS.copyWith(
                                color: context.priceUpColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Edit Button
          IconButton(
            onPressed: () => _navigateToPage(context, const EditProfilePage()),
            icon: Icon(
              Icons.edit_outlined,
              color: context.colors.primary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, AuthState authState, ProfileState profileState) {
    final profileService = getIt<ProfileService>();

    String userStatus = 'UNKNOWN';
    String userRole = 'User';
    bool twoFactorEnabled = false;
    int? kycLevel;
    String kycStatusText = 'Not Verified';
    Color kycColor = context.warningColor;

    // Get data from ProfileService first
    if (profileService.currentProfile != null) {
      userStatus = profileService.userStatus;
      userRole = profileService.userRole;
      twoFactorEnabled = profileService.isTwoFactorEnabled;
      kycLevel = profileService.userKycLevel;
    }
    // Fallback to ProfileState if available
    else if (profileState is ProfileLoaded) {
      final profile = profileState.profile;
      userStatus = profile.status;
      userRole = profile.role;
      twoFactorEnabled = profile.twoFactor?.enabled ?? false;
      kycLevel = profile.kycLevel;
    }
    // Final fallback to AuthState
    else if (authState is AuthAuthenticated) {
      userStatus = authState.user.status;
      userRole = authState.user.role ?? 'User';
      twoFactorEnabled = false;
    }

    if (kycLevel != null && kycLevel > 0) {
      kycStatusText = 'Level $kycLevel';
      kycColor = context.priceUpColor;
    }

    // Calculate completion percentage
    int completedItems = 0;
    int totalItems = 4;

    if (userStatus == 'ACTIVE') completedItems++;
    if (userRole == 'Admin') completedItems++; // or any role assigned
    if (twoFactorEnabled) completedItems++;
    if (kycLevel != null && kycLevel > 0) completedItems++;

    double completionPercentage = (completedItems / totalItems) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with completion percentage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completion',
                      style: context.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${completionPercentage.toInt()}% Complete',
                      style: context.labelM.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: completionPercentage >= 75
                      ? context.priceUpColor.withValues(alpha: 0.1)
                      : context.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: completionPercentage >= 75
                        ? context.priceUpColor.withValues(alpha: 0.3)
                        : context.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${completionPercentage.toInt()}%',
                  style: context.labelM.copyWith(
                    color: completionPercentage >= 75
                        ? context.priceUpColor
                        : context.warningColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completionPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: completionPercentage >= 75
                        ? [
                            context.priceUpColor,
                            context.priceUpColor.withValues(alpha: 0.8)
                          ]
                        : [
                            context.warningColor,
                            context.warningColor.withValues(alpha: 0.8)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Status Items Grid
          Row(
            children: [
              Expanded(
                child: _buildCompletionItem(
                  context,
                  'Account',
                  userStatus,
                  userStatus == 'ACTIVE',
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompletionItem(
                  context,
                  'Role',
                  userRole,
                  true, // Role is always assigned
                  Icons.admin_panel_settings,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildCompletionItem(
                  context,
                  '2FA',
                  twoFactorEnabled ? 'Enabled' : 'Setup Required',
                  twoFactorEnabled,
                  Icons.security,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompletionItem(
                  context,
                  'KYC',
                  kycStatusText,
                  kycLevel != null && kycLevel > 0,
                  Icons.verified_user,
                ),
              ),
            ],
          ),

          // Next Step Suggestion
          if (completionPercentage < 100) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: context.colors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getNextStepSuggestion(twoFactorEnabled, kycLevel),
                      style: context.labelM.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.labelM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatCard(BuildContext context, String label, String value,
      Color color, IconData icon,
      {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LIVE',
                    style: context.labelS.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.bodyL.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(BuildContext context, String label, String value,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.labelM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatCard(BuildContext context, String label,
      String value, Color color, IconData icon,
      {required bool isEnabled}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? color.withValues(alpha: 0.3)
              : context.warningColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isEnabled ? color : context.warningColor).withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isEnabled ? color : context.warningColor,
                size: 16,
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isEnabled ? color : context.warningColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.labelM.copyWith(
              color: isEnabled ? color : context.warningColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatCard(BuildContext context, String label,
      String value, Color color, IconData icon,
      {required bool isVerified}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              if (isVerified)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 12,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.labelM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionItem(BuildContext context, String label, String value,
      bool isCompleted, IconData icon) {
    final color = isCompleted ? context.priceUpColor : context.textSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.priceUpColor.withValues(alpha: 0.1)
            : context.borderColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? context.priceUpColor.withValues(alpha: 0.3)
              : context.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.labelS.copyWith(
                    color: context.textTertiary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: context.labelM.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getNextStepSuggestion(bool twoFactorEnabled, int? kycLevel) {
    if (!twoFactorEnabled) {
      return 'Next: Setup 2FA Security for better protection';
    }
    if (kycLevel == null || kycLevel == 0) {
      return 'Next: Complete KYC verification to unlock all features';
    }
    return 'All set! Your profile is fully configured.';
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: context.h6.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context,
          [
            _buildMenuItem(
              context,
              Icons.security_outlined,
              'Security',
              'Password and security settings',
              () => _navigateToPage(context, const SecurityPage()),
            ),
            _buildMenuItem(
              context,
              Icons.verified_user_outlined,
              'KYC Verification',
              'Complete identity verification',
              () => _navigateToPage(context, const KycPage()),
            ),
            _buildMenuItem(
              context,
              Icons.notifications_outlined,
              'Notifications',
              'Manage your notification preferences',
              () => _navigateToPage(context, const NotificationsPage()),
            ),
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Help & Support',
              'Get help and contact support',
              () => _navigateToPage(context, const SupportTicketsPage()),
            ),
            _buildMenuItem(
              context,
              Icons.settings_outlined,
              'News Settings',
              'Manage your news preferences',
              () => _navigateToPage(context, const NewsSettingsPage()),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  color: context.dividerColor,
                  height: 1,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: context.colors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.labelM.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: context.textTertiary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: context.priceDownColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: context.priceDownColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: context.labelM.copyWith(
                    color: context.priceDownColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, String displayName) {
    return Center(
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: context.h5.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.priceDownColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: context.h3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodyL.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthCheckRequested());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAuthenticatedState(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              color: context.textTertiary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Not Authenticated',
              style: context.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to view your profile',
              style: context.bodyL.copyWith(color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    // Navigate to the page - profile pages create their own bloc instances
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authBloc = getIt<AuthBloc>(); // Use singleton directly

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during logout
      builder: (BuildContext dialogContext) {
        // Set up a timer to close dialog after logout completes
        Timer? closeTimer;

        return BlocListener<AuthBloc, AuthState>(
          bloc: authBloc,
          listener: (context, state) {
            dev.log(
                '🔵 PROFILE_PAGE: Logout dialog received state: ${state.runtimeType}');
            if (state is AuthUnauthenticated) {
              // Close dialog immediately - AuthWrapper will handle navigation
              closeTimer?.cancel();
              try {
                if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  dev.log('🟢 PROFILE_PAGE: Logout successful, dialog closed');
                }
              } catch (e) {
                dev.log('🔴 PROFILE_PAGE: Error closing dialog after logout: $e');
              }
            } else if (state is AuthError) {
              // Close dialog and show error message
              closeTimer?.cancel();
              try {
                if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }
                // Show error message on the main context, not dialog context
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    _showLogoutErrorMessage(context, state.message);
                  } catch (e) {
                    dev.log('🔴 PROFILE_PAGE: Error showing logout error: $e');
                  }
                });
              } catch (e) {
                dev.log('🔴 PROFILE_PAGE: Error closing dialog after error: $e');
              }
            } else if (state is AuthLoading) {
              // Set up a fallback timer to close dialog after 5 seconds (reduced from 10)
              closeTimer?.cancel();
              closeTimer = Timer(const Duration(seconds: 5), () {
                try {
                  if (Navigator.of(dialogContext, rootNavigator: true)
                      .canPop()) {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                    dev.log('🟡 PROFILE_PAGE: Logout dialog closed by timeout');
                  }
                } catch (e) {
                  dev.log('🔴 PROFILE_PAGE: Error closing dialog by timeout: $e');
                }
              });
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            bloc: authBloc,
            builder: (context, state) {
              final isLoggingOut = state is AuthLoading;

              return AlertDialog(
                backgroundColor: context.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      isLoggingOut ? Icons.hourglass_empty : Icons.logout,
                      color: isLoggingOut
                          ? context.warningColor
                          : context.priceDownColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isLoggingOut ? 'Logging out...' : 'Logout',
                      style: context.h5,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoggingOut) ...[
                      CircularProgressIndicator(
                        color: context.colors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Signing you out securely...',
                        style: context.bodyS
                            .copyWith(color: context.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        'Are you sure you want to logout?',
                        style: context.bodyL
                            .copyWith(color: context.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will need to sign in again to access your account.',
                        style: context.bodyS
                            .copyWith(color: context.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                actions: isLoggingOut
                    ? []
                    : [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'Cancel',
                            style: context.labelL
                                .copyWith(color: context.textSecondary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            dev.log('🔵 PROFILE_PAGE: User confirmed logout');
                            authBloc.add(AuthLogoutRequested());
                            // Removed the problematic Timer - BlocListener handles dialog closing
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.priceDownColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: context.labelL.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Successfully logged out',
              style: context.labelL.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: context.priceUpColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Logout failed: $message',
                style: context.labelL.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.priceDownColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _showLogoutDialog(context),
        ),
      ),
    );
  }

  String? _fixAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }

    // If it's already a full URL, return as is
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }

    // If it's a relative path starting with /, add the base URL
    if (avatarUrl.startsWith('/')) {
      return '${ApiConstants.baseUrl}$avatarUrl';
    }

    // If it's a file:// URL, return null (invalid for network image)
    if (avatarUrl.startsWith('file://')) {
      return null;
    }

    // For any other case, assume it needs the base URL
    return '${ApiConstants.baseUrl}/$avatarUrl';
  }

  Widget _buildAvatarWidget(
      BuildContext context, String? avatarUrl, String displayName) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return _buildDefaultAvatar(context, displayName);
    }

    final fixedAvatarUrl = _fixAvatarUrl(avatarUrl);
    if (fixedAvatarUrl == null) {
      return _buildDefaultAvatar(context, displayName);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        fixedAvatarUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          dev.log('🔴 PROFILE_PAGE: Avatar image error: $error');
          // Log the specific error for debugging
          if (error.toString().contains('500')) {
            dev.log(
                '🔴 PROFILE_PAGE: Server error (500) for avatar: $fixedAvatarUrl');
          } else if (error.toString().contains('timeout')) {
            dev.log('🔴 PROFILE_PAGE: Timeout error for avatar: $fixedAvatarUrl');
          }
          return _buildDefaultAvatar(context, displayName);
        },
        // Add timeout to prevent long loading
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }
}
