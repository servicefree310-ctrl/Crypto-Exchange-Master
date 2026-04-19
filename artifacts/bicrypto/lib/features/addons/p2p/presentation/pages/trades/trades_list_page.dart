import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/trades/trades_bloc.dart';
import '../../bloc/trades/trades_state.dart';
import '../../bloc/trades/trades_event.dart';
import '../../bloc/trades/trade_execution_bloc.dart';
import '../../bloc/trades/trade_execution_event.dart';
import '../../bloc/trades/trade_execution_state.dart';
import '../../widgets/trades/trades_stats_card.dart';
import '../../widgets/trades/trades_filter_bar.dart';
import '../../widgets/dialogs/confirm_payment_dialog.dart';
import '../../widgets/dialogs/cancel_trade_dialog.dart';
import '../../widgets/dialogs/release_escrow_dialog.dart';
import '../../widgets/dialogs/dispute_dialog.dart';
import '../../../domain/entities/p2p_trade_entity.dart';
import '../../bloc/trades/trade_chat_bloc.dart';
import '../trades/trade_chat_page.dart';
import '../../../../../../injection/injection.dart';

/// KuCoin-style trades list page with status tabs and filtering
class TradesListPage extends StatefulWidget {
  const TradesListPage({super.key});

  @override
  State<TradesListPage> createState() => _TradesListPageState();
}

class _TradesListPageState extends State<TradesListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Trade status filter for API calls
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<TradesBloc>().add(const TradesRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<TradesBloc>().add(const TradesLoadMoreRequested());
    }
  }

  void _onTabChanged(int index) {
    String? status;
    switch (index) {
      case 0: // Active (all in-progress statuses)
        status = null; // Let backend handle "active" status filtering
        break;
      case 1: // Pending
        status = 'PENDING';
        break;
      case 2: // Completed
        status = 'COMPLETED';
        break;
      case 3: // Disputed
        status = 'DISPUTED';
        break;
    }

    setState(() {
      _selectedStatus = status;
    });

    context.read<TradesBloc>().add(TradesFilterChanged(status));
  }

  void _onRefresh() {
    context.read<TradesBloc>().add(const TradesRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TradeExecutionBloc>(),
      child: BlocListener<TradeExecutionBloc, TradeExecutionState>(
        listener: (context, state) {
          if (state is TradeExecutionSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.priceUpColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refresh trades list
            context.read<TradesBloc>().add(const TradesRequested(refresh: true));
          } else if (state is TradeExecutionError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text(
          'My Trades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.textPrimary),
            onPressed: () {
              // TODO: Implement trade search
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: context.textPrimary),
            onPressed: () {
              // TODO: Implement more options menu
            },
          ),
        ],
      ),
      body: BlocBuilder<TradesBloc, TradesState>(
        builder: (context, state) {
          if (state is TradesLoading && state.isRefresh) {
            return Center(
              child: CircularProgressIndicator(
                color: context.colors.primary,
              ),
            );
          }

          if (state is TradesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: context.colors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.failure.message,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TradesLoaded) {
            final response = state.response;

            return RefreshIndicator(
              onRefresh: () async => _onRefresh(),
              color: context.colors.primary,
              child: Column(
                children: [
                  // Stats Overview Card
                  TradesStatsCard(stats: response.tradeStats),

                  // Filter Bar
                  TradesFilterBar(
                    onFilterChanged: (filters) {
                      // Handle additional filtering if needed
                    },
                    onSortChanged: (sortBy, ascending) {
                      // TODO: Implement sorting
                    },
                  ),

                  // Tabs
                  Container(
                    color: context.colors.surface,
                    child: TabBar(
                      controller: _tabController,
                      onTap: _onTabChanged,
                      indicatorColor: context.colors.primary,
                      indicatorWeight: 2,
                      labelColor: context.colors.primary,
                      unselectedLabelColor: context.textSecondary,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        _buildTab('Active', response.activeTrades.length),
                        _buildTab('Pending', response.pendingTrades.length),
                        _buildTab('Completed', response.completedTrades.length),
                        _buildTab('Disputed', response.disputedTrades.length),
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTradesList(response.activeTrades, 'active'),
                        _buildTradesList(response.pendingTrades, 'pending'),
                        _buildTradesList(response.completedTrades, 'completed'),
                        _buildTradesList(response.disputedTrades, 'disputed'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Initial loading state
          return Center(
            child: CircularProgressIndicator(
              color: context.colors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTradesList(List<P2PTradeEntity> trades, String listType) {
    if (trades.isEmpty) {
      return _buildEmptyState(listType);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: trades.length + 1, // +1 for loading indicator
      itemBuilder: (context, index) {
        if (index == trades.length) {
          // Loading indicator at bottom
          return BlocBuilder<TradesBloc, TradesState>(
            builder: (context, state) {
              if (state is TradesLoaded && !state.canLoadMore) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
              );
            },
          );
        }

        final trade = trades[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _TradeCard(
            trade: trade,
            onTap: () => _navigateToTradeDetail(trade.id),
            onAction: (action) => _handleTradeAction(trade, action),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String listType) {
    String title;
    String subtitle;
    IconData icon;
    String? actionText;
    VoidCallback? onAction;

    switch (listType) {
      case 'active':
        title = 'No Active Trades';
        subtitle =
            'You don\'t have any active trades at the moment. Browse offers to start trading.';
        icon = Icons.trending_up;
        actionText = 'Find Offers';
        onAction = () => context.go('/p2p/offers');
        break;
      case 'pending':
        title = 'No Pending Trades';
        subtitle = 'All your trades are either active or completed.';
        icon = Icons.hourglass_empty;
        break;
      case 'completed':
        title = 'No Completed Trades';
        subtitle =
            'Your completed trades will appear here once you finish trading.';
        icon = Icons.check_circle_outline;
        break;
      case 'disputed':
        title = 'No Disputed Trades';
        subtitle = 'Great! You don\'t have any trades in dispute.';
        icon = Icons.gavel;
        break;
      default:
        title = 'No Trades';
        subtitle = 'Your trades will appear here.';
        icon = Icons.list_alt;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: context.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
              ),
              child: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToTradeDetail(String tradeId) {
    context.go('/p2p/trades/$tradeId');
  }

  void _handleTradeAction(P2PTradeEntity trade, String action) {
    switch (action) {
      case 'confirm':
        _showConfirmPaymentDialog(trade);
        break;
      case 'cancel':
        _showCancelTradeDialog(trade);
        break;
      case 'dispute':
        _showDisputeDialog(trade);
        break;
      case 'chat':
        _openChat(trade.id);
        break;
      case 'release':
        _showReleaseEscrowDialog(trade);
        break;
    }
  }

  void _showConfirmPaymentDialog(P2PTradeEntity trade) {
    showDialog(
      context: context,
      builder: (context) => ConfirmPaymentDialog(
        trade: trade,
        onConfirm: () {
          context.read<TradeExecutionBloc>().add(
                TradeConfirmRequested(
                  tradeId: trade.id,
                  confirmationType: 'payment_sent',
                ),
              );
        },
      ),
    );
  }

  void _showCancelTradeDialog(P2PTradeEntity trade) {
    showDialog(
      context: context,
      builder: (context) => CancelTradeDialog(
        trade: trade,
        onCancel: (reason) {
          context.read<TradeExecutionBloc>().add(
                TradeCancelRequested(
                  tradeId: trade.id,
                  reason: reason,
                ),
              );
        },
      ),
    );
  }

  void _showReleaseEscrowDialog(P2PTradeEntity trade) {
    showDialog(
      context: context,
      builder: (context) => ReleaseEscrowDialog(
        trade: trade,
        onRelease: () {
          context.read<TradeExecutionBloc>().add(
                TradeEscrowReleaseRequested(tradeId: trade.id),
              );
        },
      ),
    );
  }

  void _showDisputeDialog(P2PTradeEntity trade) {
    showDialog(
      context: context,
      builder: (context) => DisputeDialog(
        trade: trade,
        onDispute: (reason, description) {
          context.read<TradeExecutionBloc>().add(
                TradeDisputeRequested(
                  tradeId: trade.id,
                  reason: reason,
                  description: description,
                ),
              );
        },
      ),
    );
  }

  void _openChat(String tradeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<TradeChatBloc>(),
          child: TradeChatPage(tradeId: tradeId),
        ),
      ),
    );
  }
}

/// Simple trade card widget for displaying trade information
class _TradeCard extends StatelessWidget {
  const _TradeCard({
    required this.trade,
    required this.onTap,
    required this.onAction,
  });

  final P2PTradeEntity trade;
  final VoidCallback onTap;
  final Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trade.isBuyTrade ? "Buying" : "Selling"} ${trade.currency}',
                  style: TextStyle(
                    color:
                        trade.isBuyTrade ? context.buyColor : context.sellColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: 12),

            // Trade details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount: ${trade.amount.toStringAsFixed(4)} ${trade.currency}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: \$${trade.fiatAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Payment: ${trade.paymentMethod ?? "N/A"}',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction('chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.colors.secondary.withValues(alpha: 0.2),
                      foregroundColor: context.colors.secondary,
                      elevation: 0,
                    ),
                    child: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary.withValues(alpha: 0.2),
                      foregroundColor: context.colors.primary,
                      elevation: 0,
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (trade.status) {
      case P2PTradeStatus.pending:
        backgroundColor = context.warningColor.withValues(alpha: 0.2);
        textColor = context.warningColor;
        statusText = 'Pending';
        break;
      case P2PTradeStatus.inProgress:
        backgroundColor = context.colors.secondary.withValues(alpha: 0.2);
        textColor = context.colors.secondary;
        statusText = 'In Progress';
        break;
      case P2PTradeStatus.paymentSent:
        backgroundColor = context.colors.secondary.withValues(alpha: 0.2);
        textColor = context.colors.secondary;
        statusText = 'Payment Sent';
        break;
      case P2PTradeStatus.completed:
        backgroundColor = context.colors.primary.withValues(alpha: 0.2);
        textColor = context.colors.primary;
        statusText = 'Completed';
        break;
      case P2PTradeStatus.cancelled:
        backgroundColor = context.textTertiary.withValues(alpha: 0.2);
        textColor = context.textTertiary;
        statusText = 'Cancelled';
        break;
      case P2PTradeStatus.disputed:
        backgroundColor = context.colors.error.withValues(alpha: 0.2);
        textColor = context.colors.error;
        statusText = 'Disputed';
        break;
      case P2PTradeStatus.expired:
        backgroundColor = context.textTertiary.withValues(alpha: 0.2);
        textColor = context.textTertiary;
        statusText = 'Expired';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
