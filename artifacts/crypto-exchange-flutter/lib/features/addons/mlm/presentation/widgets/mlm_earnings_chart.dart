import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';

class MlmEarningsChart extends StatelessWidget {
  final List<MlmChartDataEntity> earningsChart;
  final String period;

  const MlmEarningsChart({
    super.key,
    required this.earningsChart,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: context.priceUpColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Earnings Chart',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.priceUpColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    _getPeriodName(period),
                    style: context.labelS.copyWith(
                      color: context.priceUpColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chart Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (earningsChart.isEmpty)
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 32,
                          color: context.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No earnings data',
                          style: context.bodyM.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Data will appear when you start earning',
                          style: context.labelS.copyWith(
                            color: context.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: EarningsChartPainter(
                          data: earningsChart,
                          color: context.priceUpColor,
                          backgroundColor: context.cardBackground,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                if (earningsChart.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildChartLegend(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    if (earningsChart.isEmpty) return const SizedBox.shrink();

    final maxValue =
        earningsChart.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue =
        earningsChart.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final avgValue = earningsChart.map((e) => e.value).reduce((a, b) => a + b) /
        earningsChart.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CompactLegendItem(
              label: 'Max',
              value: '\$${maxValue.toStringAsFixed(2)}',
              color: context.priceUpColor,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: context.borderColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _CompactLegendItem(
              label: 'Avg',
              value: '\$${avgValue.toStringAsFixed(2)}',
              color: context.colors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: context.borderColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _CompactLegendItem(
              label: 'Min',
              value: '\$${minValue.toStringAsFixed(2)}',
              color: context.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodName(String period) {
    switch (period) {
      case '1m':
        return '1M';
      case '3m':
        return '3M';
      case '6m':
        return '6M';
      case '1y':
        return '1Y';
      default:
        return period.toUpperCase();
    }
  }
}

class _CompactLegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.labelS.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.labelM.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class EarningsChartPainter extends CustomPainter {
  final List<MlmChartDataEntity> data;
  final Color color;
  final Color backgroundColor;

  EarningsChartPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    // Add padding to the chart
    final padding = 20.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final normalizedValue =
          valueRange > 0 ? (data[i].value - minValue) / valueRange : 0.5;
      final y = padding + chartHeight - (normalizedValue * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    if (data.isNotEmpty) {
      fillPath.lineTo(padding + chartWidth, size.height - padding);
      fillPath.close();
    }

    // Draw fill first
    canvas.drawPath(fillPath, fillPaint);

    // Draw line on top
    canvas.drawPath(path, paint);

    // Draw points with enhanced styling
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final normalizedValue =
          valueRange > 0 ? (data[i].value - minValue) / valueRange : 0.5;
      final y = padding + chartHeight - (normalizedValue * chartHeight);

      // Draw point border
      canvas.drawCircle(Offset(x, y), 4, pointBorderPaint);
      // Draw point
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
