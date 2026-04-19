import '../../domain/entities/chart_entity.dart';

class OhlcvModel {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const OhlcvModel({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory OhlcvModel.fromJson(Map<String, dynamic> json) {
    return OhlcvModel(
      timestamp: json['timestamp'] as int,
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }

  /// Creates OhlcvModel from v5 backend array format:
  /// [timestamp, open, high, low, close, volume]
  factory OhlcvModel.fromArray(List<dynamic> array) {
    if (array.length < 6) {
      throw ArgumentError('OHLCV array must have at least 6 elements');
    }

    return OhlcvModel(
      timestamp: (array[0] as num).toInt(),
      open: (array[1] as num).toDouble(),
      high: (array[2] as num).toDouble(),
      low: (array[3] as num).toDouble(),
      close: (array[4] as num).toDouble(),
      volume: (array[5] as num).toDouble(),
    );
  }

  /// Converts to k_chart_plus compatible format
  /// KLineEntity requires: timestamp, open, high, low, close, vol
  Map<String, dynamic> toKLineEntity() {
    return {
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'vol': volume,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}

extension OhlcvModelX on OhlcvModel {
  /// Converts to ChartDataPoint entity
  ChartDataPoint toChartDataPoint() {
    return ChartDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      open: open,
      high: high,
      low: low,
      close: close,
    );
  }

  /// Converts to VolumeDataPoint entity
  VolumeDataPoint toVolumeDataPoint() {
    return VolumeDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      volume: volume,
    );
  }
}
