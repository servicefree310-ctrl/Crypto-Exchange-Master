part of 'market_bloc.dart';

// States
abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

class MarketInitial extends MarketState {
  const MarketInitial();
}

class MarketLoading extends MarketState {
  const MarketLoading();
}

class MarketLoaded extends MarketState {
  const MarketLoaded({
    required this.markets,
    required this.filteredMarkets,
    this.availableCategories = const ['All'],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isRealtime = false,
    this.connectionStatus,
  });

  final List<MarketDataEntity> markets;
  final List<MarketDataEntity> filteredMarkets;
  final List<String> availableCategories;
  final bool isLoading;
  final bool isRefreshing;
  final bool isRealtime;
  final WebSocketConnectionStatus? connectionStatus;

  @override
  List<Object?> get props => [
        markets,
        filteredMarkets,
        availableCategories,
        isLoading,
        isRefreshing,
        isRealtime,
        connectionStatus,
      ];

  MarketLoaded copyWith({
    List<MarketDataEntity>? markets,
    List<MarketDataEntity>? filteredMarkets,
    List<String>? availableCategories,
    bool? isLoading,
    bool? isRefreshing,
    bool? isRealtime,
    WebSocketConnectionStatus? connectionStatus,
  }) {
    return MarketLoaded(
      markets: markets ?? this.markets,
      filteredMarkets: filteredMarkets ?? this.filteredMarkets,
      availableCategories: availableCategories ?? this.availableCategories,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isRealtime: isRealtime ?? this.isRealtime,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}

class MarketError extends MarketState {
  const MarketError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
