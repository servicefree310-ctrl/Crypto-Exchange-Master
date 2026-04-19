import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/repositories/p2p_reviews_repository.dart';
import '../../domain/entities/p2p_review_entity.dart';
import '../../domain/usecases/reviews/get_reviews_usecase.dart';
import '../../domain/usecases/reviews/get_user_reviews_usecase.dart';
import '../datasources/p2p_remote_datasource.dart';
import '../datasources/p2p_local_datasource.dart';

/// Repository implementation for P2P review operations
@Injectable(as: P2PReviewsRepository)
class P2PReviewsRepositoryImpl implements P2PReviewsRepository {
  const P2PReviewsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final P2PRemoteDataSource _remoteDataSource;
  final P2PLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
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
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getReviews(
        reviewerId: reviewerId,
        revieweeId: revieweeId,
        tradeId: tradeId,
        minRating: minRating,
        maxRating: maxRating,
        page: page,
        perPage: perPage,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return Right(_convertJsonToReviewsResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserReviewsResponse>> getUserReviews({
    required String userId,
    bool includeGiven = true,
    bool includeReceived = true,
    int limit = 20,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getUserReviews(
        userId: userId,
        includeGiven: includeGiven,
        includeReceived: includeReceived,
        limit: limit,
      );

      return Right(_convertJsonToUserReviewsResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Helper methods
  P2PReviewsResponse _convertJsonToReviewsResponse(Map<String, dynamic> json) {
    final reviews = json['reviews'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    final statistics = json['statistics'] as Map<String, dynamic>? ?? {};

    return P2PReviewsResponse(
      reviews: reviews
          .map((review) => P2PReviewEntity(
                id: review['id']?.toString() ?? '',
                tradeId: review['tradeId']?.toString() ?? '',
                reviewerId: review['reviewerId']?.toString() ?? '',
                revieweeId: review['revieweeId']?.toString() ?? '',
                rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                communicationRating:
                    (review['communicationRating'] as num?)?.toDouble(),
                speedRating: (review['speedRating'] as num?)?.toDouble(),
                trustRating: (review['trustRating'] as num?)?.toDouble(),
                comment: review['comment']?.toString(),
                createdAt:
                    DateTime.tryParse(review['createdAt']?.toString() ?? '') ??
                        DateTime.now(),
                updatedAt:
                    DateTime.tryParse(review['updatedAt']?.toString() ?? ''),
                reviewerInfo: review['reviewerInfo'] != null
                    ? ReviewerInfo(
                        id: review['reviewerInfo']['id']?.toString() ?? '',
                        firstName:
                            review['reviewerInfo']['firstName']?.toString() ??
                                '',
                        lastName:
                            review['reviewerInfo']['lastName']?.toString(),
                        avatar: review['reviewerInfo']['avatar']?.toString(),
                      )
                    : null,
                revieweeInfo: review['revieweeInfo'] != null
                    ? ReviewerInfo(
                        id: review['revieweeInfo']['id']?.toString() ?? '',
                        firstName:
                            review['revieweeInfo']['firstName']?.toString() ??
                                '',
                        lastName:
                            review['revieweeInfo']['lastName']?.toString(),
                        avatar: review['revieweeInfo']['avatar']?.toString(),
                      )
                    : null,
              ))
          .toList(),
      pagination: PaginationData(
        currentPage: pagination['currentPage'] as int? ?? 1,
        perPage: pagination['perPage'] as int? ?? 20,
        totalItems: pagination['totalItems'] as int? ?? 0,
        totalPages: pagination['totalPages'] as int? ?? 1,
        hasNextPage: pagination['hasNextPage'] as bool? ?? false,
        hasPreviousPage: pagination['hasPreviousPage'] as bool? ?? false,
      ),
      statistics: ReviewStatistics(
        totalReviews: statistics['totalReviews'] as int? ?? 0,
        averageRating: (statistics['averageRating'] as num?)?.toDouble() ?? 0.0,
        averageCommunication:
            (statistics['averageCommunication'] as num?)?.toDouble() ?? 0.0,
        averageSpeed: (statistics['averageSpeed'] as num?)?.toDouble() ?? 0.0,
        averageTrust: (statistics['averageTrust'] as num?)?.toDouble() ?? 0.0,
        ratingDistribution:
            Map<int, int>.from(statistics['ratingDistribution'] ?? {}),
      ),
    );
  }

  UserReviewsResponse _convertJsonToUserReviewsResponse(
      Map<String, dynamic> json) {
    final givenReviews = json['givenReviews'] as List? ?? [];
    final receivedReviews = json['receivedReviews'] as List? ?? [];
    final statistics = json['statistics'] as Map<String, dynamic>? ?? {};

    return UserReviewsResponse(
      userId: json['userId']?.toString() ?? '',
      givenReviews: givenReviews
          .map((review) => P2PReviewEntity(
                id: review['id']?.toString() ?? '',
                tradeId: review['tradeId']?.toString() ?? '',
                reviewerId: review['reviewerId']?.toString() ?? '',
                revieweeId: review['revieweeId']?.toString() ?? '',
                rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                communicationRating:
                    (review['communicationRating'] as num?)?.toDouble(),
                speedRating: (review['speedRating'] as num?)?.toDouble(),
                trustRating: (review['trustRating'] as num?)?.toDouble(),
                comment: review['comment']?.toString(),
                createdAt:
                    DateTime.tryParse(review['createdAt']?.toString() ?? '') ??
                        DateTime.now(),
                updatedAt:
                    DateTime.tryParse(review['updatedAt']?.toString() ?? ''),
                reviewerInfo: review['reviewerInfo'] != null
                    ? ReviewerInfo(
                        id: review['reviewerInfo']['id']?.toString() ?? '',
                        firstName:
                            review['reviewerInfo']['firstName']?.toString() ??
                                '',
                        lastName:
                            review['reviewerInfo']['lastName']?.toString(),
                        avatar: review['reviewerInfo']['avatar']?.toString(),
                      )
                    : null,
                revieweeInfo: review['revieweeInfo'] != null
                    ? ReviewerInfo(
                        id: review['revieweeInfo']['id']?.toString() ?? '',
                        firstName:
                            review['revieweeInfo']['firstName']?.toString() ??
                                '',
                        lastName:
                            review['revieweeInfo']['lastName']?.toString(),
                        avatar: review['revieweeInfo']['avatar']?.toString(),
                      )
                    : null,
              ))
          .toList(),
      receivedReviews: receivedReviews
          .map((review) => P2PReviewEntity(
                id: review['id']?.toString() ?? '',
                tradeId: review['tradeId']?.toString() ?? '',
                reviewerId: review['reviewerId']?.toString() ?? '',
                revieweeId: review['revieweeId']?.toString() ?? '',
                rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                communicationRating:
                    (review['communicationRating'] as num?)?.toDouble(),
                speedRating: (review['speedRating'] as num?)?.toDouble(),
                trustRating: (review['trustRating'] as num?)?.toDouble(),
                comment: review['comment']?.toString(),
                createdAt:
                    DateTime.tryParse(review['createdAt']?.toString() ?? '') ??
                        DateTime.now(),
                updatedAt:
                    DateTime.tryParse(review['updatedAt']?.toString() ?? ''),
                reviewerInfo: review['reviewerInfo'] != null
                    ? ReviewerInfo(
                        id: review['reviewerInfo']['id']?.toString() ?? '',
                        firstName:
                            review['reviewerInfo']['firstName']?.toString() ??
                                '',
                        lastName:
                            review['reviewerInfo']['lastName']?.toString(),
                        avatar: review['reviewerInfo']['avatar']?.toString(),
                      )
                    : null,
                revieweeInfo: review['revieweeInfo'] != null
                    ? ReviewerInfo(
                        id: review['revieweeInfo']['id']?.toString() ?? '',
                        firstName:
                            review['revieweeInfo']['firstName']?.toString() ??
                                '',
                        lastName:
                            review['revieweeInfo']['lastName']?.toString(),
                        avatar: review['revieweeInfo']['avatar']?.toString(),
                      )
                    : null,
              ))
          .toList(),
      statistics: UserReviewStatistics(
        totalGiven: statistics['totalGiven'] as int? ?? 0,
        totalReceived: statistics['totalReceived'] as int? ?? 0,
        averageGiven: (statistics['averageGiven'] as num?)?.toDouble() ?? 0.0,
        averageReceived:
            (statistics['averageReceived'] as num?)?.toDouble() ?? 0.0,
        receivedBreakdown: ReviewBreakdown(
          communication:
              (statistics['receivedBreakdown']?['communication'] as num?)
                      ?.toDouble() ??
                  0.0,
          speed:
              (statistics['receivedBreakdown']?['speed'] as num?)?.toDouble() ??
                  0.0,
          trust:
              (statistics['receivedBreakdown']?['trust'] as num?)?.toDouble() ??
                  0.0,
          overall: (statistics['receivedBreakdown']?['overall'] as num?)
                  ?.toDouble() ??
              0.0,
        ),
        reputationScore:
            (statistics['reputationScore'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }
}
