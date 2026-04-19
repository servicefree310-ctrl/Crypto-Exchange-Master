import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_trades_repository.dart';

@injectable
class SendTradeMessageUseCase implements UseCase<void, SendTradeMessageParams> {
  const SendTradeMessageUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, void>> call(SendTradeMessageParams params) async {
    if (params.tradeId.isEmpty) {
      return const Left(ValidationFailure('Trade ID cannot be empty'));
    }
    if (params.message.trim().isEmpty) {
      return const Left(ValidationFailure('Message cannot be empty'));
    }
    return _repository.sendTradeMessage(
      tradeId: params.tradeId,
      message: params.message,
    );
  }
}

class SendTradeMessageParams {
  const SendTradeMessageParams({required this.tradeId, required this.message});
  final String tradeId;
  final String message;
}
