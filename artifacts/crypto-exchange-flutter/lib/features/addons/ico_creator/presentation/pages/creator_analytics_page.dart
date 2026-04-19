import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

import '../bloc/stats_cubit.dart';
import '../bloc/performance_cubit.dart';

class CreatorAnalyticsPage extends StatelessWidget {
  const CreatorAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: BlocBuilder<StatsCubit, StatsState>(
              builder: (context, state) {
                if (state is StatsLoading) {
                  return _buildLoadingState();
                }
                if (state is StatsError) {
                  return _buildErrorState(context, state.message);
                }
                if (state is StatsLoaded) {
                  return _buildAnalyticsContent(context, state.stats);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.colors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<StatsCubit>().fetchStats();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, dynamic stats) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewSection(context, stats),

          const SizedBox(height: 24),

          // Growth Metrics
          Text(
            'Growth Metrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildGrowthMetrics(context, stats),

          const SizedBox(height: 24),

          // Performance Chart
          Text(
            'Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildPerformanceChart(context),

          const SizedBox(height: 24),

          // Offerings Breakdown
          Text(
            'Offerings Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildOfferingsBreakdown(context, stats),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, dynamic stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          title: 'Total Raised',
          value: '\$${_formatAmount(stats.totalRaised)}',
          icon: Icons.attach_money,
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
        ),
        _buildStatCard(
          context,
          title: 'Total Offerings',
          value: stats.totalOfferings.toString(),
          icon: Icons.rocket_launch,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
        ),
        _buildStatCard(
          context,
          title: 'Success Rate',
          value: '${stats.successRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
        ),
        _buildStatCard(
          context,
          title: 'Active',
          value: stats.activeOfferings.toString(),
          icon: Icons.pending_actions,
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 24,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthMetrics(BuildContext context, dynamic stats) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildGrowthItem(
            context,
            label: 'Offerings Growth',
            value: stats.offeringsGrowth,
            icon: Icons.show_chart,
          ),
          const SizedBox(height: 16),
          _buildGrowthItem(
            context,
            label: 'Raise Growth',
            value: stats.raiseGrowth,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildGrowthItem(
            context,
            label: 'Success Rate Growth',
            value: stats.successRateGrowth,
            icon: Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(
    BuildContext context, {
    required String label,
    required double value,
    required IconData icon,
  }) {
    final isPositive = value >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${value.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
      ),
      child: _PerformanceChart(),
    );
  }

  Widget _buildOfferingsBreakdown(BuildContext context, dynamic stats) {
    final total = stats.totalOfferings;
    if (total == 0) return const SizedBox.shrink();

    final active = stats.activeOfferings;
    final completed = stats.completedOfferings;
    final pending = stats.pendingOfferings;
    final rejected = stats.rejectedOfferings;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            context.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBreakdownItem(
                  context,
                  label: 'Active',
                  count: active,
                  total: total,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreakdownItem(
                  context,
                  label: 'Completed',
                  count: completed,
                  total: total,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBreakdownItem(
                  context,
                  label: 'Pending',
                  count: pending,
                  total: total,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreakdownItem(
                  context,
                  label: 'Rejected',
                  count: rejected,
                  total: total,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _PerformanceChart extends StatefulWidget {
  @override
  State<_PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<_PerformanceChart> {
  String _range = '30d';

  @override
  void initState() {
    super.initState();
    context.read<PerformanceCubit>().fetch(_range);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenue Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: DropdownButton<String>(
                value: _range,
                underline: const SizedBox.shrink(),
                isDense: true,
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                items: const [
                  DropdownMenuItem(value: '7d', child: Text('7 Days')),
                  DropdownMenuItem(value: '30d', child: Text('30 Days')),
                  DropdownMenuItem(value: '90d', child: Text('90 Days')),
                  DropdownMenuItem(value: 'all', child: Text('All Time')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _range = v);
                  context.read<PerformanceCubit>().fetch(v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<PerformanceCubit, PerformanceState>(
            builder: (context, state) {
              if (state is PerformanceLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PerformanceError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load chart',
                        style: TextStyle(color: context.colors.error),
                      ),
                    ],
                  ),
                );
              }
              if (state is PerformanceLoaded && state.data.isNotEmpty) {
                final spots = state.data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                    .toList();

                final maxY =
                    spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);
                final minY =
                    spots.map((s) => s.y).fold(maxY, (a, b) => a < b ? a : b);

                // Ensure we have a valid interval (avoid division by zero)
                final range = maxY - minY;
                final horizontalInterval = range > 0 ? range / 4 : 1.0;

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: horizontalInterval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: spots.length > 7 ? spots.length / 7 : 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= spots.length) {
                              return const SizedBox.shrink();
                            }
                            final date = state.data[value.toInt()].date;
                            return Text(
                              _formatDate(date, _range),
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatChartValue(value),
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: spots.length - 1,
                    minY: range > 0 ? minY * 0.9 : minY - 1,
                    maxY: range > 0 ? maxY * 1.1 : maxY + 1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            context.colors.primary,
                            context.colors.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: context.colors.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              context.colors.primary.withValues(alpha: 0.2),
                              context.colors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor:
                            isDark ? Colors.grey.shade800 : Colors.white,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '\$${_formatAmount(spot.y)}',
                              TextStyle(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              }
              return Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, String range) {
    if (range == '7d' || range == '30d') {
      return '${date.day}/${date.month}';
    } else if (range == '90d') {
      return '${date.month}/${date.year.toString().substring(2)}';
    } else {
      return '${date.month}/${date.year.toString().substring(2)}';
    }
  }

  String _formatChartValue(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
