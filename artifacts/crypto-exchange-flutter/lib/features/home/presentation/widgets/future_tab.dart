import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../futures/presentation/pages/futures_trading_page.dart';

class FutureTab extends StatelessWidget {
  const FutureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final isAvailable = _isFeatureAvailable(state);
        final isComingSoon = _isFeatureComingSoon(state);

        if (isAvailable) {
          // Show actual futures trading page
          return const FuturesTradingPage();
        } else if (isComingSoon) {
          // Show coming soon UI
          return _buildComingSoonUI(context);
        } else {
          // Feature is hidden, show empty state
          return _buildHiddenUI(context);
        }
      },
    );
  }

  bool _isFeatureAvailable(SettingsState state) {
    if (state is SettingsLoaded || state is SettingsUpdated) {
      final settings = (state as dynamic).settings;
      return settings?.isFeatureAvailable('futures') ?? false;
    }
    return false;
  }

  bool _isFeatureComingSoon(SettingsState state) {
    if (state is SettingsLoaded || state is SettingsUpdated) {
      final settings = (state as dynamic).settings;
      return settings?.comingSoonFeatures.contains('futures') ?? false;
    }
    return false;
  }

  Widget _buildComingSoonUI(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3498DB),
                        const Color(0xFF2980B9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Futures Trading',
                  style: context.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Coming Soon',
                  style: context.h5.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'Advanced futures trading with leverage up to 125x will be available soon. Get ready for professional trading tools!',
                  style: context.bodyL.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Features list
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.borderColor,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(context, 'Leverage up to 125x'),
                      _buildFeatureItem(context, 'Advanced charting tools'),
                      _buildFeatureItem(context, 'Real-time market data'),
                      _buildFeatureItem(context, 'Risk management tools'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: context.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: context.bodyM.copyWith(
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenUI(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 80,
                  color: context.textSecondary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Feature Unavailable',
                  style: context.h4.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Futures trading is not available in your current plan.',
                  style: context.bodyL.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Note: legacy placeholder methods removed after FuturesPage integration.
}
