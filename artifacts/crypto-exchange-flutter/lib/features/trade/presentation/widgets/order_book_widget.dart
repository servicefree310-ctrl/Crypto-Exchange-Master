import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../injection/injection.dart';
import '../bloc/order_book_bloc.dart';

class OrderBookWidget extends StatefulWidget {
  final String symbol;
  final double? expectedHeight;

  const OrderBookWidget({
    super.key,
    required this.symbol,
    this.expectedHeight,
  });

  @override
  State<OrderBookWidget> createState() => _OrderBookWidgetState();
}

class _OrderBookWidgetState extends State<OrderBookWidget> {
  late OrderBookBloc _orderBookBloc;

  @override
  void initState() {
    super.initState();
    _orderBookBloc = getIt<OrderBookBloc>()
      ..add(OrderBookInitialized(symbol: widget.symbol));
  }

  @override
  void didUpdateWidget(OrderBookWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      // Symbol changed, update the order book
      _orderBookBloc.add(OrderBookSymbolChanged(symbol: widget.symbol));
    }
  }

  @override
  void dispose() {
    dev.log(
        '🧹 ORDER_BOOK_WIDGET: Disposing order book widget for ${widget.symbol}');
    // Send cleanup event to preserve shared connection
    _orderBookBloc.add(const OrderBookCleanupRequested());
    _orderBookBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBookBloc,
      child: BlocBuilder<OrderBookBloc, OrderBookState>(
        builder: (context, state) {
          return Container(
            color: context.theme.scaffoldBackgroundColor,
            child: _buildOrderBookContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildOrderBookContent(BuildContext context, OrderBookState state) {
    if (state is OrderBookLoading) {
      return _buildSkeletonOrderBook(context);
    }

    if (state is OrderBookError) {
      return Center(
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
              'Error loading order book',
              style: TextStyle(
                color: context.priceDownColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _orderBookBloc.add(
                  OrderBookRefreshRequested(symbol: widget.symbol),
                );
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is OrderBookLoaded) {
      return _buildLoadedOrderBook(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSkeletonOrderBook(BuildContext context) {
    return Column(
      children: [
        // Top padding to match trading form
        const SizedBox(height: 5),

        // Header skeleton
        Container(
          height: 36, // Increased height to accommodate two lines
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '(${_getQuoteCurrency()})',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 7,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '(${_getBaseCurrency()})',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 7,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Skeleton sell orders
        ...List.generate(5,
            (index) => _buildPlaceholderOrderRow(context, OrderBookSide.sell)),

        // Separator
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.textTertiary.withValues(alpha: 0.1),
                context.textTertiary.withValues(alpha: 0.3),
                context.textTertiary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),

        // Current price skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: PriceFormatter.formatPriceWidget(
                  null, // Loading state
                  availableWidth: constraints.maxWidth,
                  fontSize: 14.0,
                  color: context.textPrimary,
                  isLoading: true,
                ),
              );
            },
          ),
        ),

        // Separator
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.textTertiary.withValues(alpha: 0.1),
                context.textTertiary.withValues(alpha: 0.3),
                context.textTertiary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),

        // Skeleton buy orders
        ...List.generate(5,
            (index) => _buildPlaceholderOrderRow(context, OrderBookSide.buy)),
      ],
    );
  }

  Widget _buildLoadedOrderBook(BuildContext context, OrderBookLoaded state) {
    final orderBookData = state.orderBookData;
    // Use ticker price first, fallback to mid price from order book, then null
    final currentPrice = state.currentPrice ?? orderBookData.midPrice;

    // Limit entries based on available height
    final dynamicOrderBookData = _limitEntriesForHeight(orderBookData);

    // Calculate max total for volume bar calculation
    final allTotals = [
      ...dynamicOrderBookData.sellOrders.map((e) => e.total),
      ...dynamicOrderBookData.buyOrders.map((e) => e.total),
    ];
    final maxTotal =
        allTotals.isNotEmpty ? allTotals.reduce((a, b) => a > b ? a : b) : 1.0;

    // Determine how many placeholder entries to show
    const minEntriesPerSide = 5; // Show at least 5 entries per side
    final sellOrdersToShow = dynamicOrderBookData.sellOrders.isNotEmpty
        ? dynamicOrderBookData.sellOrders
        : [];
    final buyOrdersToShow = dynamicOrderBookData.buyOrders.isNotEmpty
        ? dynamicOrderBookData.buyOrders
        : [];

    return Column(
      children: [
        // Top padding to match trading form
        const SizedBox(height: 5),

        // Simple header
        Container(
          height: 36, // Increased height to accommodate two lines
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8), // Match trading form radius
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '(${_getQuoteCurrency()})',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 7,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '(${_getBaseCurrency()})',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 7,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sell orders (red) - displayed in normal order (lowest price first)
        ...sellOrdersToShow.map(
          (entry) => _buildOrderRowWithVolumeBar(
            context,
            entry,
            OrderBookSide.sell,
            maxTotal,
          ),
        ),
        // Fill remaining space with placeholders if not enough sell orders
        ...List.generate(
          (minEntriesPerSide - sellOrdersToShow.length)
              .clamp(0, minEntriesPerSide),
          (index) => _buildPlaceholderOrderRow(context, OrderBookSide.sell),
        ),

        // Subtle separator
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.textTertiary.withValues(alpha: 0.1),
                context.textTertiary.withValues(alpha: 0.3),
                context.textTertiary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),

        // Current price row
        _buildCurrentPriceRow(context, currentPrice, state.currentPriceColor),

        // Subtle separator
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.textTertiary.withValues(alpha: 0.1),
                context.textTertiary.withValues(alpha: 0.3),
                context.textTertiary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),

        // Buy orders (green) - displayed in normal order (highest price first)
        ...buyOrdersToShow.map(
          (entry) => _buildOrderRowWithVolumeBar(
            context,
            entry,
            OrderBookSide.buy,
            maxTotal,
          ),
        ),
        // Fill remaining space with placeholders if not enough buy orders
        ...List.generate(
          (minEntriesPerSide - buyOrdersToShow.length)
              .clamp(0, minEntriesPerSide),
          (index) => _buildPlaceholderOrderRow(context, OrderBookSide.buy),
        ),
      ],
    );
  }

  /// Limit order book entries based on available height
  OrderBookData _limitEntriesForHeight(OrderBookData originalData) {
    // Use expectedHeight if provided, otherwise use a reasonable default
    final targetHeight =
        widget.expectedHeight ?? 300.0; // Fallback to reasonable default

    if (targetHeight <= 0 ||
        originalData.sellOrders.isEmpty && originalData.buyOrders.isEmpty) {
      return originalData; // Return original data if no height constraint or empty data
    }

    // Calculate space used by fixed elements (updated for smaller sizes)
    const topPadding = 5.0; // Top padding
    const headerHeight = 38.0; // Header container + margins (36 + 2)
    const currentPriceHeight = 30.0; // Current price + padding
    const separatorHeight = 6.0; // Two separators (1px each + margins)
    const entryHeight = 24.0; // Entry height without margins

    final fixedHeight =
        topPadding + headerHeight + currentPriceHeight + separatorHeight;
    final availableForRows = targetHeight - fixedHeight;

    // Calculate how many rows we can fit (ensure even split for sell/buy)
    final maxRows = (availableForRows / entryHeight).floor();
    final entriesPerSide =
        ((maxRows / 2).floor()).clamp(3, 10); // Min 3, Max 10 per side

    // Limit entries based on calculated count
    final limitedSellOrders =
        originalData.sellOrders.take(entriesPerSide).toList();
    final limitedBuyOrders =
        originalData.buyOrders.take(entriesPerSide).toList();

    return OrderBookData(
      sellOrders: limitedSellOrders,
      buyOrders: limitedBuyOrders,
      spread: originalData.spread,
      midPrice: originalData.midPrice,
    );
  }

  Widget _buildOrderRowWithVolumeBar(
    BuildContext context,
    OrderBookEntry entry,
    OrderBookSide side,
    double maxTotal,
  ) {
    final depth = maxTotal > 0 ? entry.total / maxTotal : 0.0;
    final color = side.getColor(context);

    return Container(
      height: 24, // Slightly more compact
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          // Depth indicator bar – grows proportionally with total size
          Align(
            alignment: side == OrderBookSide.buy
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: FractionallySizedBox(
              alignment: side == OrderBookSide.buy
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: depth.clamp(0.0, 1.0),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          // Row content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.formattedPrice,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatTotal(entry.total),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
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

  Widget _buildCurrentPriceRow(
      BuildContext context, double? currentPrice, Color? priceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          return Center(
            child: PriceFormatter.formatPriceWidget(
              currentPrice,
              availableWidth: availableWidth,
              fontSize: 14.0,
              color: priceColor ??
                  context.textPrimary, // Use dynamic color or theme default
              fontWeight: FontWeight.bold,
              isLoading: currentPrice == null,
              enableColorAnimation:
                  true, // Enable color animation for price changes
            ),
          );
        },
      ),
    );
  }

  /// Build placeholder row with "--" when no order book data available
  Widget _buildPlaceholderOrderRow(BuildContext context, OrderBookSide side) {
    final color = side
        .getColor(context)
        .withValues(alpha: 0.3); // Dimmed color for placeholders

    return Container(
      height: 24, // Same height as real entries
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '--',
                style: TextStyle(
                  color: context.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '--',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBaseCurrency() {
    return widget.symbol.contains('/') ? widget.symbol.split('/')[0] : 'FT';
  }

  String _getQuoteCurrency() {
    return widget.symbol.contains('/') ? widget.symbol.split('/')[1] : 'USDT';
  }

  String _formatTotal(double total) {
    if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(2)}K';
    }
    return total.toStringAsFixed(4);
  }
}
