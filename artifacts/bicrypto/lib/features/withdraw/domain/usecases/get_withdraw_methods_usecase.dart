import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/withdraw_method_entity.dart';
import '../repositories/withdraw_repository.dart';

class GetWithdrawMethodsParams extends Equatable {
  final String walletType;
  final String currency;

  const GetWithdrawMethodsParams({
    required this.walletType,
    required this.currency,
  });

  @override
  List<Object?> get props => [walletType, currency];
}

@injectable
class GetWithdrawMethodsUseCase
    implements UseCase<List<WithdrawMethodEntity>, GetWithdrawMethodsParams> {
  final WithdrawRepository _repository;

  const GetWithdrawMethodsUseCase(this._repository);

  @override
  Future<Either<Failure, List<WithdrawMethodEntity>>> call(
      GetWithdrawMethodsParams params) async {
    // Validate inputs
    if (params.walletType.isEmpty || params.currency.isEmpty) {
      return Left(ValidationFailure('Wallet type and currency are required'));
    }

    return await _repository.getWithdrawMethods(
      walletType: params.walletType,
      currency: params.currency,
    );
  }
}
