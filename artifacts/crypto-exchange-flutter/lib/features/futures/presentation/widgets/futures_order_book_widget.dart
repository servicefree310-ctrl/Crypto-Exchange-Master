import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../injection/injection.dart';
import '../bloc/futures_orderbook_bloc.dart';
import '../../../../features/trade/presentation/bloc/order_book_bloc.dart';

class FuturesOrderBookWidget extends StatefulWidget {
  const FuturesOrderBookWidget({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  State<FuturesOrderBookWidget> createState() => _FuturesOrderBookWidgetState();
}

class _FuturesOrderBookWidgetState extends State<FuturesOrderBookWidget> {
  late FuturesOrderBookBloc _bloc;
  int _selectedDepth = 5; // Default depth

  @override
  void initState() {
    super.initState();
    _bloc = getIt<FuturesOrderBookBloc>()
      ..add(FuturesOrderBookConnectRequested(symbol: widget.symbol));
  }

  @override
  void didUpdateWidget(covariant FuturesOrderBookWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _bloc.add(FuturesOrderBookDisconnectRequested());
      _bloc.add(FuturesOrderBookConnectRequested(symbol: widget.symbol));
    }
  }

  @override
  void dispose() {
    _bloc.add(FuturesOrderBookDisconnectRequested());
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with depth selector
            _buildHeader(context),
            // Order book content
            BlocBuilder<FuturesOrderBookBloc, FuturesOrderBookState>(
              builder: (context, state) {
                if (state is FuturesOrderBookError) {
                  return _buildErrorState(context, state.message);
                }

                return _buildOrderBook(
                  context,
                  state is FuturesOrderBookLoaded ? state.orderBookData : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Order Book',
            style: context.bodyXS.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Current price display
          BlocBuilder<FuturesOrderBookBloc, FuturesOrderBookState>(
            builder: (context, state) {
              if (state is FuturesOrderBookLoaded) {
                final data = state.orderBookData;
                final hasPrice = data.midPrice != null && data.midPrice! > 0;
                final priceDirection = hasPrice &&
                    data.buyOrders.isNotEmpty &&
                    data.sellOrders.isNotEmpty &&
                    data.midPrice! > data.buyOrders.first.price;

                return Row(
                  children: [
                    if (hasPrice) ...[
                      Icon(
                        priceDirection
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 10,
                        color: priceDirection
                            ? context.priceUpColor
                            : context.priceDownColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        PriceFormatter.formatPrice(data.midPrice!),
                        style: context.bodyXS.copyWith(
                          color: priceDirection
                              ? context.priceUpColor
                              : context.priceDownColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Depth selector
          Container(
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [5, 6, 7].map((depth) {
                final isSelected = depth == _selectedDepth;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDepth = depth;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.priceUpColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      depth.toString(),
                      style: context.bodyXS.copyWith(
                        color: isSelected
                            ? context.priceUpColor
                            : context.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBook(BuildContext context, OrderBookData? data) {
    // Get orders based on selected depth
    final sellOrders = data?.sellOrders.isNotEmpty == true
        ? data!.sellOrders.take(_selectedDepth).toList()
        : List.generate(_selectedDepth,
            (_) => const OrderBookEntry(price: 0, quantity: 0, total: 0));

    final buyOrders = data?.buyOrders.isNotEmpty == true
        ? data!.buyOrders.take(_selectedDepth).toList()
        : List.generate(_selectedDepth,
            (_) => const OrderBookEntry(price: 0, quantity: 0, total: 0));

    // Calculate max total for depth visualization
    final allOrders = [...sellOrders, ...buyOrders];
    final maxTotal = allOrders
        .where((order) => order.total > 0)
        .fold<double>(0, (max, order) => order.total > max ? order.total : max);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Column headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Asks header
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Price',
                        style: context.bodyXS.copyWith(
                          color: context.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Total',
                        textAlign: TextAlign.right,
                        style: context.bodyXS.copyWith(
                          color: context.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Middle divider space
              const SizedBox(width: 16),
              // Bids header
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total',
                        style: context.bodyXS.copyWith(
                          color: context.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Price',
                        textAlign: TextAlign.right,
                        style: context.bodyXS.copyWith(
                          color: context.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Orders rows
        ...List.generate(_selectedDepth, (index) {
          final sellOrder =
              index < sellOrders.length ? sellOrders[index] : null;
          final buyOrder = index < buyOrders.length ? buyOrders[index] : null;

          return Container(
            height: 20,
            margin: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                // Sell order (left side)
                Expanded(
                  child: _buildHorizontalOrderSide(
                    context,
                    sellOrder ??
                        const OrderBookEntry(price: 0, quantity: 0, total: 0),
                    context.priceDownColor,
                    true,
                    maxTotal,
                  ),
                ),
                // Middle divider space
                const SizedBox(width: 16),
                // Buy order (right side)
                Expanded(
                  child: _buildHorizontalOrderSide(
                    context,
                    buyOrder ??
                        const OrderBookEntry(price: 0, quantity: 0, total: 0),
                    context.priceUpColor,
                    false,
                    maxTotal,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildHorizontalOrderSide(
    BuildContext context,
    OrderBookEntry order,
    Color priceColor,
    bool isSell,
    double maxTotal,
  ) {
    final hasData = order.price > 0;
    final depthPercentage = maxTotal > 0 ? (order.total / maxTotal) : 0.0;

    return Stack(
      children: [
        // Depth visualization bar
        if (hasData)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: FractionallySizedBox(
              alignment: isSell ? Alignment.centerRight : Alignment.centerLeft,
              widthFactor: depthPercentage * 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: priceColor.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        // Order data
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              if (isSell) ...[
                // Price on left for sells
                Expanded(
                  child: Text(
                    hasData ? PriceFormatter.formatPrice(order.price) : '---',
                    style: context.bodyXS.copyWith(
                      color: hasData ? priceColor : context.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                // Total on right for sells
                Expanded(
                  child: Text(
                    hasData ? order.total.toStringAsFixed(2) : '---',
                    textAlign: TextAlign.right,
                    style: context.bodyXS.copyWith(
                      color:
                          hasData ? context.textPrimary : context.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ] else ...[
                // Total on left for buys
                Expanded(
                  child: Text(
                    hasData ? order.total.toStringAsFixed(2) : '---',
                    style: context.bodyXS.copyWith(
                      color:
                          hasData ? context.textPrimary : context.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
                // Price on right for buys
                Expanded(
                  child: Text(
                    hasData ? PriceFormatter.formatPrice(order.price) : '---',
                    textAlign: TextAlign.right,
                    style: context.bodyXS.copyWith(
                      color: hasData ? priceColor : context.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: context.priceDownColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Order book error',
            style: context.bodyS.copyWith(
              color: context.priceDownColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: context.bodyXS.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
