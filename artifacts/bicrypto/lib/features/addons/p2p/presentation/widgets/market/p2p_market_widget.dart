import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../injection/injection.dart';
import '../../../domain/entities/p2p_market_stats_entity.dart';
import '../../bloc/market/market_bloc.dart';
import '../../bloc/market/market_event.dart';
import '../../bloc/market/market_state.dart';
import '../../../../../../core/widgets/error_widget.dart' as core_widgets;
import '../../../../../../core/theme/global_theme_extensions.dart';

/// P2P Market Overview Widget
///
/// Displays market statistics, top cryptocurrencies, and market highlights
/// Uses the main theme system for consistent styling
class P2PMarketWidget extends StatelessWidget {
  const P2PMarketWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<P2PMarketBloc>()..add(const P2PMarketRequested()),
      child: const _P2PMarketContent(),
    );
  }
}

class _P2PMarketContent extends StatelessWidget {
  const _P2PMarketContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<P2PMarketBloc, P2PMarketState>(
      builder: (context, state) {
        if (state is P2PMarketLoading) {
          return const _LoadingCard();
        }

        if (state is P2PMarketError) {
          return core_widgets.ErrorWidget(
            message: state.failure.message,
            onRetry: () {
              context
                  .read<P2PMarketBloc>()
                  .add(const P2PMarketRetryRequested());
            },
          );
        }

        if (state is P2PMarketLoaded) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.cardBackground,
                  context.cardBackground.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildMarketStats(context, state),
                const SizedBox(height: 24),
                _buildTopCryptos(context, state),
                const SizedBox(height: 24),
                _buildMarketHighlights(context, state),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.trending_up,
              color: context.colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P2P Market Overview',
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time trading statistics',
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStats(BuildContext context, P2PMarketLoaded state) {
    final stats = state.stats;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Statistics',
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Trades',
                    stats.totalTrades.toString(),
                    context.colors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Volume',
                    '\$${_formatNumber(stats.totalVolume)}',
                    context.colors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active Trades',
                    stats.activeTrades.toString(),
                    context.buyColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Avg Trade Size',
                    '\$${_formatNumber(stats.avgTradeSize)}',
                    context.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCryptos(BuildContext context, P2PMarketLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Cryptocurrencies',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...state.topCryptos
              .take(5)
              .map((crypto) => _buildCryptoItem(context, crypto)),
        ],
      ),
    );
  }

  Widget _buildCryptoItem(BuildContext context, P2PTopCryptoEntity crypto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                crypto.symbol.substring(0, 2).toUpperCase(),
                style: context.labelM.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.name,
                  style: context.bodyL.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  crypto.symbol.toUpperCase(),
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${crypto.avgPrice.toStringAsFixed(2)}',
                style: context.bodyL.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${crypto.tradeCount} trades',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketHighlights(BuildContext context, P2PMarketLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Highlights',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...state.highlights
              .map((highlight) => _buildHighlightItem(context, highlight)),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(
      BuildContext context, P2PMarketHighlightEntity highlight) {
    final isBuy = highlight.type.toLowerCase() == 'buy';
    final typeColor = isBuy ? context.buyColor : context.sellColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuy ? Icons.trending_up : Icons.trending_down,
              color: typeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${highlight.type.toUpperCase()} ${highlight.currency}',
                  style: context.bodyL.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${highlight.paymentMethod} • ${highlight.country}',
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${highlight.price.toStringAsFixed(2)}',
                style: context.bodyL.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatNumber(highlight.amount)} ${highlight.currency}',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading market data...',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
