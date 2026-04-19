import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/animated_price.dart';
import '../bloc/trading_header_bloc.dart';
import 'trading_pair_side_menu.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../market/domain/entities/market_entity.dart';
import '../../../market/domain/entities/ticker_entity.dart';
import '../../../chart/presentation/pages/chart_page.dart';

class TradingHeader extends StatelessWidget {
  final String symbol;

  const TradingHeader({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: BlocBuilder<TradingHeaderBloc, TradingHeaderState>(
        builder: (context, state) {
          if (state is TradingHeaderLoading) {
            return _LoadingHeader(context: context);
          }

          if (state is TradingHeaderLoaded) {
            return _LoadedHeader(state: state, context: context);
          }

          if (state is TradingHeaderError) {
            return _ErrorHeader(state: state, context: context);
          }

          return _LoadingHeader(context: context);
        },
      ),
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.inputBackground,
      highlightColor: context.borderColor,
      period: const Duration(milliseconds: 1200),
      child: Row(
        children: [
          // Pair selector placeholder
          Container(
            height: 40,
            width: 120,
            decoration: BoxDecoration(
              color: context.textSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(width: 12),

          // Price placeholder expands
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: context.textSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Chart icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.textSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedHeader extends StatelessWidget {
  const _LoadedHeader({required this.state, required this.context});

  final TradingHeaderLoaded state;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    // If AI Investment selected, show simplified header
    final isAi = state.selectedType == TradingType.isolatedMargin;

    return Column(
      children: [
        if (!isAi) ...[
          // Bottom row: Pair, price, and chart icon
          Row(
            children: [
              // Pair Selector (adaptive width)
              _buildPairSelector(context),

              const SizedBox(width: 12),

              // Price section (takes remaining space)
              Expanded(
                child: _buildPriceSection(),
              ),

              const SizedBox(width: 8),

              // Chart icon only
              _buildChartButton(context),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildPairSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPairSideMenu(context),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 160),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.pairData.symbol,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: context.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final isPositive = state.pairData.changePercentage24h >= 0;
    final changeColor =
        isPositive ? context.priceUpColor : context.priceDownColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedPrice(
          symbol: state.pairData.symbol,
          price: state.pairData.price,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          decimalPlaces: 4,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTrendArrow(
              symbol: state.pairData.symbol,
              percentage: state.pairData.changePercentage24h,
              size: 12,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: AnimatedPercentage(
                symbol: state.pairData.symbol,
                percentage: state.pairData.changePercentage24h,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                showSign: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to chart page with current market data and symbol
        // This ensures the chart page gets the same data as the trading page for WebSocket reuse
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChartPage(
              symbol: state.pairData.symbol,
              marketData: _createMarketDataFromPairData(state.pairData),
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.candlestick_chart,
          color: context.priceUpColor,
          size: 20,
        ),
      ),
    );
  }

  /// Create MarketDataEntity from TradingPairData for chart navigation
  MarketDataEntity _createMarketDataFromPairData(TradingPairData pairData) {
    // Parse symbol to get currency and pair
    final symbolParts = pairData.symbol.split('/');
    final currency = symbolParts.isNotEmpty ? symbolParts[0] : 'BTC';
    final pair = symbolParts.length > 1 ? symbolParts[1] : 'USDT';

    final marketEntity = MarketEntity(
      id: pairData.symbol,
      symbol: pairData.symbol,
      currency: currency,
      pair: pair,
      isTrending: false,
      isHot: false,
      status: true,
      isEco: false,
    );

    final tickerEntity = TickerEntity(
      symbol: pairData.symbol,
      last: pairData.price,
      baseVolume: pairData.volume24h,
      quoteVolume: pairData.volume24h,
      change: pairData.change24h,
      high: pairData.high24h,
      low: pairData.low24h,
      open: pairData.price - pairData.change24h, // Approximate open price
      close: pairData.price,
      bid: pairData.price * 0.999, // Approximate bid
      ask: pairData.price * 1.001, // Approximate ask
    );

    return MarketDataEntity(
      market: marketEntity,
      ticker: tickerEntity,
    );
  }

  void _showPairSideMenu(BuildContext context) {
    // Capture the BLoC reference before showing the dialog
    final tradingHeaderBloc = context.read<TradingHeaderBloc>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Trading Pair Selector',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: TradingPairSideMenu(
            currentSymbol: state.pairData.symbol,
            onPairSelected: (symbol) {
              Navigator.of(context).pop();
              // Use the captured BLoC reference instead of trying to access it from dialog context
              tradingHeaderBloc.add(
                TradingPairChanged(symbol: symbol),
              );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }
}

class _ErrorHeader extends StatelessWidget {
  const _ErrorHeader({required this.state, required this.context});

  final TradingHeaderError state;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.priceDownColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: context.priceDownColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Error loading pair',
                style: TextStyle(
                  color: context.priceDownColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => context.read<TradingHeaderBloc>().add(
                TradingHeaderInitialized(symbol: 'BTC/USDT'),
              ),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.priceUpColor,
            foregroundColor: Colors.black,
            minimumSize: const Size(60, 32),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
