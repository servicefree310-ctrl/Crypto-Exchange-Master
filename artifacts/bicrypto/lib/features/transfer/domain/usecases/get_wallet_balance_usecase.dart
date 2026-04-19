import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency_option_entity.dart';
import '../repositories/transfer_repository.dart';

class GetWalletBalanceParams extends Equatable {
  final String walletType;

  const GetWalletBalanceParams({
    required this.walletType,
  });

  @override
  List<Object?> get props => [walletType];
}

@injectable
class GetWalletBalanceUseCase
    implements UseCase<List<CurrencyOptionEntity>, GetWalletBalanceParams> {
  final TransferRepository _repository;

  const GetWalletBalanceUseCase(this._repository);

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> call(
      GetWalletBalanceParams params) async {
    // Validate input parameters
    if (params.walletType.isEmpty) {
      return Left(ValidationFailure('Wallet type is required'));
    }

    // Business logic: Validate wallet type format
    final validWalletTypes = ['FIAT', 'SPOT', 'ECO', 'FUTURES'];
    if (!validWalletTypes.contains(params.walletType)) {
      return Left(
          ValidationFailure('Invalid wallet type: ${params.walletType}'));
    }

    // Execute repository call
    return await _repository.getWalletBalance(
      walletType: params.walletType,
    );
  }
}
