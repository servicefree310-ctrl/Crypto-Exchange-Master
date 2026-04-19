import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/widgets/app_error_widget.dart';
import '../../../../../../core/widgets/app_loading_indicator.dart';
import '../bloc/orders/orders_bloc.dart';
import '../bloc/orders/orders_event.dart';
import '../bloc/orders/orders_state.dart';
import '../../domain/entities/order_entity.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<OrdersBloc>()..add(const LoadOrdersRequested()),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'My Orders',
          style: context.h5,
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is OrdersError) {
            return Center(
              child: AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<OrdersBloc>().add(
                        const LoadOrdersRequested(),
                      );
                },
              ),
            );
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return _EmptyOrders(context: context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersBloc>().add(
                      const LoadOrdersRequested(),
                    );
              },
              child: CustomScrollView(
                slivers: [
                  // Status Filter
                  SliverToBoxAdapter(
                    child: _StatusFilter(
                      selectedStatus: state.selectedStatus,
                      onStatusChanged: (status) {
                        context.read<OrdersBloc>().add(
                              FilterOrdersRequested(status: status),
                            );
                      },
                    ),
                  ),

                  // Orders count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${state.filteredOrders.length} ${state.filteredOrders.length == 1 ? 'order' : 'orders'}',
                        style: context.bodyM.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  // Orders List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = state.filteredOrders[index];
                        return _OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(
                                  orderId: order.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: state.filteredOrders.length,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onStatusChanged;

  const _StatusFilter({
    this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      null,
      ...OrderStatus.values,
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = status == selectedStatus;

          return FilterChip(
            label: Text(
              status == null ? 'All' : _getStatusDisplay(status),
              style: context.labelM.copyWith(
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onStatusChanged(status),
            backgroundColor: context.colors.surface,
            selectedColor: context.colors.primary,
            side: BorderSide(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.outline.withValues(alpha: 0.3),
            ),
          );
        },
      ),
    );
  }

  String _getStatusDisplay(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.closed:
        return 'Closed';
    }
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: context.labelL.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.createdAt),
                        style: context.bodyS.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 16),

              // Items preview
              ...order.items.take(2).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.product.image != null
                                  ? Image.network(
                                      item.product.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.image_outlined,
                                        size: 24,
                                        color: context.colors.onSurface
                                            .withValues(alpha: 0.3),
                                      ),
                                    )
                                  : Icon(
                                      Icons.image_outlined,
                                      size: 24,
                                      color: context.colors.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: context.labelM,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: context.bodyS.copyWith(
                                    color: context.colors.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            style: context.labelM.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (order.items.length > 2) ...[
                const SizedBox(height: 8),
                Text(
                  '+ ${order.items.length - 2} more items',
                  style: context.bodyS.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: context.labelL,
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)} ${order.currency}',
                    style: context.labelL.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context);
    final icon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: context.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.purple;
      case OrderStatus.closed:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.replay;
      case OrderStatus.closed:
        return Icons.archive;
    }
  }
}

class _EmptyOrders extends StatelessWidget {
  final BuildContext context;

  const _EmptyOrders({required this.context});

  @override
  Widget build(BuildContext rootContext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: rootContext.colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: rootContext.colors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No orders yet',
              style: rootContext.h6,
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here',
              style: rootContext.bodyM.copyWith(
                color: rootContext.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(rootContext).pop(),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
