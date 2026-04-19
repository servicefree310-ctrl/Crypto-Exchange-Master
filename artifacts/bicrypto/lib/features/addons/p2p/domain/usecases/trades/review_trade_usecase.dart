import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_review_entity.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for submitting a review for a completed P2P trade
///
/// Matches v5 backend: POST /api/ext/p2p/trade/{id}/review
/// - Submits review with rating and feedback
/// - Only available for completed trades
/// - Both buyer and seller can review each other
/// - Includes communication, speed, and trust ratings
@injectable
class ReviewTradeUseCase
    implements UseCase<P2PReviewEntity, ReviewTradeParams> {
  const ReviewTradeUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, P2PReviewEntity>> call(
      ReviewTradeParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.reviewTrade(
      tradeId: params.tradeId,
      communicationRating: params.communicationRating,
      speedRating: params.speedRating,
      trustRating: params.trustRating,
      comment: params.comment,
      isPositive: params.isPositive,
    );
  }

  ValidationFailure? _validateParams(ReviewTradeParams params) {
    // Validate trade ID
    if (params.tradeId.isEmpty) {
      return ValidationFailure('Trade ID cannot be empty');
    }

    // Validate UUID format
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(params.tradeId)) {
      return ValidationFailure('Invalid trade ID format');
    }

    // Validate communication rating
    if (params.communicationRating < 1 || params.communicationRating > 5) {
      return ValidationFailure('Communication rating must be between 1 and 5');
    }

    // Validate speed rating
    if (params.speedRating < 1 || params.speedRating > 5) {
      return ValidationFailure('Speed rating must be between 1 and 5');
    }

    // Validate trust rating
    if (params.trustRating < 1 || params.trustRating > 5) {
      return ValidationFailure('Trust rating must be between 1 and 5');
    }

    // Validate comment
    if (params.comment.isEmpty) {
      return ValidationFailure('Review comment is required');
    }

    if (params.comment.length < 10) {
      return ValidationFailure('Review comment must be at least 10 characters');
    }

    if (params.comment.length > 500) {
      return ValidationFailure('Review comment cannot exceed 500 characters');
    }

    // Check for inappropriate content (basic validation)
    if (_containsInappropriateContent(params.comment)) {
      return ValidationFailure('Review comment contains inappropriate content');
    }

    return null;
  }

  bool _containsInappropriateContent(String text) {
    // Basic inappropriate content check
    const inappropriateWords = [
      'scam', 'fraud', 'steal', 'cheat', 'fake',
      // Add more inappropriate words as needed
    ];

    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }
}

/// Parameters for submitting a trade review
class ReviewTradeParams {
  const ReviewTradeParams({
    required this.tradeId,
    required this.communicationRating,
    required this.speedRating,
    required this.trustRating,
    required this.comment,
    this.isPositive,
  });

  /// Trade ID to review
  final String tradeId;

  /// Communication rating (1-5)
  final int communicationRating;

  /// Speed rating (1-5)
  final int speedRating;

  /// Trust rating (1-5)
  final int trustRating;

  /// Review comment/feedback
  final String comment;

  /// Whether this is a positive review (calculated if not provided)
  final bool? isPositive;
}
