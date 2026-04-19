import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/trading_websocket_service.dart';
import '../../../../core/usecases/stream_usecase.dart';
import '../../presentation/bloc/order_book_bloc.dart';

/// Use case for getting real-time order book stream
@injectable
class GetRealtimeOrderbookUseCase
    implements StreamUseCase<OrderBookData, String> {
  final TradingWebSocketService _tradingWebSocketService;

  GetRealtimeOrderbookUseCase(this._tradingWebSocketService);

  @override
  Stream<Either<Failure, OrderBookData>> call(String symbol) {
    // Just return the stream wrapped in Right - no need to connect as it's handled globally
    return _tradingWebSocketService.orderBookStream
        .where((data) => _tradingWebSocketService.currentSymbol == symbol)
        .map((data) => Right<Failure, OrderBookData>(data));
  }
}
