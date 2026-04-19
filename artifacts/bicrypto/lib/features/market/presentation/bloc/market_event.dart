part of 'market_bloc.dart';

// Events
abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class MarketLoadRequested extends MarketEvent {
  const MarketLoadRequested();
}

class MarketFilterChanged extends MarketEvent {
  const MarketFilterChanged({required this.filter});

  final String filter;

  @override
  List<Object?> get props => [filter];
}

class MarketSearchRequested extends MarketEvent {
  const MarketSearchRequested({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class MarketRefreshRequested extends MarketEvent {
  const MarketRefreshRequested();
}

class MarketCategoryChanged extends MarketEvent {
  const MarketCategoryChanged({required this.category});

  final String category;

  @override
  List<Object?> get props => [category];
}

// Real-time events
class MarketStartRealtimeRequested extends MarketEvent {
  const MarketStartRealtimeRequested();
}

class MarketStopRealtimeRequested extends MarketEvent {
  const MarketStopRealtimeRequested();
}

class MarketRealtimeDataReceived extends MarketEvent {
  const MarketRealtimeDataReceived({required this.markets});

  final List<MarketDataEntity> markets;

  @override
  List<Object?> get props => [markets];
}

class MarketConnectionStatusChanged extends MarketEvent {
  const MarketConnectionStatusChanged({required this.status});

  final WebSocketConnectionStatus status;

  @override
  List<Object?> get props => [status];
}
