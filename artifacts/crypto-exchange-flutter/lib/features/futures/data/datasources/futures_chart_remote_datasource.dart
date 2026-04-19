import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../chart/domain/entities/chart_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

abstract class FuturesChartRemoteDataSource {
  Future<List<ChartDataPoint>> getChartData({
    required String symbol,
    required ChartTimeframe interval,
  });
}

@Injectable(as: FuturesChartRemoteDataSource)
class FuturesChartRemoteDataSourceImpl implements FuturesChartRemoteDataSource {
  const FuturesChartRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<ChartDataPoint>> getChartData({
    required String symbol,
    required ChartTimeframe interval,
  }) async {
    // Calculate from and to timestamps
    final now = DateTime.now();
    final to = now.millisecondsSinceEpoch;
    final from = _calculateFromTimestamp(now, interval);

    final response = await _client.get(
      ApiConstants.futuresChart,
      queryParameters: {
        'symbol': symbol,
        'interval': interval.value,
        'from': from,
        'to': to,
      },
    );

    // The API returns an array of arrays: [[timestamp, open, high, low, close, volume], ...]
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['data'] as List<dynamic>);

    return data.map((candle) {
      final List<dynamic> candleData = candle as List<dynamic>;
      return ChartDataPoint(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          _toInt(candleData[0]),
        ),
        open: _toDouble(candleData[1]),
        high: _toDouble(candleData[2]),
        low: _toDouble(candleData[3]),
        close: _toDouble(candleData[4]),
      );
    }).toList();
  }

  int _calculateFromTimestamp(DateTime now, ChartTimeframe interval) {
    Duration duration;

    switch (interval) {
      case ChartTimeframe.oneMinute:
        duration = const Duration(hours: 2);
        break;
      case ChartTimeframe.fiveMinutes:
        duration = const Duration(hours: 6);
        break;
      case ChartTimeframe.fifteenMinutes:
        duration = const Duration(hours: 12);
        break;
      case ChartTimeframe.thirtyMinutes:
        duration = const Duration(days: 1);
        break;
      case ChartTimeframe.oneHour:
        duration = const Duration(days: 2);
        break;
      case ChartTimeframe.fourHours:
        duration = const Duration(days: 7);
        break;
      case ChartTimeframe.oneDay:
        duration = const Duration(days: 30);
        break;
      case ChartTimeframe.oneWeek:
        duration = const Duration(days: 180);
        break;
      case ChartTimeframe.oneMonth:
        duration = const Duration(days: 365 * 2);
        break;
      default:
        duration = const Duration(days: 1);
    }

    return now.subtract(duration).millisecondsSinceEpoch;
  }
}
