import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/widgets/app_error_widget.dart';
import '../../../../../../core/widgets/app_loading_indicator.dart';
import '../bloc/order_detail/order_detail_bloc.dart';
import '../bloc/order_detail/order_detail_event.dart';
import '../bloc/order_detail/order_detail_state.dart';
import '../../domain/entities/order_entity.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OrderDetailBloc>()
        ..add(LoadOrderDetailRequested(orderId: orderId)),
      child: const _OrderDetailView(),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Order Details'),
      ),
      body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is OrderDetailError) {
            return Center(
              child: AppErrorWidget(
                message: state.message,
                onRetry: () {
                  final bloc = context.read<OrderDetailBloc>();
                  bloc.add(LoadOrderDetailRequested(orderId: bloc.orderId));
                },
              ),
            );
          }

          if (state is OrderDetailLoaded) {
            final order = state.order;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info Card
                  _OrderInfoCard(order: order),
                  const SizedBox(height: 16),

                  // Order Items
                  _OrderItemsCard(order: order),
                  const SizedBox(height: 16),

                  // Order Summary
                  _OrderSummaryCard(order: order),

                  if (order.shippingAddress != null) ...[
                    const SizedBox(height: 16),
                    _ShippingAddressCard(order: order),
                  ],

                  const SizedBox(height: 24),
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

class _OrderInfoCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'Order #${order.orderNumber}',
            style: context.h6,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMMM dd, yyyy at hh:mm a').format(order.createdAt),
                style: context.bodyS.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatusBadge(status: order.status),
        ],
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'Order Items',
            style: context.labelL.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => _OrderItemRow(item: item)),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemEntity item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 60,
            height: 60,
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
                        size: 30,
                        color: context.colors.onSurface.withValues(alpha: 0.3),
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: context.colors.onSurface.withValues(alpha: 0.3),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: context.labelM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                  style: context.bodyS.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (item.product.type == 'DOWNLOADABLE') ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Digital Product',
                      style: context.labelS.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Price
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: context.labelM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold(0.0, (sum, item) => sum + item.total);
    final shipping = order.shipping?.cost ?? 0.0;

    return Container(
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
          Text(
            'Order Summary',
            style: context.labelL.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          if (shipping > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Shipping',
              value: '\$${shipping.toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Total',
            value:
                '\$${order.totalAmount.toStringAsFixed(2)} ${order.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? context.labelL.copyWith(fontWeight: FontWeight.w600)
              : context.bodyM,
        ),
        Text(
          value,
          style: isTotal
              ? context.labelL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                )
              : context.bodyM,
        ),
      ],
    );
  }
}

class _ShippingAddressCard extends StatelessWidget {
  final OrderEntity order;

  const _ShippingAddressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final address = order.shippingAddress!;

    return Container(
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
          Text(
            'Shipping Address',
            style: context.labelL.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            address.fullName,
            style: context.labelM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            style: context.bodyM.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (address.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address.phone,
              style: context.bodyM.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
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
            status.toString().split('.').last.toUpperCase(),
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
