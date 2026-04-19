import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import 'order_book_widget.dart';
import 'trading_info_widget.dart';
import 'recent_trades_widget.dart';
import '../../../trade/presentation/widgets/trading_form_widget.dart';

class FullscreenTradingPanel extends StatefulWidget {
  const FullscreenTradingPanel({
    super.key,
    required this.symbol,
    required this.currentPrice,
    required this.showOrderBook,
    required this.showTradingInfo,
    required this.showRecentTrades,
    required this.onOrderBookToggled,
    required this.onTradingInfoToggled,
    required this.onRecentTradesToggled,
  });

  final String symbol;
  final String currentPrice;
  final bool showOrderBook;
  final bool showTradingInfo;
  final bool showRecentTrades;
  final VoidCallback onOrderBookToggled;
  final VoidCallback onTradingInfoToggled;
  final VoidCallback onRecentTradesToggled;

  @override
  State<FullscreenTradingPanel> createState() => _FullscreenTradingPanelState();
}

class _FullscreenTradingPanelState extends State<FullscreenTradingPanel>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top action row (toggle buttons)
        _buildToggleHeader(context),

        // Main content area
        Expanded(
          child: widget.showOrderBook
              ? OrderBookWidget(
                  symbol: widget.symbol,
                  isLandscape: true,
                )
              : widget.showTradingInfo
                  ? TradingInfoWidget(
                      symbol: widget.symbol,
                      currentPrice: widget.currentPrice,
                    )
                  : widget.showRecentTrades
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: RecentTradesWidget(symbol: widget.symbol),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TradingFormWidget(symbol: widget.symbol),
                        ),
        ),
      ],
    );
  }

  Widget _buildToggleHeader(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(
              context,
              icon: Icons.currency_exchange,
              isActive: !widget.showOrderBook &&
                  !widget.showTradingInfo &&
                  !widget.showRecentTrades,
              onTap: () {
                // Return to trading form by disabling others
                if (widget.showOrderBook) widget.onOrderBookToggled();
                if (widget.showTradingInfo) widget.onTradingInfoToggled();
                if (widget.showRecentTrades) widget.onRecentTradesToggled();
              },
              tooltip: 'Buy / Sell',
            ),
            const SizedBox(width: 8),
            _buildToggleButton(
              context,
              icon: Icons.list_alt,
              isActive: widget.showOrderBook,
              onTap: widget.onOrderBookToggled,
              tooltip: 'Order Book',
            ),
            const SizedBox(width: 8),
            _buildToggleButton(
              context,
              icon: Icons.swap_horiz,
              isActive: widget.showRecentTrades,
              onTap: widget.onRecentTradesToggled,
              tooltip: 'Recent Trades',
            ),
            const SizedBox(width: 8),
            _buildToggleButton(
              context,
              icon: Icons.info_outline,
              isActive: widget.showTradingInfo,
              onTap: widget.onTradingInfoToggled,
              tooltip: 'Trading Info',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? context.priceUpColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? context.priceUpColor : context.borderColor,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? context.priceUpColor : context.textSecondary,
            size: 16,
          ),
        ),
      ),
    );
  }
}
