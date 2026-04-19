import 'package:equatable/equatable.dart';

class ChartEntity extends Equatable {
  const ChartEntity({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.marketCap,
    this.priceData = const [],
    this.volumeData = const [],
    this.bidsData = const [],
    this.asksData = const [],
    this.tradesData = const [],
  });

  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double marketCap;
  final List<ChartDataPoint> priceData;
  final List<VolumeDataPoint> volumeData;
  final List<DepthDataPoint> bidsData;
  final List<DepthDataPoint> asksData;
  final List<TradeDataPoint> tradesData;

  bool get isPositive => change >= 0;

  String get formattedPrice => '\$${price.toStringAsFixed(8)}';
  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
  String get formattedVolume => _formatLargeNumber(volume24h);
  String get formattedMarketCap => _formatLargeNumber(marketCap);

  String _formatLargeNumber(double value) {
    if (value >= 1e9) {
      return '\$${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '\$${(value / 1e6).toStringAsFixed(2)}M';
    } else if (value >= 1e3) {
      return '\$${(value / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        symbol,
        price,
        change,
        changePercent,
        high24h,
        low24h,
        volume24h,
        marketCap,
        priceData,
        volumeData,
        bidsData,
        asksData,
        tradesData,
      ];

  ChartEntity copyWith({
    String? symbol,
    double? price,
    double? change,
    double? changePercent,
    double? high24h,
    double? low24h,
    double? volume24h,
    double? marketCap,
    List<ChartDataPoint>? priceData,
    List<VolumeDataPoint>? volumeData,
    List<DepthDataPoint>? bidsData,
    List<DepthDataPoint>? asksData,
    List<TradeDataPoint>? tradesData,
  }) {
    return ChartEntity(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      marketCap: marketCap ?? this.marketCap,
      priceData: priceData ?? this.priceData,
      volumeData: volumeData ?? this.volumeData,
      bidsData: bidsData ?? this.bidsData,
      asksData: asksData ?? this.asksData,
      tradesData: tradesData ?? this.tradesData,
    );
  }
}

class ChartDataPoint extends Equatable {
  const ChartDataPoint({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  @override
  List<Object> get props => [timestamp, open, high, low, close];
}

class VolumeDataPoint extends Equatable {
  const VolumeDataPoint({
    required this.timestamp,
    required this.volume,
  });

  final DateTime timestamp;
  final double volume;

  @override
  List<Object> get props => [timestamp, volume];
}

enum ChartTimeframe {
  oneMinute('1m'),
  threeMinutes('3m'),
  fiveMinutes('5m'),
  fifteenMinutes('15m'),
  thirtyMinutes('30m'),
  oneHour('1h'),
  twoHours('2h'),
  fourHours('4h'),
  sixHours('6h'),
  eightHours('8h'),
  twelveHours('12h'),
  oneDay('1d'),
  threeDays('3d'),
  oneWeek('1w'),
  oneMonth('1M');

  const ChartTimeframe(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ChartTimeframe.oneMinute:
        return '1m';
      case ChartTimeframe.threeMinutes:
        return '3m';
      case ChartTimeframe.fiveMinutes:
        return '5m';
      case ChartTimeframe.fifteenMinutes:
        return '15m';
      case ChartTimeframe.thirtyMinutes:
        return '30m';
      case ChartTimeframe.oneHour:
        return '1h';
      case ChartTimeframe.twoHours:
        return '2h';
      case ChartTimeframe.fourHours:
        return '4h';
      case ChartTimeframe.sixHours:
        return '6h';
      case ChartTimeframe.eightHours:
        return '8h';
      case ChartTimeframe.twelveHours:
        return '12h';
      case ChartTimeframe.oneDay:
        return '1D';
      case ChartTimeframe.threeDays:
        return '3D';
      case ChartTimeframe.oneWeek:
        return '1W';
      case ChartTimeframe.oneMonth:
        return '1M';
    }
  }

  /// Returns the interval in milliseconds following v5 backend logic
  int get milliseconds {
    switch (this) {
      case ChartTimeframe.oneMinute:
        return 60 * 1000;
      case ChartTimeframe.threeMinutes:
        return 3 * 60 * 1000;
      case ChartTimeframe.fiveMinutes:
        return 5 * 60 * 1000;
      case ChartTimeframe.fifteenMinutes:
        return 15 * 60 * 1000;
      case ChartTimeframe.thirtyMinutes:
        return 30 * 60 * 1000;
      case ChartTimeframe.oneHour:
        return 60 * 60 * 1000;
      case ChartTimeframe.twoHours:
        return 2 * 60 * 60 * 1000;
      case ChartTimeframe.fourHours:
        return 4 * 60 * 60 * 1000;
      case ChartTimeframe.sixHours:
        return 6 * 60 * 60 * 1000;
      case ChartTimeframe.eightHours:
        return 8 * 60 * 60 * 1000;
      case ChartTimeframe.twelveHours:
        return 12 * 60 * 60 * 1000;
      case ChartTimeframe.oneDay:
        return 24 * 60 * 60 * 1000;
      case ChartTimeframe.threeDays:
        return 3 * 24 * 60 * 60 * 1000;
      case ChartTimeframe.oneWeek:
        return 7 * 24 * 60 * 60 * 1000;
      case ChartTimeframe.oneMonth:
        return 30 * 24 * 60 * 60 * 1000;
    }
  }

  /// Returns exchange-specific supported intervals based on provider
  static List<ChartTimeframe> getSupportedTimeframes(String exchangeProvider) {
    switch (exchangeProvider.toLowerCase()) {
      case 'bin': // Binance
        return [
          ChartTimeframe.oneMinute,
          ChartTimeframe.threeMinutes,
          ChartTimeframe.fiveMinutes,
          ChartTimeframe.fifteenMinutes,
          ChartTimeframe.thirtyMinutes,
          ChartTimeframe.oneHour,
          ChartTimeframe.twoHours,
          ChartTimeframe.fourHours,
          ChartTimeframe.sixHours,
          ChartTimeframe.eightHours,
          ChartTimeframe.twelveHours,
          ChartTimeframe.oneDay,
          ChartTimeframe.threeDays,
          ChartTimeframe.oneWeek,
          ChartTimeframe.oneMonth,
        ];
      case 'kuc': // KuCoin
        return [
          ChartTimeframe.oneMinute,
          ChartTimeframe.threeMinutes,
          ChartTimeframe.fiveMinutes,
          ChartTimeframe.fifteenMinutes,
          ChartTimeframe.thirtyMinutes,
          ChartTimeframe.oneHour,
          ChartTimeframe.twoHours,
          ChartTimeframe.fourHours,
          ChartTimeframe.sixHours,
          ChartTimeframe.eightHours,
          ChartTimeframe.twelveHours,
          ChartTimeframe.oneDay,
          ChartTimeframe.oneWeek,
        ];
      case 'okx': // OKX
        return [
          ChartTimeframe.oneMinute,
          ChartTimeframe.threeMinutes,
          ChartTimeframe.fiveMinutes,
          ChartTimeframe.fifteenMinutes,
          ChartTimeframe.thirtyMinutes,
          ChartTimeframe.oneHour,
          ChartTimeframe.twoHours,
          ChartTimeframe.fourHours,
          ChartTimeframe.sixHours,
          ChartTimeframe.twelveHours,
          ChartTimeframe.oneDay,
          ChartTimeframe.threeDays,
          ChartTimeframe.oneWeek,
          ChartTimeframe.oneMonth,
        ];
      case 'xt ': // XT
        return [
          ChartTimeframe.oneMinute,
          ChartTimeframe.fiveMinutes,
          ChartTimeframe.fifteenMinutes,
          ChartTimeframe.thirtyMinutes,
          ChartTimeframe.oneHour,
          ChartTimeframe.fourHours,
          ChartTimeframe.oneDay,
          ChartTimeframe.oneWeek,
        ];
      case 'kra': // Kraken
        return [
          ChartTimeframe.oneMinute,
          ChartTimeframe.fiveMinutes,
          ChartTimeframe.fifteenMinutes,
          ChartTimeframe.thirtyMinutes,
          ChartTimeframe.oneHour,
          ChartTimeframe.fourHours,
          ChartTimeframe.oneDay,
          ChartTimeframe.oneWeek,
        ];
      default: // Default to Binance intervals
        return getSupportedTimeframes('bin');
    }
  }
}

enum ChartType {
  candlestick,
  line,
  area,
  depth;

  String get displayName {
    switch (this) {
      case ChartType.candlestick:
        return 'Candlestick';
      case ChartType.line:
        return 'Line';
      case ChartType.area:
        return 'Area';
      case ChartType.depth:
        return 'Depth';
    }
  }
}

class DepthDataPoint extends Equatable {
  const DepthDataPoint({
    required this.price,
    required this.volume,
  });

  final double price;
  final double volume;

  @override
  List<Object> get props => [price, volume];
}

class TradeDataPoint extends Equatable {
  const TradeDataPoint({
    required this.price,
    required this.amount,
    required this.timestamp,
    required this.isBuy,
  });

  final double price;
  final double amount;
  final DateTime timestamp;
  final bool isBuy;

  @override
  List<Object> get props => [price, amount, timestamp, isBuy];
}
