import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../kyc/presentation/pages/kyc_page.dart';
import 'notification_button.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = getIt<ProfileService>();

    String displayName = 'Trader';
    String userRole = 'User';
    bool isVerified = false;
    int? kycLevel;
    String kycStatusLabel = 'KYC Not Verified';

    if (profileService.currentProfile != null) {
      final userName = profileService.userFullName;
      displayName = userName.trim();
      if (displayName.isEmpty || displayName == 'User') {
        displayName = profileService.userEmail.split('@')[0];
      } else {
        // Use only first name for better space management
        final nameParts = displayName.split(' ');
        displayName = nameParts.first;
      }
      isVerified = profileService.isEmailVerified;
      userRole = profileService.userRole ?? 'User';

      kycLevel = profileService.userKycLevel;
      if (kycLevel != null && kycLevel > 0) {
        kycStatusLabel = 'Level $kycLevel • KYC Verified';
      }
    } else {
      final authBloc = BlocProvider.of<AuthBloc>(context);
      if (authBloc.state is AuthAuthenticated) {
        final authState = authBloc.state as AuthAuthenticated;
        final fullName =
            '${authState.user.firstName} ${authState.user.lastName}'.trim();
        if (fullName.isEmpty || fullName == ' ') {
          displayName = authState.user.email.split('@')[0];
        } else {
          // Use only first name for better space management
          displayName = authState.user.firstName.isNotEmpty
              ? authState.user.firstName
              : authState.user.email.split('@')[0];
        }
        userRole = _getRoleFromUserRole(authState.user.role);
      }
    }

    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius:
            BorderRadius.circular(context.isSmallScreen ? 14.0 : 16.0),
        border: Border.all(
          color: context.borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main header row
          Row(
            children: [
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    SizedBox(height: context.isSmallScreen ? 2.0 : 4.0),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: context.h5.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (userRole != 'User') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: context.colors.primary.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              userRole,
                              style: context.labelS.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 9.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                children: [
                  const NotificationButton(),
                  SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
                  _buildSettingsButton(context),
                ],
              ),
            ],
          ),

          // KYC status row
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.isSmallScreen ? 12.0 : 16.0,
              vertical: context.isSmallScreen ? 8.0 : 10.0,
            ),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  kycLevel != null && kycLevel > 0
                      ? Icons.verified_outlined
                      : Icons.info_outline,
                  size: 16.0,
                  color: kycLevel != null && kycLevel > 0
                      ? context.priceUpColor
                      : context.textTertiary,
                ),
                SizedBox(width: context.isSmallScreen ? 8.0 : 10.0),
                Expanded(
                  child: Text(
                    kycStatusLabel,
                    style: context.bodyS.copyWith(
                      color: kycLevel != null && kycLevel > 0
                          ? context.textPrimary
                          : context.textSecondary,
                      fontWeight: kycLevel != null && kycLevel > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (kycLevel == null || kycLevel == 0) ...[
                  GestureDetector(
                    onTap: () => _navigateToKycPage(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Complete KYC',
                        style: context.bodyS.copyWith(
                          color: context.warningColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleFromUserRole(String? role) {
    switch (role) {
      case '1':
        return 'Admin';
      case '2':
        return 'User';
      case '3':
        return 'Moderator';
      default:
        return 'User';
    }
  }

  void _navigateToKycPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KycPage(),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    final size = context.isSmallScreen ? 36.0 : 40.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: getIt<AuthBloc>(),
                ),
                BlocProvider.value(
                  value: getIt<ProfileBloc>(),
                ),
              ],
              child: const ProfilePage(),
            ),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Icon(
          Icons.settings_outlined,
          color: context.textSecondary,
          size: context.isSmallScreen ? 18.0 : 20.0,
        ),
      ),
    );
  }
}
