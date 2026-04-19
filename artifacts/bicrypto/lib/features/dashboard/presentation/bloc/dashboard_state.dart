import 'package:equatable/equatable.dart';

import '../../../market/domain/entities/market_data_entity.dart';
import '../../../notification/domain/entities/announcement_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.marketStats,
    required this.portfolioData,
    required this.recentActivities,
    required this.announcements,
    required this.isRefreshing,
    required this.marketInsights,
    required this.topGainers,
    required this.topLosers,
    required this.highVolumeMarkets,
  });

  final List<MarketDataEntity> marketStats;
  final DashboardPortfolioData portfolioData;
  final List<DashboardActivityData> recentActivities;
  final List<AnnouncementEntity> announcements;
  final bool isRefreshing;
  final DashboardMarketInsights marketInsights;
  final List<MarketDataEntity> topGainers;
  final List<MarketDataEntity> topLosers;
  final List<MarketDataEntity> highVolumeMarkets;

  @override
  List<Object?> get props => [
        marketStats,
        portfolioData,
        recentActivities,
        announcements,
        isRefreshing,
        marketInsights,
        topGainers,
        topLosers,
        highVolumeMarkets,
      ];

  DashboardLoaded copyWith({
    List<MarketDataEntity>? marketStats,
    DashboardPortfolioData? portfolioData,
    List<DashboardActivityData>? recentActivities,
    List<AnnouncementEntity>? announcements,
    bool? isRefreshing,
    DashboardMarketInsights? marketInsights,
    List<MarketDataEntity>? topGainers,
    List<MarketDataEntity>? topLosers,
    List<MarketDataEntity>? highVolumeMarkets,
  }) {
    return DashboardLoaded(
      marketStats: marketStats ?? this.marketStats,
      portfolioData: portfolioData ?? this.portfolioData,
      recentActivities: recentActivities ?? this.recentActivities,
      announcements: announcements ?? this.announcements,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      marketInsights: marketInsights ?? this.marketInsights,
      topGainers: topGainers ?? this.topGainers,
      topLosers: topLosers ?? this.topLosers,
      highVolumeMarkets: highVolumeMarkets ?? this.highVolumeMarkets,
    );
  }
}

class DashboardError extends DashboardState {
  const DashboardError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

// Data classes for dashboard components
class DashboardPortfolioData extends Equatable {
  const DashboardPortfolioData({
    required this.totalValue,
    required this.change24h,
    required this.change24hPercentage,
    required this.totalPnL,
    required this.totalPnLPercentage,
  });

  final double totalValue;
  final double change24h;
  final double change24hPercentage;
  final double totalPnL;
  final double totalPnLPercentage;

  @override
  List<Object?> get props => [
        totalValue,
        change24h,
        change24hPercentage,
        totalPnL,
        totalPnLPercentage,
      ];
}

class DashboardActivityData extends Equatable {
  const DashboardActivityData({
    required this.type,
    required this.symbol,
    required this.amount,
    required this.value,
    required this.isPositive,
    required this.timeAgo,
  });

  final String type;
  final String symbol;
  final String amount;
  final String value;
  final bool isPositive;
  final String timeAgo;

  @override
  List<Object?> get props => [
        type,
        symbol,
        amount,
        value,
        isPositive,
        timeAgo,
      ];
}

class DashboardMarketInsights extends Equatable {
  const DashboardMarketInsights({
    required this.totalMarkets,
    required this.positiveMarkets,
    required this.negativeMarkets,
    required this.averageChange,
    required this.totalVolume,
    this.topGainer,
    this.topLoser,
    this.highVolumeMarket,
  });

  final int totalMarkets;
  final int positiveMarkets;
  final int negativeMarkets;
  final double averageChange;
  final double totalVolume;
  final MarketDataEntity? topGainer;
  final MarketDataEntity? topLoser;
  final MarketDataEntity? highVolumeMarket;

  @override
  List<Object?> get props => [
        totalMarkets,
        positiveMarkets,
        negativeMarkets,
        averageChange,
        totalVolume,
        topGainer,
        topLoser,
        highVolumeMarket,
      ];
}
