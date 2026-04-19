import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/discount_entity.dart';
import '../repositories/discount_repository.dart';

/// Parameters for validating a discount code
class ValidateDiscountParams {
  const ValidateDiscountParams({
    required this.code,
  });

  final String code;
}

/// Use case for validating discount codes
@injectable
class ValidateDiscountUseCase
    implements UseCase<DiscountEntity, ValidateDiscountParams> {
  const ValidateDiscountUseCase(this._repository);

  final DiscountRepository _repository;

  @override
  Future<Either<Failure, DiscountEntity>> call(
      ValidateDiscountParams params) async {
    // Validate input
    if (params.code.trim().isEmpty) {
      return const Left(ValidationFailure('Discount code cannot be empty'));
    }

    // Call repository to validate discount
    return await _repository.validateDiscount(params.code.trim());
  }
}
