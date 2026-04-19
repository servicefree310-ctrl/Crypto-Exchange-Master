import 'package:dartz/dartz.dart';
import '../../../../../../../../core/errors/failures.dart';
import '../usecases/reviews/get_reviews_usecase.dart';
import '../usecases/reviews/get_user_reviews_usecase.dart';

/// Repository interface for P2P review operations
///
/// Defines all review-related operations that can be performed
/// Implementation will handle API calls to backend endpoints
abstract class P2PReviewsRepository {
  /// Get reviews with filtering and pagination
  Future<Either<Failure, P2PReviewsResponse>> getReviews({
    String? reviewerId,
    String? revieweeId,
    String? tradeId,
    double? minRating,
    double? maxRating,
    int page = 1,
    int perPage = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  });

  /// Get reviews for a specific user
  Future<Either<Failure, UserReviewsResponse>> getUserReviews({
    required String userId,
    bool includeGiven = true,
    bool includeReceived = true,
    int limit = 20,
  });
}
