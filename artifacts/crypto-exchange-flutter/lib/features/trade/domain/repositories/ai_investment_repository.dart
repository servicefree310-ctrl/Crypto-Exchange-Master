import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ai_investment_plan_entity.dart';
import '../entities/ai_investment_entity.dart';

abstract class AiInvestmentRepository {
  /// Get all available AI investment plans
  Future<Either<Failure, List<AiInvestmentPlanEntity>>> getAiInvestmentPlans();

  /// Get user's AI investments with optional filtering
  Future<Either<Failure, List<AiInvestmentEntity>>> getUserAiInvestments({
    String? status,
    String? type,
    int? limit,
    int? offset,
  });

  /// Get specific AI investment by ID
  Future<Either<Failure, AiInvestmentEntity>> getAiInvestmentById(String id);

  /// Create a new AI investment
  Future<Either<Failure, AiInvestmentEntity>> createAiInvestment({
    required String planId,
    required String durationId,
    required String symbol,
    required double amount,
    required String walletType, // SPOT, ECO
  });

  /// Cancel an active AI investment
  Future<Either<Failure, void>> cancelAiInvestment(String id);
}
