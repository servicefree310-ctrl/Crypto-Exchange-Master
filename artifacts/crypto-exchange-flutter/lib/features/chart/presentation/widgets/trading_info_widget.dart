import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/chart_bloc.dart';

class TradingInfoWidget extends StatelessWidget {
  const TradingInfoWidget({
    super.key,
    required this.symbol,
    required this.currentPrice,
    this.tradingInfoData,
  });

  final String symbol;
  final String currentPrice;
  final TradingInfoData? tradingInfoData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        String high24h = '--';
        String low24h = '--';
        String volume24h = '--';
        String change24h = '--';
        String bid = '--';
        String ask = '--';
        String spread = '--';

        if (state is ChartLoaded) {
          final chartData = state.chartData;
          final tickerData = state.tickerData;

          // Use chart data for 24h stats
          high24h = chartData.high24h > 0
              ? chartData.high24h.toStringAsFixed(2)
              : '--';
          low24h =
              chartData.low24h > 0 ? chartData.low24h.toStringAsFixed(2) : '--';
          volume24h = chartData.volume24h > 0
              ? '${chartData.volume24h.toStringAsFixed(2)} ${_getBaseCurrency()}'
              : '--';
          change24h = chartData.changePercent != 0
              ? '${chartData.changePercent >= 0 ? '+' : ''}${chartData.changePercent.toStringAsFixed(2)}%'
              : '--';

          // Use ticker data for bid/ask if available
          if (tickerData != null) {
            // Note: Assuming ticker data might have bid/ask in the future
            // For now, we'll calculate from orderbook data
            final asks = chartData.asksData;
            final bids = chartData.bidsData;

            if (asks.isNotEmpty) {
              ask = asks.first.price.toStringAsFixed(2);
            }
            if (bids.isNotEmpty) {
              bid = bids.first.price.toStringAsFixed(2);
            }

            // Calculate spread
            if (asks.isNotEmpty && bids.isNotEmpty) {
              final spreadValue = (asks.first.price - bids.first.price) /
                  asks.first.price *
                  100;
              spread = '${spreadValue.toStringAsFixed(2)}%';
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(context, '24h Stats', [
                _buildInfoRow(context, 'High', high24h),
                _buildInfoRow(context, 'Low', low24h),
                _buildInfoRow(context, 'Volume', volume24h),
                _buildInfoRow(context, 'Change', change24h),
              ]),
              const SizedBox(height: 20),
              _buildInfoSection(context, 'Market Info', [
                _buildInfoRow(context, 'Last Price', currentPrice),
                _buildInfoRow(context, 'Bid', bid),
                _buildInfoRow(context, 'Ask', ask),
                _buildInfoRow(context, 'Spread', spread),
              ]),
              const SizedBox(height: 20),
              _buildInfoSection(context, 'Trading Rules', [
                _buildInfoRow(context, 'Min Order',
                    tradingInfoData?.minOrder ?? '0.001 ${_getBaseCurrency()}'),
                _buildInfoRow(
                    context, 'Tick Size', tradingInfoData?.tickSize ?? '0.01'),
                _buildInfoRow(
                    context, 'Maker Fee', tradingInfoData?.makerFee ?? '0.1%'),
                _buildInfoRow(
                    context, 'Taker Fee', tradingInfoData?.takerFee ?? '0.15%'),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _getValueColor(context, label, value),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(BuildContext context, String label, String value) {
    // Color code specific values for better UX
    if (label == 'Change' && value.startsWith('+')) {
      return context.priceUpColor; // Green for positive change
    } else if (label == 'Change' && value.startsWith('-')) {
      return context.priceDownColor; // Red for negative change
    } else if (label == 'Last Price') {
      return context.priceUpColor; // Green for current price
    }
    return context.textPrimary; // Default white
  }

  String _getBaseCurrency() {
    return symbol.contains('/') ? symbol.split('/')[0] : 'BTC';
  }

  String _getQuoteCurrency() {
    return symbol.contains('/') ? symbol.split('/')[1] : 'USD';
  }
}

class TradingInfoData {
  const TradingInfoData({
    this.high24h,
    this.low24h,
    this.volume24h,
    this.change24h,
    this.bid,
    this.ask,
    this.spread,
    this.minOrder,
    this.tickSize,
    this.makerFee,
    this.takerFee,
  });

  final String? high24h;
  final String? low24h;
  final String? volume24h;
  final String? change24h;
  final String? bid;
  final String? ask;
  final String? spread;
  final String? minOrder;
  final String? tickSize;
  final String? makerFee;
  final String? takerFee;
}
