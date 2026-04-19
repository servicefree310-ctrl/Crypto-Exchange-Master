import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transaction_entity.dart';

enum ChartType { status, type }

class TransactionTypeChart extends StatelessWidget {
  const TransactionTypeChart({
    super.key,
    required this.transactions,
    required this.chartType,
  });

  final List<TransactionEntity> transactions;
  final ChartType chartType;

  @override
  Widget build(BuildContext context) {
    final data = chartType == ChartType.status
        ? _getStatusData(transactions)
        : _getTypeData(transactions);

    if (data.isEmpty || data.every((item) => item.value == 0)) {
      return Center(
        child: Text(
          'No data available',
          style: context.bodyM.copyWith(
            color: context.textTertiary,
          ),
        ),
      );
    }

    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildPieChart(context, data),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transactions.length.toString(),
                      style: context.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'Total',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildLegend(context, data),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, List<ChartData> data) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: PieChartPainter(
        data: data,
        backgroundColor: context.background,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, List<ChartData> data) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: data.map((item) {
        final percentage =
            ((item.value / transactions.length) * 100).toStringAsFixed(1);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item.label} ($percentage%)',
              style: context.bodyS.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<ChartData> _getStatusData(List<TransactionEntity> transactions) {
    final statusCounts = <TransactionStatus, int>{};

    for (final tx in transactions) {
      statusCounts[tx.status] = (statusCounts[tx.status] ?? 0) + 1;
    }

    return statusCounts.entries.where((e) => e.value > 0).map((e) {
      final status = e.key;
      final count = e.value;

      return ChartData(
        label: _getStatusLabel(status),
        value: count.toDouble(),
        color: _getStatusColor(status),
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  List<ChartData> _getTypeData(List<TransactionEntity> transactions) {
    final typeCounts = <TransactionType, int>{};

    for (final tx in transactions) {
      typeCounts[tx.type] = (typeCounts[tx.type] ?? 0) + 1;
    }

    return typeCounts.entries.where((e) => e.value > 0).map((e) {
      final type = e.key;
      final count = e.value;

      return ChartData(
        label: _getTypeLabel(type),
        value: count.toDouble(),
        color: _getTypeColor(type),
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.PENDING:
        return 'Pending';
      case TransactionStatus.COMPLETED:
        return 'Completed';
      case TransactionStatus.CANCELLED:
        return 'Cancelled';
      case TransactionStatus.FAILED:
        return 'Failed';
      case TransactionStatus.PROCESSING:
        return 'Processing';
      case TransactionStatus.REJECTED:
        return 'Rejected';
      case TransactionStatus.EXPIRED:
        return 'Expired';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return Colors.green;
      case TransactionStatus.PENDING:
      case TransactionStatus.PROCESSING:
        return Colors.orange;
      case TransactionStatus.FAILED:
      case TransactionStatus.REJECTED:
      case TransactionStatus.CANCELLED:
        return Colors.red;
      case TransactionStatus.EXPIRED:
        return Colors.grey;
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOSIT:
        return 'Deposit';
      case TransactionType.WITHDRAW:
        return 'Withdraw';
      case TransactionType.TRANSFER:
        return 'Transfer';
      case TransactionType.INCOMING_TRANSFER:
        return 'Incoming';
      case TransactionType.OUTGOING_TRANSFER:
        return 'Outgoing';
      case TransactionType.TRADE:
        return 'Trade';
      case TransactionType.SPOT_ORDER:
        return 'Spot';
      case TransactionType.FUTURES_ORDER:
        return 'Futures';
      case TransactionType.STAKING_STAKE:
        return 'Staking';
      case TransactionType.STAKING_REWARD:
        return 'Rewards';
      case TransactionType.BONUS:
        return 'Bonus';
      case TransactionType.FEE:
        return 'Fee';
      case TransactionType.P2P_TRADE:
        return 'P2P';
      case TransactionType.AI_INVESTMENT:
        return 'AI Invest';
      default:
        return type.name;
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOSIT:
      case TransactionType.INCOMING_TRANSFER:
        return Colors.green;
      case TransactionType.WITHDRAW:
      case TransactionType.OUTGOING_TRANSFER:
        return Colors.red;
      case TransactionType.TRANSFER:
        return Colors.blue;
      case TransactionType.TRADE:
      case TransactionType.SPOT_ORDER:
      case TransactionType.FUTURES_ORDER:
        return Colors.indigo;
      case TransactionType.STAKING_STAKE:
      case TransactionType.STAKING_REWARD:
        return Colors.purple;
      case TransactionType.BONUS:
      case TransactionType.REFERRAL_REWARD:
        return Colors.amber;
      case TransactionType.FEE:
        return Colors.orange;
      case TransactionType.P2P_TRADE:
        return Colors.teal;
      case TransactionType.AI_INVESTMENT:
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color backgroundColor;

  PieChartPainter({
    required this.data,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    double startAngle = -math.pi / 2;

    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw inner circle to create donut chart
    final innerPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
