import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';

import '../../domain/entities/order_entity.dart';
import '../bloc/order_tabs_bloc.dart';

class TradingBottomTabs extends StatefulWidget {
  final String symbol;

  const TradingBottomTabs({
    super.key,
    required this.symbol,
  });

  @override
  State<TradingBottomTabs> createState() => _TradingBottomTabsState();
}

class _TradingBottomTabsState extends State<TradingBottomTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderTabsBloc _tabsBloc;
  int _selectedIndex = 0;
  bool _historyFetched = false;

  @override
  void initState() {
    super.initState();

    _tabsBloc = getIt<OrderTabsBloc>();
    // Load open orders immediately
    _tabsBloc.add(FetchOpenOrders(symbol: widget.symbol));
    _tabsBloc.add(InitializeOrderRealtime(symbol: widget.symbol));

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });

        // Fetch history only once when the History tab is first selected
        if (_selectedIndex == 1 && !_historyFetched) {
          _tabsBloc.add(FetchOrderHistory(symbol: widget.symbol));
          _historyFetched = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tabsBloc,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: context.borderColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Tab bar
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
                controller: _tabController,
                indicatorColor:
                    context.priceUpColor, // Match trading form green
                indicatorWeight: 2,
                labelColor: context.textPrimary,
                unselectedLabelColor: context.textSecondary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Open Orders'),
                  Tab(text: 'History'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  BlocBuilder<OrderTabsBloc, OrderTabsState>(
                    builder: (context, state) {
                      if (state is OrderTabsLoading ||
                          state is OrderTabsInitial) {
                        return const _KeepAlive(child: _OrdersShimmer());
                      } else if (state is OrderTabsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: context.priceDownColor),
                          ),
                        );
                      } else if (state is OpenOrdersLoaded) {
                        return _KeepAlive(
                            child: _buildOrdersList(context, state.orders,
                                emptyMessage: 'No open orders',
                                allowCancel: true));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  BlocBuilder<OrderTabsBloc, OrderTabsState>(
                    builder: (context, state) {
                      if (state is OrderTabsLoading ||
                          state is OrderTabsInitial) {
                        return const _KeepAlive(child: _OrdersShimmer());
                      } else if (state is OrderTabsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: context.priceDownColor),
                          ),
                        );
                      } else if (state is OrderHistoryLoaded) {
                        return _KeepAlive(
                            child: _buildOrdersList(context, state.orders,
                                emptyMessage: 'No order history',
                                allowCancel: false));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<OrderEntity> orders, {
    required String emptyMessage,
    required bool allowCancel,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: context.textTertiary, fontSize: 12),
        ),
      );
    }

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: context.borderColor,
      ),
      itemBuilder: (_, index) {
        final o = orders[index];
        return ListTile(
          dense: true,
          title: Text(
            '${o.side.toUpperCase()} ${o.amount} @ ${o.price}',
            style: TextStyle(
              color: o.side.toLowerCase() == 'buy'
                  ? context.priceUpColor
                  : context.priceDownColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            o.createdAt.toLocal().toString(),
            style: TextStyle(color: context.textTertiary, fontSize: 10),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                o.status,
                style: TextStyle(color: context.textSecondary, fontSize: 11),
              ),
              if (allowCancel) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _tabsBloc.add(
                      CancelOpenOrder(orderId: o.id, symbol: widget.symbol),
                    );
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: context.priceDownColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}

// Simple list shimmer placeholder
class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Row(
          children: [
            // Colored bar to mimic side (buy/sell)
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: context.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: context.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 12,
              width: 40,
              decoration: BoxDecoration(
                color: context.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Keep-alive wrapper for each tab view
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin<_KeepAlive> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
