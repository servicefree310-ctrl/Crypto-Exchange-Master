import 'dart:async';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/chart_service.dart';
import '../../../../core/services/market_service.dart';
import '../../domain/entities/market_data_entity.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_realtime_datasource.dart';
import '../datasources/market_remote_data_source.dart';
import '../models/market_model.dart';
import '../models/ticker_model.dart';

@Injectable(as: MarketRepository)
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl(
    this._remoteDataSource,
    this._realtimeDataSource,
    this._networkInfo,
    this._chartService,
    this._marketService,
  );

  final MarketRemoteDataSource _remoteDataSource;
  final MarketRealtimeDataSource _realtimeDataSource;
  final NetworkInfo _networkInfo;
  final ChartService _chartService;
  final MarketService _marketService;

  // Permanent cache for market entities
  List<MarketModel>? _marketsCache;
  Map<String, TickerModel>? _tickersCache;
  Timer? _backgroundUpdateTimer;
  DateTime? _lastCacheUpdate;

  // API call tracking to prevent multiple simultaneous calls
  final bool _isApiCallInProgress = false;
  static final bool _globalApiCallInProgress = false;

  // Permanent cache with background updates - REDUCED FREQUENCY
  static const Duration _backgroundUpdateInterval =
      Duration(minutes: 5); // Reduced from 60s to 5min
  static const Duration _forceUpdateInterval =
      Duration(minutes: 30); // Increased from 10min to 30min

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getMarkets() async {
    try {
      // Ensure we have data in the global cache
      if (!_marketService.hasCachedData) {
        await _marketService.fetchMarkets();
      }

      final markets = _marketService.cachedMarkets;

      if (markets.isEmpty) {
        return const Left(ServerFailure('No market data available'));
      }

      // Initialize chart service with current prices (for mini-charts)
      final priceMap = <String, double>{};
      for (final m in markets) {
        priceMap[m.symbol] = m.price;
      }
      _chartService.initializeSymbols(
        markets.map((m) => m.symbol).toList(),
        priceMap,
      );

      return Right(markets);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch markets: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getTrendingMarkets() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          final trendingMarkets =
              markets.where((market) => market.isTrending).toList();
          return Right(trendingMarkets);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getHotMarkets() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          final hotMarkets = markets.where((market) => market.isHot).toList();
          return Right(hotMarkets);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getGainersMarkets() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          final gainers = markets.where((market) => market.isPositive).toList();
          // Sort by change percentage descending
          gainers.sort((a, b) => b.changePercent.compareTo(a.changePercent));
          return Right(gainers);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getLosersMarkets() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          final losers = markets.where((market) => market.isNegative).toList();
          // Sort by change percentage ascending (most negative first)
          losers.sort((a, b) => a.changePercent.compareTo(b.changePercent));
          return Right(losers);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getHighVolumeMarkets() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          // Sort by volume descending
          final highVolumeMarkets = List<MarketDataEntity>.from(markets);
          highVolumeMarkets
              .sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
          return Right(highVolumeMarkets);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> searchMarkets(
      String query) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          final filteredMarkets = markets.where((market) {
            final searchTerm = query.toLowerCase();
            return market.symbol.toLowerCase().contains(searchTerm) ||
                market.currency.toLowerCase().contains(searchTerm) ||
                market.pair.toLowerCase().contains(searchTerm);
          }).toList();
          return Right(filteredMarkets);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketDataEntity>>> getMarketsByCategory(
      String category) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await getMarkets();
      return result.fold(
        (failure) => Left(failure),
        (markets) {
          if (category.toLowerCase() == 'all') {
            return Right(markets);
          }

          // Filter by category - for now, we'll filter by the second part of the pair
          final filteredMarkets = markets.where((market) {
            final pairParts = market.pair.split('/');
            if (pairParts.length > 1) {
              return pairParts[1].toLowerCase() == category.toLowerCase();
            }
            return false;
          }).toList();

          return Right(filteredMarkets);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Real-time data streaming implementation
  @override
  Stream<List<MarketDataEntity>> getRealtimeMarkets() {
    // The global MarketService already emits updated market lists
    return _marketService.marketsStream;
  }

  @override
  Future<Either<Failure, void>> startRealtimeUpdates() async {
    // No action required – global WebSocketService is already running
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> stopRealtimeUpdates() async {
    // No action required – keep global stream alive
    return const Right(null);
  }

  @override
  Stream<WebSocketConnectionStatus> getConnectionStatus() {
    // Not used anymore by MarketBloc; return an empty stream
    return const Stream.empty();
  }

  /// Update cache in background without affecting UI
  Future<void> _updateCacheInBackground() async {
    try {
      final results = await Future.wait([
        _remoteDataSource.getMarkets(),
        _remoteDataSource.getTickers(),
      ]);

      final markets = results[0] as List<MarketModel>;
      final tickers = results[1] as Map<String, TickerModel>;

      // Update permanent cache
      _marketsCache = markets;
      _tickersCache = tickers;
      _lastCacheUpdate = DateTime.now();

      dev.log(
          '🔄 MARKET_REPO: Background cache updated with ${markets.length} markets');
    } catch (e) {
      dev.log('❌ MARKET_REPO: Background cache update failed: $e');
      // Don't throw - just log and continue with existing cache
    }
  }

  /// Check if cache needs force update (fallback for when WebSocket is down)
  bool _shouldForceUpdate() {
    if (_lastCacheUpdate == null) return true;
    return DateTime.now().difference(_lastCacheUpdate!) > _forceUpdateInterval;
  }

  /// Dispose of the repository
  Future<void> dispose() async {
    await stopRealtimeUpdates();
    _marketsCache = null;
    _tickersCache = null;
  }
}
