import 'package:flutter/material.dart';
import '../../../domain/usecases/trades/get_trades_usecase.dart';

class TradesStatsCard extends StatelessWidget {
  const TradesStatsCard({
    super.key,
    required this.stats,
  });

  final P2PTradeStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trade Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Volume',
                  value: '\$${stats.totalVolume.toStringAsFixed(2)}',
                  color: const Color(0xFF24CE85),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Completion Rate',
                  value: '${(stats.successRate * 100).toStringAsFixed(1)}%',
                  color: const Color(0xFF007AFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Active Trades',
                  value: stats.activeCount.toString(),
                  color: const Color(0xFFFF9500),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Avg. Time',
                  value: stats.avgCompletionTime ?? 'N/A',
                  color: const Color(0xFF5856D6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
