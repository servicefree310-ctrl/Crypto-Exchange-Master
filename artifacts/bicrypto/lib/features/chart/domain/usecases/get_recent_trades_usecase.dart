import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chart_entity.dart';

@injectable
class GetRecentTradesUseCase
    implements UseCase<List<TradeDataPoint>, GetRecentTradesParams> {
  const GetRecentTradesUseCase();

  @override
  Future<Either<Failure, List<TradeDataPoint>>> call(
      GetRecentTradesParams params) async {
    try {
      // Business logic for processing trades
      final trades = List<TradeDataPoint>.from(params.allTrades);

      // Sort by timestamp (newest first)
      trades.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Return only the latest trades based on limit
      final recentTrades = trades.take(params.limit).toList();

      return Right(recentTrades);
    } catch (e) {
      return Left(FormatFailure('Failed to process recent trades: $e'));
    }
  }
}

class GetRecentTradesParams {
  const GetRecentTradesParams({
    required this.allTrades,
    this.limit = 20,
  });

  final List<TradeDataPoint> allTrades;
  final int limit;
}
