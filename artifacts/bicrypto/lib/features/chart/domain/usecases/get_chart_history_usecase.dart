import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chart_entity.dart';
import '../repositories/chart_repository.dart';

@injectable
class GetChartHistoryUseCase
    implements UseCase<List<ChartDataPoint>, GetChartHistoryParams> {
  final ChartRepository _repository;

  const GetChartHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<ChartDataPoint>>> call(
    GetChartHistoryParams params,
  ) async {
    return await _repository.getChartHistory(
      symbol: params.symbol,
      interval: params.interval,
      from: params.from,
      to: params.to,
      limit: params.limit,
    );
  }
}

class GetChartHistoryParams extends Equatable {
  final String symbol;
  final ChartTimeframe interval;
  final int? from;
  final int? to;
  final int? limit;

  const GetChartHistoryParams({
    required this.symbol,
    required this.interval,
    this.from,
    this.to,
    this.limit,
  });

  @override
  List<Object?> get props => [symbol, interval, from, to, limit];
}
