import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_review_entity.dart';
import '../../repositories/p2p_reviews_repository.dart';

/// Use case for retrieving P2P reviews
///
/// Based on v5 review system for trade reviews
/// - Supports filtering by reviewer/reviewee
/// - Includes pagination for large result sets
/// - Returns aggregated rating statistics
/// - Filters by trade ID or user ID
@injectable
class GetReviewsUseCase
    implements UseCase<P2PReviewsResponse, GetReviewsParams> {
  const GetReviewsUseCase(this._repository);

  final P2PReviewsRepository _repository;

  @override
  Future<Either<Failure, P2PReviewsResponse>> call(
      GetReviewsParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Get reviews with filters and pagination
    return await _repository.getReviews(
      reviewerId: params.reviewerId,
      revieweeId: params.revieweeId,
      tradeId: params.tradeId,
      minRating: params.minRating,
      maxRating: params.maxRating,
      page: params.page,
      perPage: params.perPage,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }

  ValidationFailure? _validateParams(GetReviewsParams params) {
    // Page validation
    if (params.page < 1) {
      return ValidationFailure('Page must be greater than 0');
    }

    // Per page validation
    if (params.perPage < 1 || params.perPage > 100) {
      return ValidationFailure('PerPage must be between 1 and 100');
    }

    // Rating range validation
    if (params.minRating != null &&
        (params.minRating! < 1 || params.minRating! > 5)) {
      return ValidationFailure('Minimum rating must be between 1 and 5');
    }

    if (params.maxRating != null &&
        (params.maxRating! < 1 || params.maxRating! > 5)) {
      return ValidationFailure('Maximum rating must be between 1 and 5');
    }

    if (params.minRating != null &&
        params.maxRating != null &&
        params.minRating! > params.maxRating!) {
      return ValidationFailure(
          'Minimum rating cannot be greater than maximum rating');
    }

    // Sort validation
    final validSortFields = [
      'createdAt',
      'rating',
      'communicationRating',
      'speedRating',
      'trustRating'
    ];
    if (!validSortFields.contains(params.sortBy)) {
      return ValidationFailure('Invalid sort field: ${params.sortBy}');
    }

    final validSortOrders = ['asc', 'desc'];
    if (!validSortOrders.contains(params.sortOrder)) {
      return ValidationFailure('Invalid sort order: ${params.sortOrder}');
    }

    return null;
  }
}

/// Parameters for getting reviews
class GetReviewsParams {
  const GetReviewsParams({
    this.reviewerId,
    this.revieweeId,
    this.tradeId,
    this.minRating,
    this.maxRating,
    this.page = 1,
    this.perPage = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  /// Filter by reviewer user ID
  final String? reviewerId;

  /// Filter by reviewee user ID
  final String? revieweeId;

  /// Filter by specific trade ID
  final String? tradeId;

  /// Minimum rating filter (1-5)
  final double? minRating;

  /// Maximum rating filter (1-5)
  final double? maxRating;

  /// Page number for pagination
  final int page;

  /// Items per page
  final int perPage;

  /// Sort field
  final String sortBy;

  /// Sort order (asc/desc)
  final String sortOrder;
}

/// Response for paginated reviews
class P2PReviewsResponse {
  const P2PReviewsResponse({
    required this.reviews,
    required this.pagination,
    required this.statistics,
  });

  /// List of reviews
  final List<P2PReviewEntity> reviews;

  /// Pagination metadata
  final PaginationData pagination;

  /// Review statistics
  final ReviewStatistics statistics;
}

/// Review statistics
class ReviewStatistics {
  const ReviewStatistics({
    required this.totalReviews,
    required this.averageRating,
    required this.averageCommunication,
    required this.averageSpeed,
    required this.averageTrust,
    required this.ratingDistribution,
  });

  final int totalReviews;
  final double averageRating;
  final double averageCommunication;
  final double averageSpeed;
  final double averageTrust;
  final Map<int, int> ratingDistribution; // rating -> count
}

/// Pagination metadata
class PaginationData {
  const PaginationData({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
}
