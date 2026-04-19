import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/trading_chart_bloc.dart';
import 'trading_chart_timeframe_selector.dart';
import 'trading_chart_canvas.dart';

class TradingChart extends StatefulWidget {
  final String symbol;

  const TradingChart({
    super.key,
    required this.symbol,
  });

  @override
  State<TradingChart> createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart> {
  late TradingChartBloc _chartBloc;

  @override
  void initState() {
    super.initState();
    _chartBloc = getIt<TradingChartBloc>()
      ..add(TradingChartInitialized(symbol: widget.symbol));
  }

  @override
  void didUpdateWidget(TradingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      // Symbol changed, reset the chart bloc with new symbol
      _chartBloc.add(TradingChartReset());
      _chartBloc.add(TradingChartInitialized(symbol: widget.symbol));
    }
  }

  @override
  void dispose() {
    _chartBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chartBloc,
      child: BlocBuilder<TradingChartBloc, TradingChartState>(
        builder: (context, state) {
          dev.log('📈 TRADING_CHART: Building with state: ${state.runtimeType}');

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            color: context.theme.scaffoldBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chart header with controls
                _buildChartHeader(context, state),

                // Chart content area - only show when expanded
                if (state is TradingChartExpanded) ...[
                  const SizedBox(height: 8),
                  _buildExpandedChart(context, state),
                  const SizedBox(height: 12),
                ] else if (state is TradingChartLoading) ...[
                  const SizedBox(height: 8),
                  _buildLoadingChart(context),
                  const SizedBox(height: 12),
                ] else if (state is TradingChartError) ...[
                  const SizedBox(height: 8),
                  _buildErrorChart(context, state),
                  const SizedBox(height: 12),
                ],

                // Bottom divider
                _buildDivider(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context, TradingChartState state) {
    final isExpanded = state is TradingChartExpanded;
    final isLoading = state is TradingChartLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.candlestick_chart,
            color: context.textSecondary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '${widget.symbol} Chart',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // Show price info when expanded
          if (state is TradingChartExpanded) ...[
            Text(
              '\$${state.currentPrice.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: state.changePercent >= 0
                    ? context.priceUpColor
                    : context.priceDownColor,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              '(${state.changePercent >= 0 ? '+' : ''}${state.changePercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                fontSize: 10,
                color: state.changePercent >= 0
                    ? context.priceUpColor
                    : context.priceDownColor,
              ),
            ),
            const SizedBox(width: 8),
          ],

          GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    context.read<TradingChartBloc>().add(
                          const TradingChartExpansionToggled(),
                        );
                  },
            child: Row(
              children: [
                if (isLoading)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(context.textSecondary),
                    ),
                  )
                else
                  Text(
                    isExpanded ? 'Collapse' : 'Expand',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                const SizedBox(width: 4),
                if (!isLoading)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: context.textSecondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedChart(BuildContext context, TradingChartExpanded state) {
    return Container(
      height: 170, // Fixed height for trading page
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Chart canvas - full height
          TradingChartCanvas(
            chartData: state.chartData,
            timeframe: state.timeframe,
            currentPrice: state.currentPrice,
            changePercent: state.changePercent,
          ),

          // Timeframe selector overlay - positioned at bottom
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
              child: TradingChartTimeframeSelector(
                currentTimeframe: state.timeframe,
                onTimeframeChanged: (timeframe) {
                  dev.log(
                      '📈 TRADING_CHART: Timeframe changed to: ${timeframe.displayName}');
                  context.read<TradingChartBloc>().add(
                        TradingChartTimeframeChanged(timeframe: timeframe),
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingChart(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: context.priceUpColor,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading chart data...',
              style: TextStyle(
                color: context.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorChart(BuildContext context, TradingChartError state) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.priceDownColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Chart Error',
              style: TextStyle(
                color: context.priceDownColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.message,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 0.5,
          color: context.borderColor,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
