import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chart_entity.dart';
import '../../../market/domain/entities/ticker_entity.dart';

abstract class ChartRepository {
  /// Get chart history data for a specific symbol and timeframe
  Future<Either<Failure, List<ChartDataPoint>>> getChartHistory({
    required String symbol,
    required ChartTimeframe interval,
    int? from,
    int? to,
    int? limit,
  });

  /// Get volume data for a specific symbol and timeframe
  Future<Either<Failure, List<VolumeDataPoint>>> getVolumeHistory({
    required String symbol,
    required ChartTimeframe interval,
    int? from,
    int? to,
    int? limit,
  });

  /// Get realtime ticker data for chart updates
  Stream<TickerEntity> getRealtimeTicker(String symbol);
}
