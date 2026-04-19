import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:k_chart_plus/k_chart_plus.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/chart_entity.dart';

class DepthChartWidget extends StatelessWidget {
  const DepthChartWidget({
    super.key,
    required this.bidsData,
    required this.asksData,
    this.isLoading = false,
  });

  final List<DepthDataPoint> bidsData;
  final List<DepthDataPoint> asksData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // dev.log(
    //     '🎯 DEPTH_CHART: Building depth chart with ${bidsData.length} bids and ${asksData.length} asks');

    final bidsEntities = _convertBidsToDepthEntities(bidsData);
    final asksEntities = _convertAsksToDepthEntities(asksData);
    final hasData = bidsEntities.isNotEmpty && asksEntities.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF0A0A0A)
            : context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Depth Chart Widget or placeholder
          SizedBox(
            height: 400, // Fixed height for depth chart
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasData
                  ? DepthChart(
                      bidsEntities,
                      asksEntities,
                      _buildChartColors(context),
                    )
                  : _buildPlaceholder(context),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: context.priceUpColor,
                ),
              ),
            ),

          // Chart type indicator
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.inputBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
              child: Text(
                'Order Book Depth',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem(context, 'Bids', context.priceUpColor),
                const SizedBox(width: 12),
                _buildLegendItem(context, 'Asks', context.priceDownColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.inputBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<DepthEntity> _convertBidsToDepthEntities(List<DepthDataPoint> data) {
    if (data.isEmpty) {
      // dev.log('🎯 DEPTH_CHART: No bid data points to convert');
      return [];
    }

    // For bids: Sort by price ascending, then reverse and accumulate
    final sortedData = List<DepthDataPoint>.from(data);
    sortedData.sort((a, b) => a.price.compareTo(b.price));

    final List<DepthEntity> entities = [];
    double cumulativeVolume = 0.0;

    // Process bids in reverse order (highest price first) and accumulate
    for (var point in sortedData.reversed) {
      cumulativeVolume += point.volume;
      entities.insert(0, DepthEntity(point.price, cumulativeVolume));
    }

    // dev.log(
    //     '🎯 DEPTH_CHART: Converting ${data.length} bid data points to depth entities');
    if (entities.isNotEmpty) {
      // dev.log(
      //     '🎯 DEPTH_CHART: Bid price range: ${entities.first.price.toStringAsFixed(6)} - ${entities.last.price.toStringAsFixed(6)} (desc)');
      // dev.log(
      //     '🎯 DEPTH_CHART: Bid cumulative volume range: ${entities.first.vol.toStringAsFixed(0)} - ${entities.last.vol.toStringAsFixed(0)}');
    }

    return entities;
  }

  List<DepthEntity> _convertAsksToDepthEntities(List<DepthDataPoint> data) {
    if (data.isEmpty) {
      // dev.log('🎯 DEPTH_CHART: No ask data points to convert');
      return [];
    }

    // For asks: Sort by price ascending and accumulate normally
    final sortedData = List<DepthDataPoint>.from(data);
    sortedData.sort((a, b) => a.price.compareTo(b.price));

    double cumulativeVolume = 0.0;
    final entities = sortedData.map((point) {
      cumulativeVolume += point.volume;
      return DepthEntity(point.price, cumulativeVolume);
    }).toList();

    // dev.log(
    //     '🎯 DEPTH_CHART: Converting ${data.length} ask data points to depth entities');
    if (entities.isNotEmpty) {
      // dev.log(
      //     '🎯 DEPTH_CHART: Ask price range: ${entities.first.price.toStringAsFixed(6)} - ${entities.last.price.toStringAsFixed(6)} (asc)');
      // dev.log(
      //     '🎯 DEPTH_CHART: Ask cumulative volume range: ${entities.first.vol.toStringAsFixed(0)} - ${entities.last.vol.toStringAsFixed(0)}');
    }

    return entities;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color:
          context.isDarkMode ? const Color(0xFF0A0A0A) : context.cardBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for Order Book Data',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Depth chart will appear when\nreal-time data is available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  ChartColors _buildChartColors(BuildContext context) {
    return ChartColors(
      bgColor:
          context.isDarkMode ? const Color(0xFF0A0A0A) : context.cardBackground,
      defaultTextColor: context.textSecondary,
      gridColor: context.borderColor,
      hCrossColor: context.textPrimary,
      vCrossColor: context.borderColor.withValues(alpha: 0.3),
      crossTextColor: context.textPrimary,
      selectBorderColor: context.textSecondary,
      selectFillColor: context.inputBackground,
      infoWindowTitleColor: context.textSecondary,
      infoWindowNormalColor: context.textPrimary,
      upColor: context.priceUpColor,
      dnColor: context.priceDownColor,
      ma5Color: Colors.yellow,
      ma10Color: Colors.orange,
      ma30Color: Colors.purple,
      volColor: context.textSecondary.withValues(alpha: 0.6),
      macdColor: Colors.blue,
      difColor: Colors.red,
      deaColor: Colors.orange,
      kColor: Colors.blue,
      dColor: Colors.orange,
      jColor: Colors.purple,
      rsiColor: Colors.yellow,
      maxColor: context.priceUpColor,
      minColor: context.priceDownColor,
      nowPriceUpColor: context.priceUpColor,
      nowPriceDnColor: context.priceDownColor,
      nowPriceTextColor: context.textPrimary,
    );
  }
}
