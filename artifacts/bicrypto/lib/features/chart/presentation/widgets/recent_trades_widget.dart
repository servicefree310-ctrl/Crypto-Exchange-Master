import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/chart_bloc.dart';
import '../../domain/entities/chart_entity.dart';
import '../../domain/value_objects/trade_display_vo.dart';

class RecentTradesWidget extends StatelessWidget {
  const RecentTradesWidget({
    super.key,
    required this.symbol,
    this.tradesData,
  });

  final String symbol;
  final List<TradeEntry>? tradesData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        List<TradeDataPoint> trades = [];

        if (state is ChartLoaded) {
          trades = state.chartData.tradesData;
          dev.log('🔄 RECENT_TRADES: Displaying ${trades.length} trades');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sleek Header
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.inputBackground,
                border: Border(
                  bottom: BorderSide(
                    color: context.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Trade icon
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.inputBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: context.textPrimary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Trades',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Live indicator
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.priceUpColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: context.priceUpColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Compact Column Headers
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Price',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Amount',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Time',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Trades list (latest 20 trades, newest at top)
            Column(
              children: _buildTradesItems(context, trades),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTradesItems(
      BuildContext context, List<TradeDataPoint> trades) {
    if (trades.isNotEmpty) {
      // Note: Trades are already sorted by the ChartBloc business logic
      // We just take the first 20 trades (which are already the most recent)
      final displayTrades = trades.take(20).toList();

      dev.log(
          '🔄 RECENT_TRADES: Building ${displayTrades.length} trade rows (pre-sorted)');

      return displayTrades
          .map((trade) => _buildTradeRow(context, TradeDisplayVO(trade: trade)))
          .toList();
    } else {
      // Show compact placeholder rows while waiting for real data
      return List.generate(15, (index) {
        return _buildEmptyTradeRow(context);
      });
    }
  }

  Widget _buildEmptyTradeRow(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: context.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: context.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: context.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeRow(BuildContext context, TradeDisplayVO tradeDisplay) {
    final color = Color(tradeDisplay.tradeColorValue);
    final bgColor = Color(tradeDisplay.backgroundColorValue);

    return Container(
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Side indicator + Price
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tradeDisplay.formattedPrice,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Expanded(
              flex: 3,
              child: Text(
                tradeDisplay.formattedAmount,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Time
            Expanded(
              flex: 2,
              child: Text(
                tradeDisplay.formattedTime,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBaseCurrency() {
    return symbol.contains('/') ? symbol.split('/')[0] : 'BTC';
  }

  String _getQuoteCurrency() {
    return symbol.contains('/') ? symbol.split('/')[1] : 'USD';
  }
}

class TradeEntry {
  const TradeEntry({
    required this.price,
    required this.amount,
    required this.timestamp,
    required this.isBuy,
  });

  final double price;
  final double amount;
  final DateTime timestamp;
  final bool isBuy;
}
