import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/portfolio_performance_point_entity.dart';

class PortfolioPerformanceChart extends StatelessWidget {
  const PortfolioPerformanceChart({super.key, required this.points});

  final List<PortfolioPerformancePointEntity> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = points.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    List<FlSpot> spots = [];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value));
    }

    final color =
        points.last.value >= points.first.value ? Colors.green : Colors.red;

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
