import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../chart/domain/entities/chart_entity.dart';
import '../../../chart/domain/repositories/chart_repository.dart';

@injectable
class GetTradingChartHistoryUseCase
    implements UseCase<List<ChartDataPoint>, GetTradingChartHistoryParams> {
  final ChartRepository _repository;

  const GetTradingChartHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<ChartDataPoint>>> call(
    GetTradingChartHistoryParams params,
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

class GetTradingChartHistoryParams extends Equatable {
  final String symbol;
  final ChartTimeframe interval;
  final int? from;
  final int? to;
  final int? limit;

  const GetTradingChartHistoryParams({
    required this.symbol,
    required this.interval,
    this.from,
    this.to,
    this.limit,
  });

  @override
  List<Object?> get props => [symbol, interval, from, to, limit];
}
