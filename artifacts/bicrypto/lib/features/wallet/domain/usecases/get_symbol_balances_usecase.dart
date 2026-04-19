import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class GetSymbolBalancesParams extends Equatable {
  const GetSymbolBalancesParams({
    required this.type,
    required this.currency,
    required this.pair,
  });

  final String type; // SPOT
  final String currency;
  final String pair;

  @override
  List<Object?> get props => [type, currency, pair];
}

@injectable
class GetSymbolBalancesUseCase
    implements UseCase<Map<String, double>, GetSymbolBalancesParams> {
  const GetSymbolBalancesUseCase(this._repository);

  final WalletRepository _repository;

  @override
  Future<Either<Failure, Map<String, double>>> call(
      GetSymbolBalancesParams params) {
    return _repository.getSymbolBalances(
      type: params.type,
      currency: params.currency,
      pair: params.pair,
    );
  }
}
