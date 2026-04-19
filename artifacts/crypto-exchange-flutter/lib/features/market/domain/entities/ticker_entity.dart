import 'package:equatable/equatable.dart';

class TickerEntity extends Equatable {
  const TickerEntity({
    required this.symbol,
    required this.last,
    required this.baseVolume,
    required this.quoteVolume,
    required this.change,
    this.bid,
    this.ask,
    this.high,
    this.low,
    this.open,
    this.close,
  });

  final String symbol;
  final double last;
  final double baseVolume;
  final double quoteVolume;
  final double change;
  final double? bid;
  final double? ask;
  final double? high;
  final double? low;
  final double? open;
  final double? close;

  // Computed properties
  double get changePercent => change * 100;
  bool get isPositive => change >= 0;
  bool get isNegative => change < 0;

  @override
  List<Object?> get props => [
        symbol,
        last,
        baseVolume,
        quoteVolume,
        change,
        bid,
        ask,
        high,
        low,
        open,
        close,
      ];

  TickerEntity copyWith({
    String? symbol,
    double? last,
    double? baseVolume,
    double? quoteVolume,
    double? change,
    double? bid,
    double? ask,
    double? high,
    double? low,
    double? open,
    double? close,
  }) {
    return TickerEntity(
      symbol: symbol ?? this.symbol,
      last: last ?? this.last,
      baseVolume: baseVolume ?? this.baseVolume,
      quoteVolume: quoteVolume ?? this.quoteVolume,
      change: change ?? this.change,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      close: close ?? this.close,
    );
  }
}
