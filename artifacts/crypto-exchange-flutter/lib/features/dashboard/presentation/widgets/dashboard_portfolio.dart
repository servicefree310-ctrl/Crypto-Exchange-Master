import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/dashboard_state.dart';

class DashboardPortfolio extends StatelessWidget {
  const DashboardPortfolio({
    super.key,
    required this.portfolioData,
  });

  final DashboardPortfolioData portfolioData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(context.isSmallScreen ? 14.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: context.bodyM.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: context.isSmallScreen ? 13.0 : 14.0,
                      ),
                    ),
                    SizedBox(height: context.isSmallScreen ? 2.0 : 4.0),
                    Text(
                      '\$${portfolioData.totalValue.toStringAsFixed(2)}',
                      style: context.priceLarge().copyWith(
                            color: Colors.white,
                            fontSize: context.isSmallScreen ? 24.0 : 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(context.isSmallScreen ? 6.0 : 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: context.isSmallScreen ? 20.0 : 24.0,
                ),
              ),
            ],
          ),
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context,
                  '24h Change',
                  '\$${portfolioData.change24h.toStringAsFixed(2)}',
                  '${portfolioData.change24hPercentage >= 0 ? '+' : ''}${portfolioData.change24hPercentage.toStringAsFixed(2)}%',
                  portfolioData.change24hPercentage >= 0,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMetric(
                  context,
                  'Total P&L',
                  '\$${portfolioData.totalPnL.toStringAsFixed(2)}',
                  '${portfolioData.totalPnLPercentage >= 0 ? '+' : ''}${portfolioData.totalPnLPercentage.toStringAsFixed(1)}%',
                  portfolioData.totalPnLPercentage >= 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    String percentage,
    bool isPositive,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: context.bodyS.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: context.isSmallScreen ? 11.0 : 12.0,
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 2.0 : 4.0),
        Text(
          value,
          style: context.h6.copyWith(
            color: Colors.white,
            fontSize: context.isSmallScreen ? 14.0 : 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          percentage,
          style: context.percentageChange().copyWith(
                color:
                    isPositive ? context.priceUpColor : context.priceDownColor,
                fontSize: context.isSmallScreen ? 11.0 : 12.0,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
