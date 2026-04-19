import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/market_service.dart';
import '../../../../core/services/global_notification_service.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../notification/domain/entities/announcement_entity.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(
    this._marketService,
    this._globalNotificationService,
  ) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<DashboardMarketStatsUpdateRequested>(_onMarketStatsUpdateRequested);
    on<DashboardPortfolioUpdateRequested>(_onPortfolioUpdateRequested);
    on<DashboardRecentActivityUpdateRequested>(
        _onRecentActivityUpdateRequested);

    // Subscribe to global services for real-time updates
    _marketSubscription = _marketService.marketsStream.listen((markets) {
      add(const DashboardMarketStatsUpdateRequested());
    });

    _announcementsSubscription =
        _globalNotificationService.announcementsStream.listen((announcements) {
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(currentState.copyWith(announcements: announcements));
      }
    });
  }

  final MarketService _marketService;
  final GlobalNotificationService _globalNotificationService;

  StreamSubscription<List<MarketDataEntity>>? _marketSubscription;
  StreamSubscription<List<AnnouncementEntity>>? _announcementsSubscription;

  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    try {
      // Get market stats from global service
      final markets = _marketService.cachedMarkets;
      final marketStats = _getTopMarketStats(markets);
      final topGainers = _getTopGainers(markets);
      final topLosers = _getTopLosers(markets);
      final highVolumeMarkets = _getHighVolumeMarkets(markets);
      final marketInsights = _getMarketInsights(markets);

      // Get announcements from global service
      final announcements = _globalNotificationService.cachedAnnouncements;

      // Create portfolio data (mock for now, should come from wallet service)
      final portfolioData = const DashboardPortfolioData(
        totalValue: 127543.89,
        change24h: 3247.12,
        change24hPercentage: 2.61,
        totalPnL: 27543.89,
        totalPnLPercentage: 27.6,
      );

      // Create recent activities (mock for now, should come from activity service)
      final recentActivities = [
        const DashboardActivityData(
          type: 'Spot Buy',
          symbol: 'BTC/USDT',
          amount: '0.0234 BTC',
          value: '+\$1,573.45',
          isPositive: true,
          timeAgo: '2m ago',
        ),
        const DashboardActivityData(
          type: 'P2P Sell',
          symbol: 'USDT',
          amount: '5,000 USDT',
          value: '+\$5,000.00',
          isPositive: true,
          timeAgo: '1h ago',
        ),
        const DashboardActivityData(
          type: 'Futures',
          symbol: 'ETH/USDT',
          amount: '2.5 ETH',
          value: '-\$234.56',
          isPositive: false,
          timeAgo: '3h ago',
        ),
        const DashboardActivityData(
          type: 'Staking',
          symbol: 'DOT Reward',
          amount: '12.34 DOT',
          value: '+\$145.67',
          isPositive: true,
          timeAgo: '1d ago',
        ),
      ];

      emit(DashboardLoaded(
        marketStats: marketStats,
        portfolioData: portfolioData,
        recentActivities: recentActivities,
        announcements: announcements,
        isRefreshing: false,
        marketInsights: marketInsights,
        topGainers: topGainers,
        topLosers: topLosers,
        highVolumeMarkets: highVolumeMarkets,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      try {
        // Refresh market data
        await _marketService.fetchMarkets();

        // Update with fresh data
        final markets = _marketService.cachedMarkets;
        final marketStats = _getTopMarketStats(markets);
        final topGainers = _getTopGainers(markets);
        final topLosers = _getTopLosers(markets);
        final highVolumeMarkets = _getHighVolumeMarkets(markets);
        final marketInsights = _getMarketInsights(markets);
        final announcements = _globalNotificationService.cachedAnnouncements;

        emit(currentState.copyWith(
          marketStats: marketStats,
          announcements: announcements,
          isRefreshing: false,
          marketInsights: marketInsights,
          topGainers: topGainers,
          topLosers: topLosers,
          highVolumeMarkets: highVolumeMarkets,
        ));
      } catch (e) {
        emit(DashboardError(message: e.toString()));
      }
    }
  }

  Future<void> _onMarketStatsUpdateRequested(
    DashboardMarketStatsUpdateRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final markets = _marketService.cachedMarkets;
      final marketStats = _getTopMarketStats(markets);
      final topGainers = _getTopGainers(markets);
      final topLosers = _getTopLosers(markets);
      final highVolumeMarkets = _getHighVolumeMarkets(markets);
      final marketInsights = _getMarketInsights(markets);

      emit(currentState.copyWith(
        marketStats: marketStats,
        topGainers: topGainers,
        topLosers: topLosers,
        highVolumeMarkets: highVolumeMarkets,
        marketInsights: marketInsights,
      ));
    }
  }

  Future<void> _onPortfolioUpdateRequested(
    DashboardPortfolioUpdateRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // TODO: Implement portfolio updates from wallet service
    // For now, keep existing portfolio data
  }

  Future<void> _onRecentActivityUpdateRequested(
    DashboardRecentActivityUpdateRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // TODO: Implement recent activity updates from activity service
    // For now, keep existing activity data
  }

  List<MarketDataEntity> _getTopMarketStats(List<MarketDataEntity> markets) {
    // Get top 3 trending markets or highest volume markets
    final topMarkets =
        markets.where((m) => m.isTrending || m.isHot).take(3).toList();

    // If not enough trending, add high volume markets
    if (topMarkets.length < 3) {
      final highVolumeMarkets = markets
          .where((m) => !topMarkets.contains(m))
          .toList()
        ..sort((a, b) => b.baseVolume.compareTo(a.baseVolume));

      topMarkets.addAll(highVolumeMarkets.take(3 - topMarkets.length));
    }

    return topMarkets;
  }

  List<MarketDataEntity> _getTopGainers(List<MarketDataEntity> markets) {
    // Get top gainers from markets data
    final gainers = markets.where((market) => market.isPositive).toList()
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return gainers.take(4).toList();
  }

  List<MarketDataEntity> _getTopLosers(List<MarketDataEntity> markets) {
    // Get top losers from markets data
    final losers = markets.where((market) => market.isNegative).toList()
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return losers.take(4).toList();
  }

  List<MarketDataEntity> _getHighVolumeMarkets(List<MarketDataEntity> markets) {
    // Get high volume markets
    final highVolume = List<MarketDataEntity>.from(markets)
      ..sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
    return highVolume.take(4).toList();
  }

  DashboardMarketInsights _getMarketInsights(List<MarketDataEntity> markets) {
    if (markets.isEmpty) {
      return const DashboardMarketInsights(
        totalMarkets: 0,
        positiveMarkets: 0,
        negativeMarkets: 0,
        averageChange: 0.0,
        totalVolume: 0.0,
        topGainer: null,
        topLoser: null,
        highVolumeMarket: null,
      );
    }

    final totalMarkets = markets.length;
    final positiveMarkets = markets.where((m) => m.isPositive).length;
    final negativeMarkets = markets.where((m) => m.isNegative).length;
    final avgChange = markets.fold<double>(
          0.0,
          (sum, market) => sum + market.changePercent,
        ) /
        totalMarkets;

    final totalVolume = markets.fold<double>(
      0.0,
      (sum, market) => sum + market.baseVolume,
    );

    // Get top performers
    final sortedByGain = List<MarketDataEntity>.from(markets)
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    final topGainer = sortedByGain.isNotEmpty ? sortedByGain.first : null;

    final sortedByLoss = List<MarketDataEntity>.from(markets)
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    final topLoser = sortedByLoss.isNotEmpty ? sortedByLoss.first : null;

    final sortedByVolume = List<MarketDataEntity>.from(markets)
      ..sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
    final highVolume = sortedByVolume.isNotEmpty ? sortedByVolume.first : null;

    return DashboardMarketInsights(
      totalMarkets: totalMarkets,
      positiveMarkets: positiveMarkets,
      negativeMarkets: negativeMarkets,
      averageChange: avgChange,
      totalVolume: totalVolume,
      topGainer: topGainer,
      topLoser: topLoser,
      highVolumeMarket: highVolume,
    );
  }

  @override
  Future<void> close() {
    _marketSubscription?.cancel();
    _announcementsSubscription?.cancel();
    return super.close();
  }
}
