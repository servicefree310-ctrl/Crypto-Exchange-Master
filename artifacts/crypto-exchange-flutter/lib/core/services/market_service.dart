import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../../features/market/domain/entities/market_entity.dart';
import '../../features/market/domain/entities/market_data_entity.dart';
import '../../features/market/domain/entities/ticker_entity.dart';
import '../../features/market/data/models/market_model.dart';
import 'price_animation_service.dart';
import 'maintenance_service.dart';
import '../../injection/injection.dart';

@singleton
class MarketService {
  MarketService();

  late final PriceAnimationService _priceAnimationService =
      getIt<PriceAnimationService>();
  late final MaintenanceService _maintenanceService =
      getIt<MaintenanceService>();

  // Cached market data
  List<MarketDataEntity> _cachedMarkets = [];
  final Map<String, MarketDataEntity> _marketsMap = {};

  // Stream controllers
  final StreamController<List<MarketDataEntity>> _marketsController =
      StreamController<List<MarketDataEntity>>.broadcast();
  final StreamController<Map<String, MarketDataEntity>> _marketsMapController =
      StreamController<Map<String, MarketDataEntity>>.broadcast();

  // Loading state
  bool _isLoading = false;
  String? _lastError;

  // Cache timestamp
  DateTime? _lastCacheTime;
  static const Duration _cacheValidity = Duration(seconds: 20);

  // Public streams
  Stream<List<MarketDataEntity>> get marketsStream => _marketsController.stream;
  Stream<Map<String, MarketDataEntity>> get marketsMapStream =>
      _marketsMapController.stream;

  // Getters
  List<MarketDataEntity> get cachedMarkets => List.unmodifiable(_cachedMarkets);
  Map<String, MarketDataEntity> get cachedMarketsMap =>
      Map.unmodifiable(_marketsMap);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasCachedData => _cachedMarkets.isNotEmpty;
  DateTime? get lastCacheTime => _lastCacheTime;

  bool _offline =
      false; // Indicates if last initialization failed due to network issues

  /// Whether the service is currently in offline mode (no internet / DNS failure)
  bool get isOffline => _offline;

  /// Manually mark the service as offline from outside (e.g. main.dart)
  void markOffline() => _offline = true;

  void _clearOffline() => _offline = false;

  /// Initialize market service and fetch initial data
  Future<void> initialize() async {
    dev.log('🚀 MARKET_SERVICE: Initializing market service');
    try {
      await fetchMarkets();
      _clearOffline();
    } catch (_) {
      // Keep offline mode so UI can react
      _offline = true;
      rethrow;
    }
  }

  /// Fetch markets from API
  Future<List<MarketDataEntity>> fetchMarkets() async {
    // Check if cache is still valid
    if (_isCacheValid()) {
      dev.log('📊 MARKET_SERVICE: Using cached market data');
      return _cachedMarkets;
    }

    _isLoading = true;
    _lastError = null;

    try {
      dev.log('📡 MARKET_SERVICE: Fetching markets from API');
      final url = '${ApiConstants.baseUrl}${ApiConstants.markets}';
      dev.log('🌐 MARKET_SERVICE: URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      dev.log('📡 MARKET_SERVICE: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = jsonDecode(response.body);
          dev.log(
              '📊 MARKET_SERVICE: Received ${jsonData.length} markets from API');

          final markets = <MarketModel>[];
          for (int i = 0; i < jsonData.length; i++) {
            try {
              final marketModel = MarketModel.fromJson(jsonData[i]);
              markets.add(marketModel);
            } catch (e) {
              dev.log(
                  '⚠️ MARKET_SERVICE: Failed to parse market at index $i: $e');
              dev.log('🔍 MARKET_SERVICE: Problem data: ${jsonData[i]}');
              // Continue with other markets instead of failing completely
            }
          }

          if (markets.isEmpty) {
            throw Exception(
                'No valid markets could be parsed from API response');
          }

          await _updateCache(markets);
          dev.log(
              '✅ MARKET_SERVICE: Successfully cached ${markets.length} markets');

          // Clear maintenance mode on successful fetch
          _maintenanceService.clearMaintenanceMode();

          return _cachedMarkets;
        } on FormatException catch (e) {
          _lastError = 'Invalid data format received from server';
          dev.log('❌ MARKET_SERVICE: JSON parsing error: $e');
          dev.log('🔍 MARKET_SERVICE: Response body: ${response.body}');
          throw Exception('Invalid data format received from server');
        } catch (e) {
          _lastError = 'Failed to process market data: $e';
          dev.log('❌ MARKET_SERVICE: Market parsing error: $e');
          throw Exception('Failed to process market data: $e');
        }
      } else {
        _lastError = 'Server error: ${response.statusCode}';
        dev.log(
            '❌ MARKET_SERVICE: HTTP Error ${response.statusCode}: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _lastError ??= e.toString();
      dev.log('❌ MARKET_SERVICE: Error fetching markets: $e');

      // Handle maintenance mode
      _maintenanceService.handleServiceError(e, 'MarketService');

      // Return cached data if available, even if expired
      if (_cachedMarkets.isNotEmpty) {
        dev.log('📊 MARKET_SERVICE: Returning expired cached data as fallback');
        return _cachedMarkets;
      }

      // If no cached data and in maintenance, return mock data
      if (_maintenanceService.isInMaintenance) {
        dev.log('🎭 MARKET_SERVICE: Returning mock data due to maintenance');
        return _getMockMarkets();
      }

      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Update market data with ticker information from WebSocket
  void updateMarketsWithTickers(Map<String, dynamic> tickerData) {
    if (_cachedMarkets.isEmpty) {
      dev.log('⚠️ MARKET_SERVICE: No cached markets to update with tickers');
      return;
    }

    bool hasUpdates = false;
    final updatedMarkets = <MarketDataEntity>[];
    int matchCount = 0;

    for (final marketData in _cachedMarkets) {
      final symbol = marketData.symbol;
      final ticker = tickerData[symbol];

      if (ticker != null && ticker is Map<String, dynamic>) {
        matchCount++;
        final last = (ticker['last'] as num?)?.toDouble();
        final change = (ticker['change'] as num?)?.toDouble();
        final baseVolume = (ticker['baseVolume'] as num?)?.toDouble();
        final quoteVolume = (ticker['quoteVolume'] as num?)?.toDouble();

        if (last != null && last != marketData.price) {
          // Trigger global price animation (context will be handled by AnimatedPrice widgets)
          _priceAnimationService.updatePrice(symbol, last);

          final tickerEntity = TickerEntity(
            symbol: symbol,
            last: last,
            baseVolume: baseVolume ?? 0.0,
            quoteVolume: quoteVolume ?? 0.0,
            change: change != null
                ? change / 100.0
                : 0.0, // Convert percentage to decimal
          );

          final updatedMarketData = marketData.copyWith(ticker: tickerEntity);
          updatedMarkets.add(updatedMarketData);
          hasUpdates = true;
        } else {
          updatedMarkets.add(marketData);
        }

        // Also trigger change percentage animation if change percentage changed
        if (change != null) {
          final changePercent = change / 100.0;
          if (changePercent != marketData.changePercent) {
            _priceAnimationService.updateChangePercentage(
                symbol, changePercent);
          }
        }
      } else {
        updatedMarkets.add(marketData);
      }
    }

    if (hasUpdates) {
      _cachedMarkets = updatedMarkets;
      _updateMarketsMap();
      _emitUpdates();
    }
  }

  /// Get market by symbol
  MarketDataEntity? getMarketBySymbol(String symbol) {
    return _marketsMap[symbol];
  }

  /// Get markets by currency
  List<MarketDataEntity> getMarketsByCurrency(String currency) {
    return _cachedMarkets
        .where((market) => market.currency == currency)
        .toList();
  }

  /// Get trending markets
  List<MarketDataEntity> getTrendingMarkets() {
    return _cachedMarkets.where((market) => market.isTrending).toList();
  }

  /// Get hot markets
  List<MarketDataEntity> getHotMarkets() {
    return _cachedMarkets.where((market) => market.isHot).toList();
  }

  /// Get eco markets
  List<MarketDataEntity> getEcoMarkets() {
    return _cachedMarkets.where((market) => market.isEco).toList();
  }

  /// Get top gainers (markets with positive change, sorted by percentage)
  List<MarketDataEntity> getTopGainers({int limit = 10}) {
    final gainers = _cachedMarkets.where((market) => market.isPositive).toList()
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));

    return gainers.take(limit).toList();
  }

  /// Get top losers (markets with negative change, sorted by percentage)
  List<MarketDataEntity> getTopLosers({int limit = 10}) {
    final losers = _cachedMarkets.where((market) => market.isNegative).toList()
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));

    return losers.take(limit).toList();
  }

  /// Get high volume markets
  List<MarketDataEntity> getHighVolumeMarkets({int limit = 10}) {
    final highVolume = _cachedMarkets
        .where((market) => market.baseVolume > 1000000)
        .toList()
      ..sort((a, b) => b.baseVolume.compareTo(a.baseVolume));

    return highVolume.take(limit).toList();
  }

  /// Search markets by symbol or currency
  List<MarketDataEntity> searchMarkets(String query) {
    if (query.isEmpty) return _cachedMarkets;

    final lowercaseQuery = query.toLowerCase();
    return _cachedMarkets.where((market) {
      return market.currency.toLowerCase().contains(lowercaseQuery) ||
          market.pair.toLowerCase().contains(lowercaseQuery) ||
          market.symbol.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Refresh market data
  Future<void> refresh() async {
    dev.log('🔄 MARKET_SERVICE: Refreshing market data');
    _lastCacheTime = null; // Force refresh
    await fetchMarkets();
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastCacheTime == null || _cachedMarkets.isEmpty) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidity;
  }

  /// Update cache with new market data
  Future<void> _updateCache(List<MarketModel> marketModels) async {
    final markets = marketModels.map((model) {
      final marketEntity = model.toEntity();
      return MarketDataEntity(market: marketEntity);
    }).toList();

    _cachedMarkets = markets;
    _updateMarketsMap();
    _lastCacheTime = DateTime.now();

    _emitUpdates();
  }

  /// Update markets map for quick lookups
  void _updateMarketsMap() {
    _marketsMap.clear();
    for (final market in _cachedMarkets) {
      _marketsMap[market.symbol] = market;
    }
  }

  /// Emit updates to streams
  void _emitUpdates() {
    if (!_marketsController.isClosed) {
      _marketsController.add(_cachedMarkets);
    }
    if (!_marketsMapController.isClosed) {
      _marketsMapController.add(_marketsMap);
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedMarkets.clear();
    _marketsMap.clear();
    _lastCacheTime = null;
    _lastError = null;
    _emitUpdates();
    dev.log('🧹 MARKET_SERVICE: Cache cleared');
  }

  /// Dispose service
  void dispose() {
    _marketsController.close();
    _marketsMapController.close();
    dev.log('🔌 MARKET_SERVICE: Service disposed');
  }

  /// Generate mock market data for maintenance mode
  List<MarketDataEntity> _getMockMarkets() {
    final mockMarkets = [
      _createMockMarket('BTC', 'USDT', 43250.50, 2.5, 1250000000),
      _createMockMarket('ETH', 'USDT', 2280.75, -1.2, 850000000),
      _createMockMarket('BNB', 'USDT', 315.20, 0.8, 125000000),
      _createMockMarket('SOL', 'USDT', 98.45, 5.2, 95000000),
      _createMockMarket('XRP', 'USDT', 0.6234, -0.5, 75000000),
      _createMockMarket('ADA', 'USDT', 0.3845, 1.8, 45000000),
      _createMockMarket('DOGE', 'USDT', 0.0924, 3.1, 35000000),
      _createMockMarket('MATIC', 'USDT', 0.8756, -2.3, 30000000),
      _createMockMarket('DOT', 'USDT', 7.234, 0.2, 25000000),
      _createMockMarket('AVAX', 'USDT', 35.67, 4.5, 20000000),
    ];

    _cachedMarkets = mockMarkets;
    _updateMarketsMap();
    _emitUpdates();

    return mockMarkets;
  }

  MarketDataEntity _createMockMarket(
    String currency,
    String pair,
    double price,
    double changePercent,
    double volume,
  ) {
    final symbol = '$currency/$pair';

    final market = MarketEntity(
      id: '${currency}_$pair',
      symbol: symbol,
      currency: currency,
      pair: pair,
      limits: MarketLimitsEntity(
        minAmount: 0.001,
        maxAmount: 10000,
        minPrice: 0.01,
        maxPrice: 1000000,
        minCost: 10,
        maxCost: 1000000,
      ),
      precision: MarketPrecisionEntity(
        amount: 8,
        price: 2,
      ),
      taker: 0.001,
      maker: 0.001,
      isTrending: changePercent.abs() > 3,
      isHot: volume > 100000000,
      isEco: false,
      status: true,
    );

    final ticker = TickerEntity(
      symbol: symbol,
      last: price,
      baseVolume: volume / price,
      quoteVolume: volume,
      change: changePercent / 100,
    );

    return MarketDataEntity(
      market: market,
      ticker: ticker,
    );
  }
}
