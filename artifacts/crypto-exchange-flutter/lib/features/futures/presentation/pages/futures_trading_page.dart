import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../injection/injection.dart';
import '../widgets/futures_trading_chart.dart';
import '../widgets/futures_trading_form.dart';
import '../bloc/futures_header_bloc.dart';
import '../bloc/futures_header_state.dart';
import '../bloc/futures_form_bloc.dart';
import '../bloc/futures_positions_bloc.dart';
import '../bloc/futures_orderbook_bloc.dart';
import '../bloc/futures_header_event.dart';
import '../widgets/futures_header.dart';
import '../widgets/futures_order_book_widget.dart';
import '../bloc/futures_orders_bloc.dart';

/// Futures Trading Page that uses futures-specific BLoCs and data sources
class FuturesTradingPage extends StatefulWidget {
  const FuturesTradingPage({
    super.key,
    this.symbol,
    this.marketData,
    this.initialAction,
  });

  final String? symbol;
  final dynamic marketData;
  final String? initialAction;

  @override
  State<FuturesTradingPage> createState() => _FuturesTradingPageState();
}

class _FuturesTradingPageState extends State<FuturesTradingPage> {
  late String? selectedSymbol;

  @override
  void initState() {
    super.initState();
    selectedSymbol =
        widget.symbol; // Can be null, will use first available market

    // Note: Portrait orientation is enforced globally in main.dart
    // No need to set it again here
  }

  @override
  void dispose() {
    // Note: Portrait orientation is maintained globally
    // No need to restore it here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<FuturesHeaderBloc>()
                ..add(FuturesHeaderInitialized(symbol: selectedSymbol)),
            ),
            BlocProvider(
              create: (context) => getIt<FuturesFormBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<FuturesPositionsBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<FuturesOrderBookBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<FuturesOrdersBloc>(),
            ),
          ],
          child: BlocConsumer<FuturesHeaderBloc, FuturesHeaderState>(
            // Listen to state changes but don't rebuild the entire page
            listenWhen: (previous, current) {
              // Only listen when transitioning from one loaded state to another
              return previous is FuturesHeaderLoaded &&
                  current is FuturesHeaderLoaded &&
                  previous.symbol != current.symbol;
            },
            listener: (context, state) {
              if (state is FuturesHeaderLoaded &&
                  selectedSymbol != state.symbol) {
                setState(() {
                  selectedSymbol = state.symbol;
                });

                // Update other blocs with the new symbol
                context.read<FuturesPositionsBloc>().add(
                      FuturesPositionsLoadRequested(symbol: state.symbol),
                    );
                context.read<FuturesOrderBookBloc>().add(
                      FuturesOrderBookConnectRequested(symbol: state.symbol),
                    );
                context.read<FuturesOrdersBloc>().add(
                      FuturesOrdersLoadRequested(symbol: state.symbol),
                    );
              }
            },
            // Build only when necessary
            buildWhen: (previous, current) {
              // Rebuild only when transitioning to/from error states or initial loading
              return (previous is! FuturesHeaderLoaded &&
                      current is FuturesHeaderLoaded) ||
                  (previous is FuturesHeaderLoaded &&
                      current is! FuturesHeaderLoaded) ||
                  (current is FuturesHeaderNoMarket ||
                      current is FuturesHeaderError);
            },
            builder: (context, headerState) {
              return Column(
                children: [
                  // Futures Header
                  const FuturesHeader(),

                  // Trading Content
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (headerState is FuturesHeaderNoMarket ||
                            headerState is FuturesHeaderError ||
                            headerState is FuturesHeaderInitial) {
                          if (headerState is FuturesHeaderInitial) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const FuturesHeaderShimmer(),
                                  const SizedBox(height: 16),
                                  const FuturesChartShimmer(),
                                  const SizedBox(height: 16),
                                  const FuturesTradingFormShimmer(),
                                ],
                              ),
                            );
                          } else if (headerState is FuturesHeaderError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: context.priceDownColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading futures data',
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    headerState.message,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: context.textSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No futures markets available',
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }

                        // Get the current symbol from header state or use the selected one
                        final currentSymbol = headerState is FuturesHeaderLoaded
                            ? headerState.symbol
                            : (selectedSymbol ?? 'BTC/USDT');

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // Chart (reuse existing)
                              FuturesTradingChart(symbol: currentSymbol),

                              // Order book + form
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  // Use horizontal layout for tablets, vertical for phones
                                  final isTablet = constraints.maxWidth > 600;

                                  if (isTablet) {
                                    // Tablet layout - side by side
                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Order book (left)
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 400,
                                                maxHeight: 600,
                                              ),
                                              child: FuturesOrderBookWidget(
                                                symbol: currentSymbol,
                                              ),
                                            ),
                                          ),
                                          // Trading form (right)
                                          Expanded(
                                            flex: 3,
                                            child: FuturesTradingForm(
                                              symbol: currentSymbol,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // Phone layout - stacked vertically
                                    return Column(
                                      children: [
                                        // Order book - takes natural height
                                        FuturesOrderBookWidget(
                                          symbol: currentSymbol,
                                        ),
                                        const SizedBox(height: 8),
                                        // Trading form - takes natural height
                                        FuturesTradingForm(
                                          symbol: currentSymbol,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),

                              // Bottom tabs for positions and orders
                              SizedBox(
                                height: 300,
                                child: _buildFuturesBottomTabs(currentSymbol),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFuturesBottomTabs(String currentSymbol) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              labelColor: context.textPrimary,
              unselectedLabelColor: context.textSecondary,
              indicatorColor: context.priceUpColor,
              tabs: const [
                Tab(text: 'Positions'),
                Tab(text: 'Orders'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Positions tab
                BlocBuilder<FuturesPositionsBloc, FuturesPositionsState>(
                  builder: (context, state) {
                    if (state is FuturesPositionsLoading) {
                      return ShimmerList(
                        padding: const EdgeInsets.all(16),
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            const FuturesPositionCardShimmer(),
                      );
                    }

                    if (state is FuturesPositionsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading positions',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<FuturesPositionsBloc>().add(
                                    FuturesPositionsRefreshRequested(
                                        symbol: currentSymbol));
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is FuturesPositionsLoaded) {
                      if (state.positions.isEmpty) {
                        return Center(
                          child: Text(
                            'No positions found',
                            style: TextStyle(color: context.textSecondary),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.positions.length,
                        itemBuilder: (context, index) {
                          final position = state.positions[index];
                          return Card(
                            child: ListTile(
                              title: Text(position.symbol),
                              subtitle: Text('Size: ${position.amount}'),
                              trailing: Text(
                                position.side.toUpperCase(),
                                style: TextStyle(
                                  color: position.side == 'long'
                                      ? context.priceUpColor
                                      : context.priceDownColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),

                // Orders tab
                BlocBuilder<FuturesOrdersBloc, FuturesOrdersState>(
                  builder: (context, state) {
                    // Initialize load on first build
                    if (state is FuturesOrdersInitial) {
                      context.read<FuturesOrdersBloc>().add(
                            FuturesOrdersLoadRequested(symbol: currentSymbol),
                          );
                      return ShimmerList(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder: (context, index) =>
                            const FuturesOrderCardShimmer(),
                      );
                    }

                    if (state is FuturesOrdersLoading) {
                      return ShimmerList(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder: (context, index) =>
                            const FuturesOrderCardShimmer(),
                      );
                    }

                    if (state is FuturesOrdersError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading orders',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<FuturesOrdersBloc>().add(
                                    FuturesOrdersRefreshRequested(
                                        symbol: currentSymbol));
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is FuturesOrdersLoaded) {
                      // Show error/success messages
                      if (state.error != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error!),
                              backgroundColor: context.priceDownColor,
                            ),
                          );
                        });
                      }

                      if (state.successMessage != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.successMessage!),
                              backgroundColor: context.priceUpColor,
                            ),
                          );
                        });
                      }

                      return Column(
                        children: [
                          // Filter chips
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterChip(
                                  context,
                                  'All',
                                  state.filter == OrderStatusFilter.all,
                                  () => context.read<FuturesOrdersBloc>().add(
                                        const FuturesOrdersFilterChanged(
                                          OrderStatusFilter.all,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context,
                                  'Open',
                                  state.filter == OrderStatusFilter.open,
                                  () => context.read<FuturesOrdersBloc>().add(
                                        const FuturesOrdersFilterChanged(
                                          OrderStatusFilter.open,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context,
                                  'Filled',
                                  state.filter == OrderStatusFilter.filled,
                                  () => context.read<FuturesOrdersBloc>().add(
                                        const FuturesOrdersFilterChanged(
                                          OrderStatusFilter.filled,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context,
                                  'Cancelled',
                                  state.filter == OrderStatusFilter.cancelled,
                                  () => context.read<FuturesOrdersBloc>().add(
                                        const FuturesOrdersFilterChanged(
                                          OrderStatusFilter.cancelled,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Orders list
                          Expanded(
                            child: state.orders.isEmpty
                                ? Center(
                                    child: Text(
                                      'No orders found',
                                      style: TextStyle(
                                          color: context.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.orders.length,
                                    itemBuilder: (context, index) {
                                      final order = state.orders[index];
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(order.symbol),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getOrderStatusColor(
                                                          context, order.status)
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  order.status,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getOrderStatusColor(
                                                        context, order.status),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${order.side.toUpperCase()} ${order.type.toUpperCase()}',
                                                    style: TextStyle(
                                                      color: order.side ==
                                                              'LONG'
                                                          ? context.priceUpColor
                                                          : context
                                                              .priceDownColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Size: ${order.amount}',
                                                    style: context.bodyXS,
                                                  ),
                                                ],
                                              ),
                                              ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Price: ${order.price}',
                                                style: context.bodyXS
                                                    .copyWith(
                                                        color: context
                                                            .textSecondary),
                                              ),
                                            ],
                                            ],
                                          ),
                                          trailing: order.status == 'OPEN'
                                              ? state.cancellingOrderId ==
                                                      order.id
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : IconButton(
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: context
                                                            .textSecondary,
                                                      ),
                                                      onPressed: () {
                                                        // Show confirmation dialog
                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (dialogContext) =>
                                                                  AlertDialog(
                                                            title: const Text(
                                                                'Cancel Order'),
                                                            content: Text(
                                                              'Are you sure you want to cancel this ${order.side.toUpperCase()} order for ${order.amount} ${order.symbol}?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(),
                                                                child:
                                                                    const Text(
                                                                        'No'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop();
                                                                  context
                                                                      .read<
                                                                          FuturesOrdersBloc>()
                                                                      .add(
                                                                        FuturesOrderCancelRequested(
                                                                          orderId:
                                                                              order.id,
                                                                          symbol:
                                                                              currentSymbol,
                                                                          createdAt:
                                                                              order.createdAt,
                                                                        ),
                                                                      );
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      context
                                                                          .priceDownColor,
                                                                ),
                                                                child: const Text(
                                                                    'Yes, Cancel'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.priceUpColor.withValues(alpha: 0.2)
              : context.borderColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.priceUpColor : context.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? context.priceUpColor : context.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getOrderStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return context.theme.colorScheme.primary;
      case 'FILLED':
        return context.priceUpColor;
      case 'CANCELLED':
      case 'REJECTED':
        return context.priceDownColor;
      case 'PARTIALLY_FILLED':
        return context.theme.colorScheme.primary;
      default:
        return context.textSecondary;
    }
  }
}
