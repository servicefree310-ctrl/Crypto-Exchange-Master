import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/trading_websocket_service.dart';
import '../../domain/entities/chart_entity.dart';
import '../../domain/repositories/chart_repository.dart';
import '../../../market/domain/entities/ticker_entity.dart';
import '../datasources/chart_remote_datasource.dart';
import '../models/ohlcv_model.dart';

@Injectable(as: ChartRepository)
class ChartRepositoryImpl implements ChartRepository {
  final ChartRemoteDataSource _remoteDataSource;
  final TradingWebSocketService _tradingWebSocketService;
  final NetworkInfo _networkInfo;

  const ChartRepositoryImpl(
    this._remoteDataSource,
    this._tradingWebSocketService,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<ChartDataPoint>>> getChartHistory({
    required String symbol,
    required ChartTimeframe interval,
    int? from,
    int? to,
    int? limit,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch OHLCV data from remote source
      final ohlcvList = await _remoteDataSource.getChartHistory(
        symbol: symbol,
        interval: interval,
        from: from,
        to: to,
        limit: limit,
      );

      // Convert to ChartDataPoint entities
      final chartDataPoints =
          ohlcvList.map((ohlcv) => ohlcv.toChartDataPoint()).toList();

      return Right(chartDataPoints);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch chart history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VolumeDataPoint>>> getVolumeHistory({
    required String symbol,
    required ChartTimeframe interval,
    int? from,
    int? to,
    int? limit,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch OHLCV data from remote source
      final ohlcvList = await _remoteDataSource.getChartHistory(
        symbol: symbol,
        interval: interval,
        from: from,
        to: to,
        limit: limit,
      );

      // Convert to VolumeDataPoint entities
      final volumeDataPoints =
          ohlcvList.map((ohlcv) => ohlcv.toVolumeDataPoint()).toList();

      return Right(volumeDataPoints);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch volume history: $e'));
    }
  }

  @override
  Stream<TickerEntity> getRealtimeTicker(String symbol) {
    try {
      return _tradingWebSocketService
          .subscribeToSymbolTicker(symbol)
          .map((marketData) => marketData.ticker!)
          .where((ticker) => ticker != null)
          .cast<TickerEntity>();
    } catch (e) {
      // Return empty stream on error
      return const Stream.empty();
    }
  }
}
