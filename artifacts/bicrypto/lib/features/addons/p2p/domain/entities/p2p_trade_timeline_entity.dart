import 'package:equatable/equatable.dart';

import 'p2p_trade_entity.dart';

class TradeTimeline extends Equatable {
  const TradeTimeline({
    required this.events,
    this.totalEvents,
  });

  final List<P2PTradeTimelineEntity> events;
  final int? totalEvents;

  @override
  List<Object?> get props => [events, totalEvents];

  TradeTimeline copyWith({
    List<P2PTradeTimelineEntity>? events,
    int? totalEvents,
  }) {
    return TradeTimeline(
      events: events ?? this.events,
      totalEvents: totalEvents ?? this.totalEvents,
    );
  }
}
