import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_investment_plan_entity.dart';
import '../repositories/ai_investment_repository.dart';

@injectable
class GetAiInvestmentPlansUseCase
    implements UseCase<List<AiInvestmentPlanEntity>, NoParams> {
  const GetAiInvestmentPlansUseCase(this._repository);

  final AiInvestmentRepository _repository;

  @override
  Future<Either<Failure, List<AiInvestmentPlanEntity>>> call(
      NoParams params) async {
    return await _repository.getAiInvestmentPlans();
  }
}
