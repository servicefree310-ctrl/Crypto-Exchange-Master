import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/trading_header_bloc.dart';
import '../../../../features/home/presentation/pages/home_page.dart';

/// Tabs widget to switch between Spot, Futures, and AI Investment
/// Used only inside the main TradingPage. Not imported in Futures page.
class TradingTypeTabs extends StatelessWidget {
  const TradingTypeTabs({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradingHeaderBloc, TradingHeaderState>(
      builder: (context, state) {
        TradingType selected = TradingType.spot;
        if (state is TradingHeaderLoaded) {
          selected = state.selectedType;
        }

        return SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabItem(
                  context,
                  'Spot',
                  isSelected: selected == TradingType.spot,
                  onTap: () => context.read<TradingHeaderBloc>().add(
                        const TradingTypeChanged(tradingType: TradingType.spot),
                      ),
                ),
                const SizedBox(width: 8),
                _buildTabItem(
                  context,
                  'Futures',
                  isSelected: false,
                  onTap: () {
                    // Navigate to futures tab in main navbar
                    HomePage.navigateToTab(context, 'futures');
                  },
                ),
                const SizedBox(width: 8),
                _buildTabItem(
                  context,
                  'AI Investment',
                  isSelected: selected == TradingType.isolatedMargin,
                  onTap: () => context.read<TradingHeaderBloc>().add(
                        const TradingTypeChanged(
                            tradingType: TradingType.isolatedMargin),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    String title, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        foregroundColor:
            isSelected ? context.textPrimary : context.textSecondary,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onPressed: onTap,
      child: Text(title),
    );
  }
}
