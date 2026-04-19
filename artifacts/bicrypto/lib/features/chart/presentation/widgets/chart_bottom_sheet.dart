import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import 'order_book_widget.dart';
import 'recent_trades_widget.dart';
import 'trading_info_widget.dart';

class ChartBottomSheet extends StatelessWidget {
  const ChartBottomSheet({
    super.key,
    required this.symbol,
    required this.currentPrice,
    this.showOrderBook = false,
    this.showTradingInfo = false,
    this.showRecentTrades = false,
  });

  final String symbol;
  final String currentPrice;
  final bool showOrderBook;
  final bool showTradingInfo;
  final bool showRecentTrades;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF0A0A0A)
            : context.cardBackground,
        border: Border(
          top: BorderSide(
            color: context.borderColor,
            width: 1,
          ),
        ),
      ),
      child: showOrderBook
          ? OrderBookWidget(symbol: symbol)
          : showTradingInfo
              ? TradingInfoWidget(
                  symbol: symbol,
                  currentPrice: currentPrice,
                )
              : RecentTradesWidget(symbol: symbol),
    );
  }
}
