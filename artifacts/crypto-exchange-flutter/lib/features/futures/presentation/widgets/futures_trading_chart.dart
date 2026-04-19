import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../chart/domain/entities/chart_entity.dart';
import '../../../trade/presentation/widgets/trading_chart_canvas.dart';
import '../bloc/futures_chart_bloc.dart';
import '../bloc/futures_chart_event.dart';
import '../bloc/futures_chart_state.dart';

class FuturesTradingChart extends StatefulWidget {
  const FuturesTradingChart({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  State<FuturesTradingChart> createState() => _FuturesTradingChartState();
}

class _FuturesTradingChartState extends State<FuturesTradingChart> {
  late FuturesChartBloc _chartBloc;

  @override
  void initState() {
    super.initState();
    _chartBloc = getIt<FuturesChartBloc>()
      ..add(FuturesChartInitialized(symbol: widget.symbol));
  }

  @override
  void didUpdateWidget(FuturesTradingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      // Symbol changed, reset the chart bloc with new symbol
      _chartBloc.add(FuturesChartReset());
      _chartBloc.add(FuturesChartInitialized(symbol: widget.symbol));
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
      child: BlocBuilder<FuturesChartBloc, FuturesChartState>(
        builder: (context, state) {
          dev.log('📈 FUTURES_CHART: Building with state: ${state.runtimeType}');

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
                if (state is FuturesChartExpanded) ...[
                  const SizedBox(height: 8),
                  _buildTimeframeSelector(context, state),
                  const SizedBox(height: 8),
                  _buildExpandedChart(context, state),
                  const SizedBox(height: 12),
                ] else if (state is FuturesChartError) ...[
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

  Widget _buildChartHeader(BuildContext context, FuturesChartState state) {
    final isExpanded = state is FuturesChartExpanded;
    final isLoading = state is FuturesChartLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Just show the symbol name without "Chart" text
          Icon(
            Icons.candlestick_chart,
            color: context.textSecondary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            widget.symbol,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // Show price info when expanded
          if (state is FuturesChartExpanded) ...[
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
                    context.read<FuturesChartBloc>().add(
                          const FuturesChartExpansionToggled(),
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

  Widget _buildTimeframeSelector(
      BuildContext context, FuturesChartExpanded state) {
    // Get supported timeframes for futures trading
    final timeframes = [
      ChartTimeframe.fiveMinutes,
      ChartTimeframe.fifteenMinutes,
      ChartTimeframe.thirtyMinutes,
      ChartTimeframe.oneHour,
      ChartTimeframe.fourHours,
      ChartTimeframe.oneDay,
    ];

    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: timeframes.map((timeframe) {
            final isSelected = timeframe == state.timeframe;
            return GestureDetector(
              onTap: () {
                context.read<FuturesChartBloc>().add(
                      FuturesChartTimeframeChanged(timeframe: timeframe),
                    );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.priceUpColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        isSelected ? context.priceUpColor : context.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  timeframe.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? context.priceUpColor
                        : context.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpandedChart(BuildContext context, FuturesChartExpanded state) {
    return Container(
      height: 220, // Slightly larger for futures trading
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TradingChartCanvas(
        chartData: state.chartData,
        timeframe: state.timeframe,
        currentPrice: state.currentPrice,
        changePercent: state.changePercent,
      ),
    );
  }

  Widget _buildErrorChart(BuildContext context, FuturesChartError state) {
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
              'Futures Chart Error',
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
