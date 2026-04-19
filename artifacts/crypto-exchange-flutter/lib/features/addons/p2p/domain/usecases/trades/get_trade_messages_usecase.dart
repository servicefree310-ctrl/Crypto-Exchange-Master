import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_trades_repository.dart';

@injectable
class GetTradeMessagesUseCase
    implements UseCase<List<Map<String, dynamic>>, GetTradeMessagesParams> {
  const GetTradeMessagesUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetTradeMessagesParams params) async {
    if (params.tradeId.isEmpty) {
      return const Left(ValidationFailure('Trade ID cannot be empty'));
    }
    return _repository.getTradeMessages(params.tradeId);
  }
}

class GetTradeMessagesParams {
  const GetTradeMessagesParams({required this.tradeId});
  final String tradeId;
}
