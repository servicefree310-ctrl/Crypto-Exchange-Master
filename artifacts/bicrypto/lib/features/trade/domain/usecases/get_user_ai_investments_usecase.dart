import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_investment_entity.dart';
import '../repositories/ai_investment_repository.dart';

@injectable
class GetUserAiInvestmentsUseCase
    implements UseCase<List<AiInvestmentEntity>, GetUserAiInvestmentsParams> {
  const GetUserAiInvestmentsUseCase(this._repository);

  final AiInvestmentRepository _repository;

  @override
  Future<Either<Failure, List<AiInvestmentEntity>>> call(
      GetUserAiInvestmentsParams params) async {
    return await _repository.getUserAiInvestments(
      status: params.status,
      type: params.type,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserAiInvestmentsParams extends Equatable {
  const GetUserAiInvestmentsParams({
    this.status,
    this.type,
    this.limit,
    this.offset,
  });

  final String? status;
  final String? type;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [status, type, limit, offset];

  GetUserAiInvestmentsParams copyWith({
    String? status,
    String? type,
    int? limit,
    int? offset,
  }) {
    return GetUserAiInvestmentsParams(
      status: status ?? this.status,
      type: type ?? this.type,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
