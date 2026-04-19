import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/market_service.dart';
import '../../../../core/services/global_notification_service.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../notification/domain/entities/announcement_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(
    this._marketService,
    this._globalNotificationService,
    this._walletRepository,
    this._dioClient,
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
  final WalletRepository _walletRepository;
  final DioClient _dioClient;

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

      // Live portfolio + recent activity from API (with safe fallbacks)
      final portfolioData = await _fetchPortfolioData();
      final recentActivities = await _fetchRecentActivities();

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
        final portfolioData = await _fetchPortfolioData();
        final recentActivities = await _fetchRecentActivities();

        emit(currentState.copyWith(
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

  Future<DashboardPortfolioData> _fetchPortfolioData() async {
    const fallback = DashboardPortfolioData(
      totalValue: 0.0,
      change24h: 0.0,
      change24hPercentage: 0.0,
      totalPnL: 0.0,
      totalPnLPercentage: 0.0,
    );
    try {
      final balanceResult = await _walletRepository.getTotalBalanceUSD();
      return balanceResult.fold(
        (_) => fallback,
        (totalValue) => DashboardPortfolioData(
          totalValue: totalValue,
          change24h: 0.0,
          change24hPercentage: 0.0,
          totalPnL: 0.0,
          totalPnLPercentage: 0.0,
        ),
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<List<DashboardActivityData>> _fetchRecentActivities() async {
    try {
      final response = await _dioClient
          .get('/api/exchange/order', queryParameters: {'limit': 10});
      final data = response.data;
      if (data is! List) return const <DashboardActivityData>[];
      final orders = List<Map<String, dynamic>>.from(
        data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
      orders.sort((a, b) {
        final ad = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
      return orders.take(4).map(_orderToActivity).toList(growable: false);
    } catch (_) {
      return const <DashboardActivityData>[];
    }
  }

  DashboardActivityData _orderToActivity(Map<String, dynamic> o) {
    final side = (o['side'] ?? '').toString().toUpperCase();
    final type = (o['type'] ?? '').toString();
    final qty = double.tryParse(o['qty']?.toString() ?? '') ?? 0.0;
    final price = double.tryParse(o['price']?.toString() ?? '') ?? 0.0;
    final notional = qty * price;
    final pairId = o['pairId']?.toString() ?? '';
    final status = (o['status'] ?? '').toString();
    final createdAt = DateTime.tryParse(o['createdAt']?.toString() ?? '');
    final isBuy = side == 'BUY';
    return DashboardActivityData(
      type: '${type.isEmpty ? 'Spot' : _capitalize(type)} ${_capitalize(side.toLowerCase())}'.trim(),
      symbol: 'Pair $pairId',
      amount: '${qty.toStringAsFixed(6)} (${status})',
      value: '${isBuy ? '-' : '+'}\$${notional.toStringAsFixed(2)}',
      isPositive: !isBuy,
      timeAgo: _timeAgo(createdAt),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _timeAgo(DateTime? dt) {
    if (dt == null) return 'just now';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
