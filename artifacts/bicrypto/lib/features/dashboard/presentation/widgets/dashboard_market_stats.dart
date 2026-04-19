import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

class DashboardMarketStats extends StatelessWidget {
  const DashboardMarketStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          return _buildMarketStats(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMarketStats(BuildContext context, DashboardLoaded state) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius:
            BorderRadius.circular(context.isSmallScreen ? 14.0 : 16.0),
        border: Border.all(
          color: context.borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Market Intelligence Header
          _buildLiveMarketHeader(context, state.marketInsights),
          SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

          // Advanced Market Insights
          _buildAdvancedMarketInsights(context, state.marketInsights),
        ],
      ),
    );
  }

  Widget _buildLiveMarketHeader(
      BuildContext context, DashboardMarketInsights insights) {
    final isBullish = insights.positiveMarkets > insights.negativeMarkets;
    final sentimentColor =
        isBullish ? context.priceUpColor : context.priceDownColor;
    final sentimentIcon = isBullish ? Icons.trending_up : Icons.trending_down;
    final sentimentText = isBullish ? 'Bullish' : 'Bearish';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: sentimentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            sentimentIcon,
            color: sentimentColor,
            size: 20.0,
          ),
        ),
        SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Market Intelligence',
                style: context.h6.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                '$sentimentText Sentiment • ${insights.totalMarkets} Markets Active',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 8.0 : 12.0,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            color: sentimentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            sentimentText,
            style: context.bodyS.copyWith(
              color: sentimentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMarketInsights(
      BuildContext context, DashboardMarketInsights insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Overview',
          style: context.h6.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),

        // Market Statistics Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Volume',
                '\$${_formatVolume(insights.totalVolume)}',
                Icons.analytics_outlined,
                context.colors.primary,
              ),
            ),
            SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Change',
                '${insights.averageChange.toStringAsFixed(2)}%',
                Icons.trending_up_outlined,
                insights.averageChange >= 0
                    ? context.priceUpColor
                    : context.priceDownColor,
              ),
            ),
          ],
        ),
        SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),

        // Market Sentiment Breakdown
        Row(
          children: [
            Expanded(
              child: _buildSentimentCard(
                context,
                'Gainers',
                insights.positiveMarkets,
                insights.totalMarkets,
                context.priceUpColor,
              ),
            ),
            SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
            Expanded(
              child: _buildSentimentCard(
                context,
                'Losers',
                insights.negativeMarkets,
                insights.totalMarkets,
                context.priceDownColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16.0,
              ),
              SizedBox(width: 6.0),
              Text(
                title,
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(
    BuildContext context,
    String title,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                '$count',
                style: context.h6.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.0),
              Text(
                '($percentage%)',
                style: context.bodyS.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: total > 0 ? count / total : 0.0,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4.0,
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1e12) {
      return '${(volume / 1e12).toStringAsFixed(1)}T';
    } else if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(1)}B';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(1)}M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(1)}K';
    } else {
      return volume.toStringAsFixed(0);
    }
  }
}
