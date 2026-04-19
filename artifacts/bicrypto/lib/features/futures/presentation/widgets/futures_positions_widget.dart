import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../bloc/futures_positions_bloc.dart';

class FuturesPositionsWidget extends StatelessWidget {
  const FuturesPositionsWidget({super.key, this.symbol});

  final String? symbol;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FuturesPositionsBloc, FuturesPositionsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Positions',
                    style: context.h5.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Refresh positions
                      context.read<FuturesPositionsBloc>().add(
                            FuturesPositionsRefreshRequested(
                                symbol: symbol ?? 'BTC/USDT'),
                          );
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: context.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FuturesPositionsState state) {
    if (state is FuturesPositionsLoading) {
      return ShimmerList(
        itemCount: 3,
        itemBuilder: (context, index) => const FuturesPositionCardShimmer(),
      );
    }

    if (state is FuturesPositionsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading positions',
              style: context.bodyM.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              state.failure.message,
              style: context.bodyS.copyWith(color: context.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is FuturesPositionsLoaded) {
      if (state.positions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: context.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No open positions',
                style: context.bodyM.copyWith(color: context.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Start trading to see your positions here',
                style: context.bodyS.copyWith(color: context.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: state.positions.length,
        itemBuilder: (context, index) {
          final position = state.positions[index];
          return _buildPositionItem(context, position);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPositionItem(BuildContext context, position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                position.symbol,
                style: context.labelM.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: position.side == 'LONG'
                      ? context.buyColor.withValues(alpha: 0.1)
                      : context.sellColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  position.side,
                  style: context.labelS.copyWith(
                    color: position.side == 'LONG'
                        ? context.buyColor
                        : context.sellColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: context.labelS.copyWith(color: context.textTertiary),
                  ),
                  Text(
                    position.amount.toStringAsFixed(4),
                    style: context.bodyM.copyWith(color: context.textPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Leverage',
                    style: context.labelS.copyWith(color: context.textTertiary),
                  ),
                  Text(
                    '${position.leverage.toInt()}x',
                    style: context.bodyM.copyWith(color: context.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // PnL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PnL',
                style: context.labelS.copyWith(color: context.textTertiary),
              ),
              Text(
                '\$${position.unrealisedPnl.toStringAsFixed(2)}',
                style: context.bodyM.copyWith(
                  color: position.isProfit
                      ? context.priceUpColor
                      : context.priceDownColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
