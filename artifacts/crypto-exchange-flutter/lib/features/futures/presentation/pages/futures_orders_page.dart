import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/shimmer_loading.dart';
import '../bloc/futures_orders_bloc.dart';

class FuturesOrdersPage extends StatelessWidget {
  const FuturesOrdersPage({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<FuturesOrdersBloc>()
        ..add(FuturesOrdersLoadRequested(symbol: symbol)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$symbol Orders'),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Filter chips
            BlocBuilder<FuturesOrdersBloc, FuturesOrdersState>(
              builder: (context, state) {
                if (state is FuturesOrdersLoaded) {
                  return Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: Text('All (${state.allOrders.length})'),
                          selected: state.filter == OrderStatusFilter.all,
                          onSelected: (_) =>
                              context.read<FuturesOrdersBloc>().add(
                                    const FuturesOrdersFilterChanged(
                                        OrderStatusFilter.all),
                                  ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Open (${state.openCount})'),
                          selected: state.filter == OrderStatusFilter.open,
                          onSelected: (_) =>
                              context.read<FuturesOrdersBloc>().add(
                                    const FuturesOrdersFilterChanged(
                                        OrderStatusFilter.open),
                                  ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Filled (${state.filledCount})'),
                          selected: state.filter == OrderStatusFilter.filled,
                          onSelected: (_) =>
                              context.read<FuturesOrdersBloc>().add(
                                    const FuturesOrdersFilterChanged(
                                        OrderStatusFilter.filled),
                                  ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Cancelled (${state.cancelledCount})'),
                          selected: state.filter == OrderStatusFilter.cancelled,
                          onSelected: (_) =>
                              context.read<FuturesOrdersBloc>().add(
                                    const FuturesOrdersFilterChanged(
                                        OrderStatusFilter.cancelled),
                                  ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox(height: 56);
              },
            ),
            // Orders list
            Expanded(
              child: BlocConsumer<FuturesOrdersBloc, FuturesOrdersState>(
                listener: (context, state) {
                  if (state is FuturesOrdersLoaded) {
                    if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    if (state.successMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.successMessage!),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is FuturesOrdersLoading) {
                    return ShimmerList(
                      itemCount: 5,
                      itemBuilder: (context, index) =>
                          const FuturesOrderCardShimmer(),
                    );
                  } else if (state is FuturesOrdersError) {
                    return app_error.ErrorWidget(
                      message: state.failure.message,
                      onRetry: () => context.read<FuturesOrdersBloc>().add(
                            FuturesOrdersLoadRequested(symbol: symbol),
                          ),
                    );
                  } else if (state is FuturesOrdersLoaded) {
                    final orders = state.filteredOrders;

                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: context.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.filter == OrderStatusFilter.all
                                  ? 'No Orders Found'
                                  : 'No ${state.filter.name.toUpperCase()} Orders',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.filter == OrderStatusFilter.all
                                  ? 'Your order history will appear here'
                                  : 'No orders match the selected filter',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.5),
                                  ),
                            ),
                            if (state.filter != OrderStatusFilter.all) ...[
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () =>
                                    context.read<FuturesOrdersBloc>().add(
                                          const FuturesOrdersFilterChanged(
                                              OrderStatusFilter.all),
                                        ),
                                child: const Text('Show All Orders'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FuturesOrdersBloc>().add(
                              FuturesOrdersRefreshRequested(symbol: symbol),
                            );
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isCancelling =
                              state.cancellingOrderId == order.id;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  order.symbol,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: order.side == 'BUY'
                                                        ? Colors.green
                                                            .withValues(alpha: 0.1)
                                                        : Colors.red
                                                            .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    order.side,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: order.side == 'BUY'
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    order.type,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(order.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStatusChip(order.status, context),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildOrderDetail(
                                        'Amount',
                                        order.amount.toStringAsFixed(4),
                                        context,
                                      ),
                                      _buildOrderDetail(
                                        'Price',
                                        order.price > 0
                                            ? '\$${order.price.toStringAsFixed(2)}'
                                            : 'Market',
                                        context,
                                      ),
                                      _buildOrderDetail(
                                        'Leverage',
                                        '${order.leverage.toInt()}x',
                                        context,
                                      ),
                                    ],
                                  ),
                                  if (order.status == 'OPEN' &&
                                      !isCancelling) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _showCancelConfirmation(
                                          context,
                                          order.id,
                                          symbol,
                                          order.createdAt,
                                        ),
                                        icon: const Icon(Icons.close, size: 16),
                                        label: const Text('Cancel Order'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isCancelling) ...[
                                    const SizedBox(height: 12),
                                    const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, BuildContext context) {
    Color color;
    Color backgroundColor;

    switch (status) {
      case 'OPEN':
        color = Colors.blue;
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        break;
      case 'FILLED':
        color = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'CANCELLED':
      case 'REJECTED':
        color = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        break;
      default:
        color = Colors.grey;
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showCancelConfirmation(
    BuildContext context,
    String orderId,
    String symbol,
    DateTime createdAt,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FuturesOrdersBloc>().add(
                    FuturesOrderCancelRequested(
                      orderId: orderId,
                      symbol: symbol,
                      createdAt: createdAt,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}
