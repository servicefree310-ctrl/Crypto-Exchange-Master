import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transfer/domain/entities/currency_option_entity.dart';
import '../repositories/withdraw_repository.dart';

class GetWithdrawCurrenciesParams extends Equatable {
  final String walletType;

  const GetWithdrawCurrenciesParams({
    required this.walletType,
  });

  @override
  List<Object?> get props => [walletType];
}

@injectable
class GetWithdrawCurrenciesUseCase
    implements
        UseCase<List<CurrencyOptionEntity>, GetWithdrawCurrenciesParams> {
  final WithdrawRepository _repository;

  const GetWithdrawCurrenciesUseCase(this._repository);

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> call(
      GetWithdrawCurrenciesParams params) async {
    // Validate wallet type
    final validWalletTypes = ['FIAT', 'SPOT', 'ECO'];
    if (!validWalletTypes.contains(params.walletType)) {
      return Left(
          ValidationFailure('Invalid wallet type: ${params.walletType}'));
    }

    return await _repository.getWithdrawCurrencies(
      walletType: params.walletType,
    );
  }
}
