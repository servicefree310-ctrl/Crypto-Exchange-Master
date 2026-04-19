import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../bloc/futures_header_bloc.dart';
import '../bloc/futures_header_state.dart';
import 'futures_pair_side_menu.dart';
import '../bloc/futures_header_event.dart';

class FuturesHeader extends StatelessWidget {
  const FuturesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FuturesHeaderBloc, FuturesHeaderState>(
      builder: (context, state) {
        if (state is FuturesHeaderLoading) {
          return const FuturesHeaderShimmer();
        }

        if (state is FuturesHeaderNoMarket) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 32,
                  color: context.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'No futures markets available',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is FuturesHeaderError) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 32,
                  color: context.priceDownColor,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is FuturesHeaderLoaded) {
          final isPositive = state.changePercent >= 0;
          final changeColor =
              isPositive ? context.priceUpColor : context.priceDownColor;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: context.borderColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Main header row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _openPairMenu(context, state.symbol),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                state.symbol,
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: context.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perpetual',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          state.currentPrice > 0
                              ? '\$${state.currentPrice.toStringAsFixed(2)}'
                              : '--',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: changeColor,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${isPositive ? '+' : ''}${state.changePercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: changeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Funding info row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.inputBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Funding',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${state.fundingRate.toStringAsFixed(4)}%',
                        style: TextStyle(
                          color: state.fundingRate >= 0
                              ? context.priceUpColor
                              : context.priceDownColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Next in ${state.fundingCountdown}',
                        style: TextStyle(
                          color: context.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Initial state - show shimmer
        return const FuturesHeaderShimmer();
      },
    );
  }

  void _openPairMenu(BuildContext context, String symbol) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Futures Pair Selector',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim, secAnim) {
        return Align(
          alignment: Alignment.centerLeft,
          child: FuturesPairSideMenu(
            currentSymbol: symbol,
            onPairSelected: (s) {
              Navigator.of(ctx).pop();
              context.read<FuturesHeaderBloc>().add(
                    FuturesHeaderSymbolChanged(symbol: s),
                  );
            },
          ),
        );
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }
}
