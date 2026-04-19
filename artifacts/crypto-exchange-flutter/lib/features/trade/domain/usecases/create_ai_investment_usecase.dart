import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_investment_entity.dart';
import '../repositories/ai_investment_repository.dart';

@injectable
class CreateAiInvestmentUseCase
    implements UseCase<AiInvestmentEntity, CreateAiInvestmentParams> {
  const CreateAiInvestmentUseCase(this._repository);

  final AiInvestmentRepository _repository;

  @override
  Future<Either<Failure, AiInvestmentEntity>> call(
      CreateAiInvestmentParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.createAiInvestment(
      planId: params.planId,
      durationId: params.durationId,
      symbol: params.symbol,
      amount: params.amount,
      walletType: params.walletType,
    );
  }

  ValidationFailure? _validateParams(CreateAiInvestmentParams params) {
    if (params.planId.isEmpty) {
      return const ValidationFailure('Plan ID is required');
    }
    if (params.durationId.isEmpty) {
      return const ValidationFailure('Duration ID is required');
    }
    if (params.symbol.isEmpty) {
      return const ValidationFailure('Symbol is required');
    }
    if (params.amount <= 0) {
      return const ValidationFailure('Amount must be greater than 0');
    }
    if (params.walletType.isEmpty) {
      return const ValidationFailure('Wallet type is required');
    }

    return null;
  }
}

class CreateAiInvestmentParams extends Equatable {
  const CreateAiInvestmentParams({
    required this.planId,
    required this.durationId,
    required this.symbol,
    required this.amount,
    required this.walletType,
  });

  final String planId;
  final String durationId;
  final String symbol;
  final double amount;
  final String walletType; // SPOT, ECO

  @override
  List<Object?> get props => [planId, durationId, symbol, amount, walletType];

  CreateAiInvestmentParams copyWith({
    String? planId,
    String? durationId,
    String? symbol,
    double? amount,
    String? walletType,
  }) {
    return CreateAiInvestmentParams(
      planId: planId ?? this.planId,
      durationId: durationId ?? this.durationId,
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
      walletType: walletType ?? this.walletType,
    );
  }
}
