import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_review_entity.dart';
import '../../repositories/p2p_reviews_repository.dart';

/// Use case for retrieving reviews for a specific user
///
/// Based on v5 backend review aggregation patterns
/// - Gets both reviews given by user and received by user
/// - Calculates comprehensive user rating statistics
/// - Includes recent reviews for display
/// - Provides trader reputation data
@injectable
class GetUserReviewsUseCase
    implements UseCase<UserReviewsResponse, GetUserReviewsParams> {
  const GetUserReviewsUseCase(this._repository);

  final P2PReviewsRepository _repository;

  @override
  Future<Either<Failure, UserReviewsResponse>> call(
      GetUserReviewsParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Get user reviews data
    return await _repository.getUserReviews(
      userId: params.userId,
      includeGiven: params.includeGiven,
      includeReceived: params.includeReceived,
      limit: params.limit,
    );
  }

  ValidationFailure? _validateParams(GetUserReviewsParams params) {
    // User ID validation
    if (params.userId.trim().isEmpty) {
      return ValidationFailure('User ID is required');
    }

    // Must include at least one type
    if (!params.includeGiven && !params.includeReceived) {
      return ValidationFailure('Must include either given or received reviews');
    }

    // Limit validation
    if (params.limit < 1 || params.limit > 100) {
      return ValidationFailure('Limit must be between 1 and 100');
    }

    return null;
  }
}

/// Parameters for getting user reviews
class GetUserReviewsParams {
  const GetUserReviewsParams({
    required this.userId,
    this.includeGiven = true,
    this.includeReceived = true,
    this.limit = 20,
  });

  /// User ID to get reviews for
  final String userId;

  /// Include reviews given by this user
  final bool includeGiven;

  /// Include reviews received by this user
  final bool includeReceived;

  /// Maximum number of recent reviews to return
  final int limit;
}

/// Response for user reviews
class UserReviewsResponse {
  const UserReviewsResponse({
    required this.userId,
    required this.givenReviews,
    required this.receivedReviews,
    required this.statistics,
  });

  /// User ID
  final String userId;

  /// Reviews given by the user
  final List<P2PReviewEntity> givenReviews;

  /// Reviews received by the user
  final List<P2PReviewEntity> receivedReviews;

  /// User review statistics
  final UserReviewStatistics statistics;
}

/// User review statistics
class UserReviewStatistics {
  const UserReviewStatistics({
    required this.totalGiven,
    required this.totalReceived,
    required this.averageGiven,
    required this.averageReceived,
    required this.receivedBreakdown,
    required this.reputationScore,
  });

  final int totalGiven;
  final int totalReceived;
  final double averageGiven;
  final double averageReceived;
  final ReviewBreakdown receivedBreakdown;
  final double reputationScore; // Calculated reputation score (0-100)
}

/// Review breakdown for received reviews
class ReviewBreakdown {
  const ReviewBreakdown({
    required this.communication,
    required this.speed,
    required this.trust,
    required this.overall,
  });

  final double communication;
  final double speed;
  final double trust;
  final double overall;
}
