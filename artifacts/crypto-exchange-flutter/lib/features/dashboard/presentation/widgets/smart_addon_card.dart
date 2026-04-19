import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class SmartAddonCard extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  final String description;
  final String badge;
  final VoidCallback? onTap;

  const SmartAddonCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.badge,
    this.onTap,
  });

  @override
  State<SmartAddonCard> createState() => _SmartAddonCardState();
}

class _SmartAddonCardState extends State<SmartAddonCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state is SettingsLoaded || state is SettingsUpdated
            ? (state as dynamic).settings
            : null;

        // Check if feature is available
        final isAvailable = settings?.isFeatureAvailable(widget.icon) ?? false;
        final isComingSoon = AppConstants.defaultShowComingSoon &&
            (settings?.comingSoonFeatures.contains(widget.icon) ?? false);

        // Determine if we should show this addon
        final shouldShow = isAvailable || isComingSoon;

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return Material(
          color: context.cardBackground,
          borderRadius:
              BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
          child: InkWell(
            onTap: isAvailable
                ? widget.onTap
                : () => _showComingSoonToast(context),
            borderRadius:
                BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isAvailable
                      ? widget.color.withValues(alpha: 0.3)
                      : context.borderColor,
                  width: 1,
                ),
                borderRadius:
                    BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: context.isSmallScreen ? 8.0 : 10.0,
                horizontal: context.isSmallScreen ? 8.0 : 12.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: context.isSmallScreen ? 28.0 : 32.0,
                        height: context.isSmallScreen ? 28.0 : 32.0,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            _buildAddonIcon(widget.icon, widget.color, context),
                      ),
                      if (isAvailable)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: context.isSmallScreen ? 8.0 : 10.0,
                            height: context.isSmallScreen ? 8.0 : 10.0,
                            decoration: BoxDecoration(
                              color: context.priceUpColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.cardBackground,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      if (isComingSoon)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: context.isSmallScreen ? 8.0 : 10.0,
                            height: context.isSmallScreen ? 8.0 : 10.0,
                            decoration: BoxDecoration(
                              color: context.warningColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.cardBackground,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.schedule,
                              size: context.isSmallScreen ? 6.0 : 8.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.isSmallScreen ? 3.0 : 4.0),
                  Column(
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: context.labelS.copyWith(
                          fontSize: context.isSmallScreen ? 9.0 : 10.0,
                          fontWeight: FontWeight.w500,
                          color: isComingSoon
                              ? context.textSecondary
                              : context.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.isSmallScreen ? 1.0 : 2.0),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.isSmallScreen ? 3.0 : 4.0,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isComingSoon
                              ? context.warningColor.withValues(alpha: 0.2)
                              : widget.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          isComingSoon ? 'Soon' : widget.badge,
                          style: context.labelS.copyWith(
                            color: isComingSoon
                                ? context.warningColor
                                : widget.color,
                            fontSize: context.isSmallScreen ? 6.0 : 7.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddonIcon(String icon, Color color, BuildContext context) {
    final iconMap = {
      'p2p': Icons.people_outline,
      'futures': Icons.trending_up,
      'staking': Icons.savings_outlined,
      'ico': Icons.rocket_launch_outlined,
      'blog': Icons.article_outlined,
      'ecommerce': Icons.shopping_cart_outlined,
      'aiInvestment': Icons.psychology_outlined,
      'forex': Icons.currency_exchange,
      'ecosystem': Icons.eco_outlined,
      'mlm': Icons.account_tree_outlined,
      'mailwizard': Icons.email_outlined,
      'wallet_connect': Icons.account_balance_wallet_outlined,
    };

    return Icon(
      iconMap[icon] ?? Icons.apps,
      color: color,
      size: context.isSmallScreen ? 18.0 : 20.0,
    );
  }

  void _showComingSoonToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.title} is coming soon!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: context.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
