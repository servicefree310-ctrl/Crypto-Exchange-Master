import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/review_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class AddReviewUseCase {
  const AddReviewUseCase(this._repository);

  final EcommerceRepository _repository;

  Future<Either<Failure, ReviewEntity>> call(AddReviewParams params) {
    return _repository.addReview(
      productId: params.productId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}

class AddReviewParams {
  const AddReviewParams({
    required this.productId,
    required this.rating,
    required this.comment,
  });

  final String productId;
  final int rating;
  final String comment;
}
