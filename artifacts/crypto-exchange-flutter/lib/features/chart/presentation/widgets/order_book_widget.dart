import 'dart:math' as math;
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/chart_bloc.dart';

class OrderBookWidget extends StatelessWidget {
  const OrderBookWidget({
    super.key,
    required this.symbol,
    this.orderBookData,
    this.isLandscape = false,
  });

  final String symbol;
  final List<OrderBookEntry>? orderBookData;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        List<OrderBookEntry> asks = [];
        List<OrderBookEntry> bids = [];

        if (state is ChartLoaded) {
          // Convert DepthDataPoint to OrderBookEntry for asks
          asks = state.chartData.asksData
              .map((depth) => OrderBookEntry(
                    price: depth.price,
                    size: depth.volume,
                    isBid: false,
                  ))
              .toList();

          // Convert DepthDataPoint to OrderBookEntry for bids
          bids = state.chartData.bidsData
              .map((depth) => OrderBookEntry(
                    price: depth.price,
                    size: depth.volume,
                    isBid: true,
                  ))
              .toList();
        } else {
          dev.log(
              '📊 ORDER_BOOK_WIDGET: State is not ChartLoaded: ${state.runtimeType}');
        }

        return isLandscape
            ? _buildLandscapeOrderBook(context, asks, bids)
            : _buildPortraitOrderBook(context, asks, bids);
      },
    );
  }

  Widget _buildLandscapeOrderBook(BuildContext context,
      List<OrderBookEntry> asks, List<OrderBookEntry> bids) {
    // Show all entries received from WebSocket for landscape
    const entriesToShow = 15; // Show all 15 entries for asks and 15 for bids
    const entryHeight =
        18.0; // Smaller height for landscape to fit more entries

    // Use real data if available, otherwise show empty lists
    final displayAsks = asks.isNotEmpty
        ? asks.take(entriesToShow).toList().reversed.toList()
        : <OrderBookEntry>[];
    final displayBids = bids.isNotEmpty
        ? bids.take(entriesToShow).toList()
        : <OrderBookEntry>[];

    // Calculate max sizes for depth visualization
    final maxAskSize = displayAsks.isNotEmpty
        ? displayAsks.map((e) => e.size).reduce((a, b) => a > b ? a : b)
        : 1.0;
    final maxBidSize = displayBids.isNotEmpty
        ? displayBids.map((e) => e.size).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Column(
      children: [
        // Header with spread info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              Text(
                'Order Book',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: context.inputBackground,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _calculateSpread(displayAsks, displayBids),
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Column headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
          ),
          child: Row(
            children: [
              // Asks side headers (LEFT)
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'ASKS',
                      style: TextStyle(
                        color: context.priceDownColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Price (${_getQuoteCurrency()})',
                        style: TextStyle(
                          color: context.textTertiary,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'Size',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Center divider
              Container(
                width: 1,
                height: 20,
                color: context.borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // Bids side headers (RIGHT)
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'BIDS',
                      style: TextStyle(
                        color: context.priceUpColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Price (${_getQuoteCurrency()})',
                        style: TextStyle(
                          color: context.textTertiary,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'Size',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Order book content - Scrollable for landscape
        Expanded(
          child: Row(
            children: [
              // Asks side (LEFT) - Scrollable
              Expanded(
                child: ListView.builder(
                  itemCount: math.max(entriesToShow, displayAsks.length),
                  itemBuilder: (context, index) {
                    if (index < displayAsks.length) {
                      final ask = displayAsks[index];
                      return _buildLandscapeOrderBookRow(
                        context,
                        price: ask.price,
                        size: ask.size,
                        maxSize: maxAskSize,
                        isAsk: true,
                      );
                    } else {
                      return _buildEmptyLandscapeOrderBookRow(context);
                    }
                  },
                ),
              ),

              // Center divider
              Container(
                width: 1,
                color: context.borderColor,
              ),

              // Bids side (RIGHT) - Scrollable
              Expanded(
                child: ListView.builder(
                  itemCount: math.max(entriesToShow, displayBids.length),
                  itemBuilder: (context, index) {
                    if (index < displayBids.length) {
                      final bid = displayBids[index];
                      return _buildLandscapeOrderBookRow(
                        context,
                        price: bid.price,
                        size: bid.size,
                        maxSize: maxBidSize,
                        isAsk: false,
                      );
                    } else {
                      return _buildEmptyLandscapeOrderBookRow(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitOrderBook(BuildContext context,
      List<OrderBookEntry> asks, List<OrderBookEntry> bids) {
    // Show all entries received from WebSocket
    const entriesToShow = 15; // Show all 15 entries for asks and 15 for bids
    const entryHeight = 20.0; // Smaller height to fit more entries

    // Use real data if available, otherwise show empty lists which will show fallback UI
    final displayAsks = asks.isNotEmpty
        ? asks.take(entriesToShow).toList().reversed.toList()
        : <OrderBookEntry>[];
    final displayBids = bids.isNotEmpty
        ? bids.take(entriesToShow).toList()
        : <OrderBookEntry>[];

    // Calculate max sizes for depth visualization
    final maxAskSize = displayAsks.isNotEmpty
        ? displayAsks.map((e) => e.size).reduce((a, b) => a > b ? a : b)
        : 1.0;
    final maxBidSize = displayBids.isNotEmpty
        ? displayBids.map((e) => e.size).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with spread info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Text(
                'Order Book',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.inputBackground,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _calculateSpread(displayAsks, displayBids),
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Column headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
          ),
          child: Row(
            children: [
              // Asks side headers (LEFT)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASKS',
                      style: TextStyle(
                        color: context.priceDownColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Price (${_getQuoteCurrency()})',
                            style: TextStyle(
                              color: context.textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Size',
                            style: TextStyle(
                              color: context.textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Center divider
              Container(
                width: 1,
                height: 30,
                color: context.borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // Bids side headers (RIGHT)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIDS',
                      style: TextStyle(
                        color: context.priceUpColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Price (${_getQuoteCurrency()})',
                            style: TextStyle(
                              color: context.textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Size',
                            style: TextStyle(
                              color: context.textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Fighting bar - ABOVE the order book data
        _buildFightingBar(context, displayAsks, displayBids),

        // Order book content (fixed height container)
        SizedBox(
          height: entriesToShow * entryHeight,
          child: Row(
            children: [
              // Asks side (LEFT)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...displayAsks
                        .take(entriesToShow)
                        .map((ask) => _buildOrderBookRow(
                              context,
                              price: ask.price,
                              size: ask.size,
                              maxSize: maxAskSize,
                              isAsk: true,
                            )),
                    // Fill remaining space with placeholder if not enough asks
                    ...List.generate(
                      (entriesToShow - displayAsks.length)
                          .clamp(0, entriesToShow),
                      (index) => _buildEmptyOrderBookRow(context),
                    ),
                  ],
                ),
              ),

              // Center divider
              Container(
                width: 1,
                color: context.borderColor,
              ),

              // Bids side (RIGHT)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...displayBids
                        .take(entriesToShow)
                        .map((bid) => _buildOrderBookRow(
                              context,
                              price: bid.price,
                              size: bid.size,
                              maxSize: maxBidSize,
                              isAsk: false,
                            )),
                    // Fill remaining space with placeholder if not enough bids
                    ...List.generate(
                      (entriesToShow - displayBids.length)
                          .clamp(0, entriesToShow),
                      (index) => _buildEmptyOrderBookRow(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrderBookRow(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '--',
              style: TextStyle(
                color: context.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '--',
              style: TextStyle(
                color: context.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookRow(
    BuildContext context, {
    required double price,
    required double size,
    bool? isBid,
    double? maxSize,
    bool? isAsk,
  }) {
    // Support both old and new calling patterns
    final isAskOrder = isAsk ?? (isBid != null ? !isBid : false);
    final depth = maxSize != null && maxSize > 0 ? size / maxSize : 0.0;
    final color = isAskOrder ? context.priceDownColor : context.priceUpColor;

    return SizedBox(
      height: 20,
      child: Stack(
        children: [
          // Depth bar background (only show if maxSize is provided)
          if (maxSize != null)
            Positioned(
              left: isAskOrder ? null : 0,
              right: isAskOrder ? 0 : null,
              top: 0,
              bottom: 0,
              width: 100 * depth,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAskOrder
                        ? [
                            color.withValues(alpha: 0.0),
                            color.withValues(alpha: 0.3),
                          ]
                        : [
                            color.withValues(alpha: 0.3),
                            color.withValues(alpha: 0.0),
                          ],
                  ),
                ),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _formatPrice(price),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatVolume(size),
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateSpread(
      List<OrderBookEntry> asks, List<OrderBookEntry> bids) {
    if (asks.isEmpty || bids.isEmpty) {
      return 'Spread: --';
    }

    final spread =
        (asks.first.price - bids.first.price) / asks.first.price * 100;
    return 'Spread: ${spread.toStringAsFixed(2)}%';
  }

  String _getBaseCurrency() {
    return symbol.contains('/') ? symbol.split('/')[0] : 'BTC';
  }

  String _getQuoteCurrency() {
    return symbol.contains('/') ? symbol.split('/')[1] : 'USD';
  }

  String _formatPrice(double price) {
    // For very small prices (like MEME token), show more decimal places
    if (price < 0.01) {
      return price.toStringAsFixed(6);
    } else if (price < 1) {
      return price.toStringAsFixed(4);
    } else if (price < 100) {
      return price.toStringAsFixed(2);
    } else {
      return price.toStringAsFixed(0);
    }
  }

  String _formatVolume(double volume) {
    // Format volume with appropriate precision
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else if (volume >= 1) {
      return volume.toStringAsFixed(1);
    } else {
      return volume.toStringAsFixed(4);
    }
  }

  Widget _buildVerticalFightingBar(BuildContext context,
      List<OrderBookEntry> asks, List<OrderBookEntry> bids) {
    // Calculate total volumes
    final totalAskVolume = asks.fold<double>(0, (sum, ask) => sum + ask.size);
    final totalBidVolume = bids.fold<double>(0, (sum, bid) => sum + bid.size);
    final totalVolume = totalAskVolume + totalBidVolume;

    // Calculate percentages - default to 50/50 when no data is available
    final askPercentage =
        totalVolume > 0 ? (totalAskVolume / totalVolume) : 0.5;
    final bidPercentage =
        totalVolume > 0 ? (totalBidVolume / totalVolume) : 0.5;

    return Container(
      height: 40, // Smaller height for landscape
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Percentage labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ASKS ${(askPercentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: context.priceDownColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(bidPercentage * 100).toStringAsFixed(1)}% BIDS',
                  style: TextStyle(
                    color: context.priceUpColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Fighting bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Asks side
                    Expanded(
                      flex: (askPercentage * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.priceDownColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            bottomLeft: Radius.circular(7),
                          ),
                        ),
                      ),
                    ),
                    // Bids side
                    Expanded(
                      flex: (bidPercentage * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.priceUpColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(7),
                            bottomRight: Radius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeOrderBookRow(
    BuildContext context, {
    required double price,
    required double size,
    required double maxSize,
    required bool isAsk,
  }) {
    final depth = maxSize > 0 ? size / maxSize : 0.0;
    final color = isAsk ? context.priceDownColor : context.priceUpColor;

    return SizedBox(
      height: 20, // Smaller height for landscape
      child: Stack(
        children: [
          // Depth bar background
          Positioned(
            left: isAsk ? null : 0,
            right: isAsk ? 0 : null,
            top: 0,
            bottom: 0,
            width: 80 * depth, // Smaller width for landscape
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAsk
                      ? [
                          color.withValues(alpha: 0.0),
                          color.withValues(alpha: 0.3),
                        ]
                      : [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.0),
                        ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _formatPrice(price),
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatVolume(size),
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLandscapeOrderBookRow(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '--',
              style: TextStyle(
                color: context.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '--',
              style: TextStyle(
                color: context.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFightingBar(BuildContext context, List<OrderBookEntry> asks,
      List<OrderBookEntry> bids) {
    // Calculate total volumes
    final totalAskVolume = asks.fold<double>(0, (sum, ask) => sum + ask.size);
    final totalBidVolume = bids.fold<double>(0, (sum, bid) => sum + bid.size);
    final totalVolume = totalAskVolume + totalBidVolume;

    // Calculate percentages - default to 50/50 when no data is available
    final askPercentage =
        totalVolume > 0 ? (totalAskVolume / totalVolume) : 0.5;
    final bidPercentage =
        totalVolume > 0 ? (totalBidVolume / totalVolume) : 0.5;

    return Container(
      height: 32, // Reduced height from 55 to 32
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          // Compact percentage labels
          SizedBox(
            height: 14,
            child: Row(
              children: [
                // Ask percentage
                Text(
                  '${(askPercentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: context.priceDownColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Central divider with icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: context.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: context.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: context.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Bid percentage
                Text(
                  '${(bidPercentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: context.priceUpColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Sleek fighting bar with central divider
          SizedBox(
            height: 14,
            child: Row(
              children: [
                // Asks side
                Expanded(
                  flex: (askPercentage * 100).round().clamp(1, 99),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.priceDownColor.withValues(alpha: 0.8),
                          context.priceDownColor,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                    ),
                  ),
                ),
                // Central divider line
                Container(
                  width: 2,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.textPrimary.withValues(alpha: 0.1),
                        context.textPrimary.withValues(alpha: 0.3),
                        context.textPrimary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Bids side
                Expanded(
                  flex: (bidPercentage * 100).round().clamp(1, 99),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.priceUpColor,
                          context.priceUpColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderBookEntry {
  const OrderBookEntry({
    required this.price,
    required this.size,
    required this.isBid,
  });

  final double price;
  final double size;
  final bool isBid;
}
