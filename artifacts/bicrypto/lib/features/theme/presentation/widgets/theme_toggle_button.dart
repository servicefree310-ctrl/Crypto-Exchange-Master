import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/app_theme_entity.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

/// A reusable theme toggle button widget
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const ThemeToggleButton({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is! ThemeLoaded) {
          return const SizedBox.shrink();
        }

        final currentTheme = state.currentTheme;

        if (compact) {
          return _buildCompactButton(context, currentTheme);
        }

        return _buildFullButton(context, currentTheme);
      },
    );
  }

  Widget _buildCompactButton(BuildContext context, AppThemeType currentTheme) {
    return IconButton(
      icon: Icon(
        _getThemeIcon(currentTheme),
        color: context.textSecondary,
      ),
      onPressed: () => _toggleTheme(context),
      tooltip: _getThemeTooltip(currentTheme),
    );
  }

  Widget _buildFullButton(BuildContext context, AppThemeType currentTheme) {
    return InkWell(
      onTap: () => _showThemeMenu(context, currentTheme),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getThemeIcon(currentTheme),
              size: 20,
              color: context.textSecondary,
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                _getThemeLabel(currentTheme),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    context.read<ThemeBloc>().add(const ThemeToggleRequested());
  }

  void _showThemeMenu(BuildContext context, AppThemeType currentTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeSelectionBottomSheet(
        currentTheme: currentTheme,
      ),
    );
  }

  IconData _getThemeIcon(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return Icons.light_mode_rounded;
      case AppThemeType.dark:
        return Icons.dark_mode_rounded;
      case AppThemeType.system:
        return Icons.settings_brightness_rounded;
    }
  }

  String _getThemeLabel(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.system:
        return 'System';
    }
  }

  String _getThemeTooltip(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return 'Switch to dark mode';
      case AppThemeType.dark:
        return 'Switch to light mode';
      case AppThemeType.system:
        return 'Toggle theme';
    }
  }
}

/// Bottom sheet for theme selection
class _ThemeSelectionBottomSheet extends StatelessWidget {
  final AppThemeType currentTheme;

  const _ThemeSelectionBottomSheet({
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose Theme',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Theme options
            _buildThemeOption(
              context,
              AppThemeType.light,
              Icons.light_mode_rounded,
              'Light',
              'Light theme with bright colors',
            ),
            _buildThemeOption(
              context,
              AppThemeType.dark,
              Icons.dark_mode_rounded,
              'Dark',
              'Dark theme with muted colors',
            ),
            _buildThemeOption(
              context,
              AppThemeType.system,
              Icons.settings_brightness_rounded,
              'System',
              'Follow system theme setting',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppThemeType theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = currentTheme == theme;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          context.read<ThemeBloc>().add(
                ThemeChangeRequested(theme: theme),
              );
        }
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : context.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: context.colors.primary, width: 2)
                    : null,
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? context.colors.primary : context.textSecondary,
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
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.colors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
