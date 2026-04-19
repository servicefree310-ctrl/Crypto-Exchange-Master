import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/futures_websocket_service.dart';
import '../../../../core/services/maintenance_service.dart';
import '../../../../injection/injection.dart';
import '../../../wallet/domain/usecases/get_wallet_balance_usecase.dart';
import '../../domain/usecases/get_futures_markets_usecase.dart';
import '../../domain/entities/futures_market_entity.dart';
import 'futures_header_event.dart';
import 'futures_header_state.dart';

@injectable
class FuturesHeaderBloc extends Bloc<FuturesHeaderEvent, FuturesHeaderState> {
  FuturesHeaderBloc(
    this._getMarketsUseCase,
    this._wsService,
    this._getWalletBalanceUseCase,
  ) : super(const FuturesHeaderInitial()) {
    on<FuturesHeaderInitialized>(_onInit);
    on<FuturesHeaderSymbolChanged>(_onSymbolChanged);
    on<FuturesTickerUpdated>(_onTicker);

    // Start timer for funding countdown updates
    _fundingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is FuturesHeaderLoaded) {
        _emitUpdatedState();
      }
    });
  }

  final GetFuturesMarketsUseCase _getMarketsUseCase;
  final FuturesWebSocketService _wsService;
  final GetCurrencyWalletBalanceUseCase _getWalletBalanceUseCase;
  final MaintenanceService _maintenanceService = getIt<MaintenanceService>();

  StreamSubscription? _tickerSub;
  Timer? _fundingTimer;

  // Internal state
  String _currentSymbol = '';
  double _currentPrice = 0.0;
  double _fundingRate = 0.0001; // Default 0.01%
  double _availableBalance = 0.0;
  List<FuturesMarketEntity> _cachedMarkets = [];
  int _maxLeverage = 100; // Default max leverage
  double? _takerFee;
  double? _makerFee;

  String _calculateFundingCountdown() {
    // Calculate time until next funding (every 8 hours)
    final now = DateTime.now();
    final nextFunding = DateTime(
      now.year,
      now.month,
      now.day,
      ((now.hour ~/ 8) + 1) * 8,
    );

    final difference = nextFunding.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _onInit(
    FuturesHeaderInitialized event,
    Emitter<FuturesHeaderState> emit,
  ) async {
    emit(const FuturesHeaderLoading());

    // Check if we're in maintenance mode
    if (_maintenanceService.isInMaintenance) {
      // Emit mock data when in maintenance
      emit(FuturesHeaderLoaded(
        symbol: event.symbol ?? 'BTC/USDT',
        price: 43250.50, // Mock BTC price
        changePercent: 2.5,
        currentPrice: 43250.50,
        availableBalance: 10000.0, // Mock balance
        fundingRate: 0.01,
        fundingCountdown: _calculateFundingCountdown(),
        maxLeverage: 100,
      ));
      return;
    }

    // Load futures markets list
    final marketsResult = await _getMarketsUseCase(NoParams());

    if (marketsResult.isLeft()) {
      final failure = marketsResult.fold((l) => l, (r) => UnknownFailure(''));

      // Check if this is a maintenance failure
      _maintenanceService.handleServiceError(failure, 'FuturesHeaderBloc');

      // Emit mock data if in maintenance
      if (_maintenanceService.isInMaintenance) {
        emit(FuturesHeaderLoaded(
          symbol: event.symbol ?? 'BTC/USDT',
          price: 43250.50,
          changePercent: 2.5,
          currentPrice: 43250.50,
          availableBalance: 10000.0,
          fundingRate: 0.01,
          fundingCountdown: _calculateFundingCountdown(),
          maxLeverage: 100,
        ));
      } else {
        emit(FuturesHeaderError(message: failure.message));
      }
      return;
    }

    final markets =
        marketsResult.fold((l) => <FuturesMarketEntity>[], (r) => r);
    _cachedMarkets = markets; // Cache the markets

    // Check if markets are empty
    if (markets.isEmpty) {
      emit(const FuturesHeaderNoMarket());
      return;
    }

    // Select market to display
    // If event.symbol is provided, try to find it, otherwise use first market
    var selectedMarket = markets.first;
    if (event.symbol != null) {
      final found = markets.firstWhere(
        (m) => m.symbol == event.symbol,
        orElse: () => markets.first,
      );
      selectedMarket = found;
    }

    await _loadMarketData(selectedMarket, emit);
  }

  Future<void> _onSymbolChanged(
    FuturesHeaderSymbolChanged event,
    Emitter<FuturesHeaderState> emit,
  ) async {
    dev.log('🔄 FuturesHeaderBloc: Symbol change requested to ${event.symbol}');

    // Don't refetch markets, use cached ones
    if (_cachedMarkets.isEmpty) {
      dev.log('⚠️ FuturesHeaderBloc: No cached markets, initializing...');
      // If somehow we don't have cached markets, initialize
      add(FuturesHeaderInitialized(symbol: event.symbol));
      return;
    }

    dev.log(
        '📊 FuturesHeaderBloc: Using ${_cachedMarkets.length} cached markets');

    // Find the selected market
    final selectedMarket = _cachedMarkets.firstWhere(
      (m) => m.symbol == event.symbol,
      orElse: () {
        dev.log(
            '⚠️ FuturesHeaderBloc: Symbol ${event.symbol} not found, using first market');
        return _cachedMarkets.first;
      },
    );

    dev.log('✅ FuturesHeaderBloc: Found market: ${selectedMarket.symbol}');

    // Show loading briefly while switching
    emit(const FuturesHeaderLoading());

    await _loadMarketData(selectedMarket, emit);
  }

  Future<void> _loadMarketData(
    FuturesMarketEntity selectedMarket,
    Emitter<FuturesHeaderState> emit,
  ) async {
    dev.log(
        '📊 FuturesHeaderBloc: Loading market data for ${selectedMarket.symbol}');

    _currentSymbol = selectedMarket.symbol;
    _currentPrice = selectedMarket.price; // Initial price from API

    // Get funding rate and max leverage from metadata
    if (selectedMarket.metadata != null) {
      _fundingRate = selectedMarket.metadata!.fundingRate ?? 0.0001;
      dev.log('💰 FuturesHeaderBloc: Funding rate: ${_fundingRate * 100}%');

      // Extract max leverage from limits
      if (selectedMarket.metadata?.limits != null &&
          selectedMarket.metadata!.limits!['leverage'] != null) {
        final leverageData = selectedMarket.metadata!.limits!['leverage'];

        if (leverageData is int) {
          _maxLeverage = leverageData;
        } else if (leverageData is double) {
          _maxLeverage = leverageData.toInt();
        } else if (leverageData is String) {
          _maxLeverage = int.tryParse(leverageData) ?? 100;
        } else if (leverageData is Map && leverageData['max'] != null) {
          final maxValue = leverageData['max'];
          if (maxValue is int) {
            _maxLeverage = maxValue;
          } else if (maxValue is double) {
            _maxLeverage = maxValue.toInt();
          } else if (maxValue is String) {
            _maxLeverage = int.tryParse(maxValue) ?? 100;
          }
        }

        dev.log('🎚️ FuturesHeaderBloc: Max leverage: ${_maxLeverage}x');
      }
    }

    // Load wallet balance for FUTURES wallet
    dev.log('💳 FuturesHeaderBloc: Loading FUTURES wallet balance...');
    final walletResult = await _getWalletBalanceUseCase(
      const GetWalletBalanceParams(
        currency: 'USDT',
        walletType: 'FUTURES',
      ),
    );

    if (walletResult.isRight()) {
      _availableBalance = walletResult.fold((l) => 0.0, (r) => r);
      dev.log('💰 FuturesHeaderBloc: Wallet balance: $_availableBalance USDT');
    } else {
      dev.log('⚠️ FuturesHeaderBloc: Failed to load wallet balance');
    }

    // Connect to websocket for real-time updates
    try {
      dev.log(
          '🔌 FuturesHeaderBloc: Connecting to websocket for $_currentSymbol...');

      // Cancel previous subscription
      await _tickerSub?.cancel();

      // Connect to new symbol
      await _wsService.connect(_currentSymbol);

      // Listen to ticker updates
      _tickerSub = _wsService.tickerStream.listen((ticker) {
        // Only update if it's for our current symbol
        if (ticker.symbol == _currentSymbol) {
          add(FuturesTickerUpdated(
            price: ticker.last,
            changePercent: ticker.change * 100, // Convert decimal to percentage
          ));
        }
      });

      dev.log('✅ FuturesHeaderBloc: WebSocket connected successfully');
    } catch (e) {
      dev.log('❌ FuturesHeaderBloc: Failed to connect to websocket: $e');
      // Continue with static data if websocket fails
    }

    // Extract taker and maker fees from market metadata
    _takerFee = selectedMarket.metadata?.taker;
    _makerFee = selectedMarket.metadata?.maker;
    dev.log(
        '💰 FuturesHeaderBloc: Taker fee: $_takerFee, Maker fee: $_makerFee');

    // Emit loaded state with market data
    dev.log('🎯 FuturesHeaderBloc: Emitting loaded state for $_currentSymbol');
    emit(FuturesHeaderLoaded(
      symbol: _currentSymbol,
      price: _currentPrice,
      changePercent: selectedMarket.changePercent,
      currentPrice: _currentPrice,
      availableBalance: _availableBalance,
      fundingRate: _fundingRate * 100, // Convert to percentage for display
      fundingCountdown: _calculateFundingCountdown(),
      maxLeverage: _maxLeverage,
      takerFee: _takerFee,
      makerFee: _makerFee,
    ));
    dev.log('✅ FuturesHeaderBloc: Market data loaded successfully');
  }

  void _onTicker(
    FuturesTickerUpdated event,
    Emitter<FuturesHeaderState> emit,
  ) {
    _currentPrice = event.price;
    if (state is FuturesHeaderLoaded) {
      final loaded = state as FuturesHeaderLoaded;
      emit(FuturesHeaderLoaded(
        symbol: loaded.symbol,
        price: event.price,
        changePercent: event.changePercent,
        currentPrice: event.price,
        availableBalance: loaded.availableBalance,
        fundingRate: loaded.fundingRate,
        fundingCountdown: _calculateFundingCountdown(),
        maxLeverage: loaded.maxLeverage,
        takerFee: loaded.takerFee,
        makerFee: loaded.makerFee,
      ));
    }
  }

  void _emitUpdatedState() {
    if (state is FuturesHeaderLoaded) {
      final loaded = state as FuturesHeaderLoaded;
      emit(FuturesHeaderLoaded(
        symbol: loaded.symbol,
        price: loaded.price,
        changePercent: loaded.changePercent,
        currentPrice: loaded.currentPrice,
        availableBalance: loaded.availableBalance,
        fundingRate: loaded.fundingRate,
        fundingCountdown: _calculateFundingCountdown(),
        maxLeverage: loaded.maxLeverage,
        takerFee: loaded.takerFee,
        makerFee: loaded.makerFee,
      ));
    }
  }

  @override
  Future<void> close() {
    _tickerSub?.cancel();
    _fundingTimer?.cancel();
    return super.close();
  }
}
