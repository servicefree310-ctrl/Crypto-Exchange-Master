import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_state.dart';

/// Widget to display staking statistics overview
class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state is StatsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StatsLoaded) {
          final stats = state.stats;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildCard(context, 'Total Staked', stats.totalStaked),
                _buildCard(context, 'Active Users', stats.activeUsers),
                _buildCard(context, 'Avg. APR', stats.avgApr, isPercent: true),
                _buildCard(context, 'Total Rewards', stats.totalRewards),
              ],
            ),
          );
        } else if (state is StatsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    num value, {
    bool isPercent = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple.shade700, Colors.indigo.shade700]
                : [Colors.blue.shade400, Colors.lightBlueAccent.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white),
            ),
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 800),
              builder: (context, val, child) {
                final display = isPercent
                    ? '${val.toStringAsFixed(2)}%'
                    : value is int || value == val.floor()
                        ? val.toInt().toString()
                        : '\$${val.toStringAsFixed(2)}';
                return Text(
                  display,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
