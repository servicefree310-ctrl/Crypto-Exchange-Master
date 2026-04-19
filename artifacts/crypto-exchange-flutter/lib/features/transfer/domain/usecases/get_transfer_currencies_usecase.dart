import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency_option_entity.dart';
import '../repositories/transfer_repository.dart';

class GetTransferCurrenciesParams extends Equatable {
  final String walletType;
  final String? targetWalletType;

  const GetTransferCurrenciesParams({
    required this.walletType,
    this.targetWalletType,
  });

  @override
  List<Object?> get props => [walletType, targetWalletType];
}

@injectable
class GetTransferCurrenciesUseCase
    implements
        UseCase<List<CurrencyOptionEntity>, GetTransferCurrenciesParams> {
  final TransferRepository _repository;

  const GetTransferCurrenciesUseCase(this._repository);

  @override
  Future<Either<Failure, List<CurrencyOptionEntity>>> call(
      GetTransferCurrenciesParams params) async {
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

    // Validate target wallet type if provided
    if (params.targetWalletType != null) {
      if (!validWalletTypes.contains(params.targetWalletType)) {
        return Left(ValidationFailure(
            'Invalid target wallet type: ${params.targetWalletType}'));
      }
    }

    // Execute repository call
    return await _repository.getTransferCurrencies(
      walletType: params.walletType,
      targetWalletType: params.targetWalletType,
    );
  }
}
