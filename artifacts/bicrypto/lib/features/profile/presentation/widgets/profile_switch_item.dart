import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';

/// Reusable profile switch item widget for consistent switch handling
/// across all profile pages in the app
class ProfileSwitchItem extends StatelessWidget {
  const ProfileSwitchItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLoading = false,
    this.errorMessage,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: errorMessage != null
                ? context.colors.error
                : context.borderColor,
            width: errorMessage != null ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => onChanged(!value),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: context.cardPadding,
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      color: _getIconColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: context.labelL.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getTitleColor(context),
                                ),
                              ),
                            ),
                            if (isLoading)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.colors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 14,
                                color: context.colors.error,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: context.bodyS.copyWith(
                                    color: context.colors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Switch
                  _buildSwitch(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: context.textTertiary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: context.colors.primary,
      activeTrackColor: context.colors.primary.withValues(alpha: 0.3),
      inactiveThumbColor: context.textSecondary,
      inactiveTrackColor: context.borderColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getIconBackgroundColor(BuildContext context) {
    if (errorMessage != null) {
      return context.colors.error.withValues(alpha: 0.1);
    }
    if (isLoading) {
      return context.textTertiary.withValues(alpha: 0.1);
    }
    if (value) {
      return context.colors.primary.withValues(alpha: 0.1);
    }
    return context.colors.tertiary.withValues(alpha: 0.1);
  }

  Color _getIconColor(BuildContext context) {
    if (errorMessage != null) {
      return context.colors.error;
    }
    if (isLoading) {
      return context.textTertiary;
    }
    if (value) {
      return context.colors.primary;
    }
    return context.colors.tertiary;
  }

  Color _getTitleColor(BuildContext context) {
    if (errorMessage != null) {
      return context.colors.error;
    }
    if (isLoading) {
      return context.textTertiary;
    }
    return context.textPrimary;
  }
}

/// Profile switch item with section wrapper for consistent grouping
class ProfileSwitchSection extends StatelessWidget {
  const ProfileSwitchSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Column(
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
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: child,
              )),
        ],
      ),
    );
  }
}
