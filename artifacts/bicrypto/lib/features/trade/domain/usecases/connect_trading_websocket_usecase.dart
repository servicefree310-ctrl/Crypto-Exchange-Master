import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/trading_websocket_service.dart';

class ConnectTradingWebSocketParams {
  final String symbol;

  ConnectTradingWebSocketParams({
    required this.symbol,
  });
}

/// Use case for connecting to trading WebSocket - Updated to use changeSymbol
@injectable
class ConnectTradingWebSocketUseCase
    implements UseCase<void, ConnectTradingWebSocketParams> {
  final TradingWebSocketService _tradingWebSocketService;

  ConnectTradingWebSocketUseCase(this._tradingWebSocketService);

  @override
  Future<Either<Failure, void>> call(
      ConnectTradingWebSocketParams params) async {
    try {
      // Use changeSymbol instead of deprecated connect method
      await _tradingWebSocketService.changeSymbol(params.symbol);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to change symbol: ${e.toString()}'));
    }
  }
}
