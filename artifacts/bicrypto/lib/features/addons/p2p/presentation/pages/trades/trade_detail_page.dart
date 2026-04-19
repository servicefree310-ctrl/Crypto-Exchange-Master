import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/theme/p2p_color_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/trades/trade_detail_bloc.dart';
import '../../bloc/trades/trade_detail_event.dart';
import '../../bloc/trades/trade_detail_state.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

/// P2P Trade Detail Page (KuCoin-style compact design)
/// Shows timeline, escrow info and available actions.
class TradeDetailPage extends StatefulWidget {
  const TradeDetailPage({super.key, required this.tradeId});

  final String tradeId;

  @override
  State<TradeDetailPage> createState() => _TradeDetailPageState();
}

class _TradeDetailPageState extends State<TradeDetailPage> {
  @override
  void initState() {
    super.initState();
    // Trigger load
    context.read<TradeDetailBloc>().add(TradeDetailRequested(widget.tradeId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          context.colors.surface,
      appBar: AppBar(
        backgroundColor:
            context.colors.surface,
        elevation: 0,
        title: const Text('Trade Details'),
      ),
      body: BlocBuilder<TradeDetailBloc, TradeDetailState>(
        builder: (context, state) {
          if (state is TradeDetailLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }
          if (state is TradeDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: context.colors.error),
                  const SizedBox(height: 12),
                  Text(
                    state.failure.message,
                    style: TextStyle(
                        color: isDark
                            ? context.textPrimary
                            : context.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TradeDetailBloc>()
                        .add(const TradeDetailRetryRequested()),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }
          if (state is TradeDetailLoaded || state is TradeActionSuccess) {
            final trade = state is TradeDetailLoaded
                ? state.trade
                : (state as TradeActionSuccess).trade;
            return Stack(
              children: [
                _buildDetail(trade, isDark),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildActionBar(trade, isDark),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(P2PTradeEntity trade, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(trade, isDark)),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildTimeline(trade, isDark)),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildEscrowInfo(trade, isDark)),
        SliverToBoxAdapter(child: const SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(P2PTradeEntity trade, bool isDark) {
    final isBuy = trade.isBuyTrade;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBuy
              ? [context.buyColor, context.buyColorLight]
              : [context.sellColor, context.sellColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBuy ? 'BUYING ${trade.currency}' : 'SELLING ${trade.currency}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Amount: ${trade.amount.toStringAsFixed(4)}',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              Text(
                'Total: \${trade.fiatAmount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${_statusToText(trade.status)}',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(P2PTradeEntity trade, bool isDark) {
    final timeline = trade.timeline ?? [];
    if (timeline.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Timeline',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        ...timeline.map((e) {
          final description = e['description'] ?? e['status'] ?? '';
          DateTime? time;
          final rawTime = e['time'];
          if (rawTime is DateTime) {
            time = rawTime;
          } else if (rawTime is String) {
            time = DateTime.tryParse(rawTime);
          }
          return ListTile(
            leading: Icon(Icons.check_circle,
                size: 20, color: context.colors.primary),
            title: Text(description.toString()),
            subtitle: time != null ? Text(_formatTime(time)) : null,
          );
        }),
      ],
    );
  }

  Widget _buildEscrowInfo(P2PTradeEntity trade, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escrow',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 8),
            _infoRow('Escrow Amount',
                '${trade.escrowAmount?.toStringAsFixed(4) ?? trade.amount.toStringAsFixed(4)} ${trade.currency}'),
            if (trade.escrowFee != null)
              _infoRow('Escrow Fee', '\${trade.escrowFee!.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  )),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
        ],
      ),
    );
  }

  String _statusToText(P2PTradeStatus status) {
    switch (status) {
      case P2PTradeStatus.pending:
        return 'Pending';
      case P2PTradeStatus.inProgress:
        return 'In Progress';
      case P2PTradeStatus.paymentSent:
        return 'Payment Sent';
      case P2PTradeStatus.completed:
        return 'Completed';
      case P2PTradeStatus.cancelled:
        return 'Cancelled';
      case P2PTradeStatus.disputed:
        return 'Disputed';
      case P2PTradeStatus.expired:
        return 'Expired';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActionBar(P2PTradeEntity trade, bool isDark) {
    List<Widget> buttons = [];

    void addBtn(String label, VoidCallback onTap, {Color? bg, Color? fg}) {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg ?? context.colors.primary,
              foregroundColor: fg ?? Colors.white,
              elevation: 0,
            ),
            child: Text(label),
          ),
        ),
      );
    }

    switch (trade.status) {
      case P2PTradeStatus.pending:
        addBtn('Cancel', () => _showCancelDialog());
        break;
      case P2PTradeStatus.inProgress:
        addBtn('Confirm Payment', () => _showConfirmDialog());
        addBtn('Cancel', () => _showCancelDialog());
        break;
      case P2PTradeStatus.paymentSent:
        addBtn('Release Escrow', () => _showReleaseDialog());
        addBtn('Dispute', () => _showDisputeDialog());
        break;
      case P2PTradeStatus.completed:
        // Optional review
        break;
      case P2PTradeStatus.cancelled:
      case P2PTradeStatus.disputed:
      case P2PTradeStatus.expired:
        // no actions
        break;
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + 16),
      // add bottom safe padding
      color: context.colors.surface,
      child: Row(
        children: [
          ...buttons.expand((w) sync* {
            yield w;
            yield const SizedBox(width: 12);
          }).toList()
            ..removeLast(),
        ],
      ),
    );
  }

  // Dialog helpers
  void _showConfirmDialog() {
    final refController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: TextField(
          controller: refController,
          decoration: const InputDecoration(hintText: 'Payment reference'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<TradeDetailBloc>().add(TradeConfirmPaymentRequested(
                    paymentReference: refController.text,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Trade'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'Reason'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              context
                  .read<TradeDetailBloc>()
                  .add(TradeCancelRequested(reason: reasonCtrl.text));
              Navigator.pop(context);
            },
            child: const Text('Cancel Trade'),
          )
        ],
      ),
    );
  }

  void _showReleaseDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Release Escrow'),
        content: const Text('Are you sure you want to release the escrow?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              context
                  .read<TradeDetailBloc>()
                  .add(const TradeReleaseEscrowRequested());
              Navigator.pop(context);
            },
            child: const Text('Release'),
          )
        ],
      ),
    );
  }

  void _showDisputeDialog() {
    final reasonCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Open Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(hintText: 'Reason'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(hintText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              context.read<TradeDetailBloc>().add(TradeDisputeRequested(
                    reason: reasonCtrl.text,
                    description: descCtrl.text,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }
}
