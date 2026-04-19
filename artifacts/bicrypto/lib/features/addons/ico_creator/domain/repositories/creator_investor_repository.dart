import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/creator_investor_entity.dart';

abstract class CreatorInvestorRepository {
  Future<Either<Failure, List<CreatorInvestorEntity>>> getInvestors({
    int page = 1,
    int limit = 10,
    String? sortField,
    String? sortDirection,
    String? search,
  });
}
