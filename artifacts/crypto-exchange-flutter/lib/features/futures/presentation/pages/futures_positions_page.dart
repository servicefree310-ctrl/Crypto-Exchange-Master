import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/shimmer_loading.dart';
import '../bloc/futures_positions_bloc.dart';

class FuturesPositionsPage extends StatelessWidget {
  const FuturesPositionsPage({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<FuturesPositionsBloc>()
        ..add(FuturesPositionsLoadRequested(symbol: symbol)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$symbol Futures Positions'),
          elevation: 0,
        ),
        body: BlocConsumer<FuturesPositionsBloc, FuturesPositionsState>(
          listener: (context, state) {
            if (state is FuturesPositionsLoaded) {
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
            if (state is FuturesPositionsLoading) {
              return ShimmerList(
                itemCount: 3,
                itemBuilder: (context, index) =>
                    const FuturesPositionCardShimmer(),
              );
            } else if (state is FuturesPositionsError) {
              return app_error.ErrorWidget(
                message: state.failure.message,
                onRetry: () => context.read<FuturesPositionsBloc>().add(
                      FuturesPositionsLoadRequested(symbol: symbol),
                    ),
              );
            } else if (state is FuturesPositionsLoaded) {
              if (state.positions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Open Positions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start trading to open your first position',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Trading'),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FuturesPositionsBloc>().add(
                        FuturesPositionsRefreshRequested(symbol: symbol),
                      );
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: state.positions.length,
                  itemBuilder: (context, index) {
                    final position = state.positions[index];
                    final isClosing = state.closingPositionId == position.id;

                    // Calculate percentage safely
                    final percentage = position.entryPrice > 0
                        ? ((position.markPrice - position.entryPrice) /
                                position.entryPrice) *
                            100 *
                            (position.side == 'LONG' ? 1 : -1)
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            position.symbol,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: position.side == 'LONG'
                                                  ? Colors.green
                                                      .withValues(alpha: 0.1)
                                                  : Colors.red.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              position.side,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: position.side == 'LONG'
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Size: ${position.amount.toStringAsFixed(4)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isClosing)
                                  const CircularProgressIndicator()
                                else
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.red,
                                    onPressed: () => _showCloseConfirmation(
                                      context,
                                      position.id,
                                      symbol,
                                      position.side,
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn(
                                  'Entry Price',
                                  '\$${position.entryPrice.toStringAsFixed(2)}',
                                ),
                                _buildInfoColumn(
                                  'Mark Price',
                                  '\$${position.markPrice.toStringAsFixed(2)}',
                                ),
                                _buildInfoColumn(
                                  'Liq. Price',
                                  position.liquidationPrice > 0
                                      ? '\$${position.liquidationPrice.toStringAsFixed(2)}'
                                      : '--',
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildPnLInfo(
                                    'PnL',
                                    position.unrealisedPnl,
                                    ' USDT',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPnLInfo(
                                    'ROI',
                                    percentage,
                                    '%',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.speed,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Leverage: ${position.leverage}x',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPnLInfo(String label, double value, String suffix) {
    final isProfit = value >= 0;
    final color = isProfit ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            '${isProfit ? '+' : ''}${value.toStringAsFixed(2)}$suffix',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCloseConfirmation(
    BuildContext context,
    String positionId,
    String symbol,
    String side,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close Position'),
        content: const Text(
            'Are you sure you want to close this position? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FuturesPositionsBloc>().add(
                    FuturesPositionCloseRequested(
                      positionId: positionId,
                      symbol: symbol,
                      side: side,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Close Position'),
          ),
        ],
      ),
    );
  }
}
