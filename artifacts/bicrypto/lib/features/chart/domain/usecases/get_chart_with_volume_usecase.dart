import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chart_entity.dart';
import '../repositories/chart_repository.dart';

@injectable
class GetChartWithVolumeUseCase
    implements UseCase<ChartWithVolumeData, GetChartWithVolumeParams> {
  final ChartRepository _repository;

  const GetChartWithVolumeUseCase(this._repository);

  @override
  Future<Either<Failure, ChartWithVolumeData>> call(
    GetChartWithVolumeParams params,
  ) async {
    try {
      // Fetch chart history data
      final chartResult = await _repository.getChartHistory(
        symbol: params.symbol,
        interval: params.interval,
        from: params.from,
        to: params.to,
        limit: params.limit,
      );

      return chartResult.fold(
        (failure) => Left(failure),
        (chartDataPoints) async {
          // Fetch volume history data
          final volumeResult = await _repository.getVolumeHistory(
            symbol: params.symbol,
            interval: params.interval,
            from: params.from,
            to: params.to,
            limit: params.limit,
          );

          return volumeResult.fold(
            (failure) => Left(failure),
            (volumeDataPoints) => Right(
              ChartWithVolumeData(
                chartDataPoints: chartDataPoints,
                volumeDataPoints: volumeDataPoints,
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to fetch chart with volume data: $e'));
    }
  }
}

class GetChartWithVolumeParams extends Equatable {
  final String symbol;
  final ChartTimeframe interval;
  final int? from;
  final int? to;
  final int? limit;

  const GetChartWithVolumeParams({
    required this.symbol,
    required this.interval,
    this.from,
    this.to,
    this.limit,
  });

  @override
  List<Object?> get props => [symbol, interval, from, to, limit];
}

class ChartWithVolumeData extends Equatable {
  final List<ChartDataPoint> chartDataPoints;
  final List<VolumeDataPoint> volumeDataPoints;

  const ChartWithVolumeData({
    required this.chartDataPoints,
    required this.volumeDataPoints,
  });

  @override
  List<Object> get props => [chartDataPoints, volumeDataPoints];
}
