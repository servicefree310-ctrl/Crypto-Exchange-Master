import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_recommendation_repository.dart';

/// Use case for managing P2P recommendations
///
/// Handles recommendation management operations:
/// - Mark as read
/// - Mark all as read
/// - Delete recommendations
/// - Get unread count
/// - Update preferences
@injectable
class ManageRecommendationsUseCase
    implements UseCase<dynamic, ManageRecommendationsParams> {
  const ManageRecommendationsUseCase(this._repository);

  final P2PRecommendationRepository _repository;

  @override
  Future<Either<Failure, dynamic>> call(
      ManageRecommendationsParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute the requested operation
    switch (params.operation) {
      case RecommendationOperation.markAsRead:
        return await _repository.markAsRead(params.recommendationId!);

      case RecommendationOperation.markAllAsRead:
        return await _repository.markAllAsRead();

      case RecommendationOperation.delete:
        return await _repository.deleteRecommendation(params.recommendationId!);

      case RecommendationOperation.getUnreadCount:
        return await _repository.getUnreadCount();

      case RecommendationOperation.updatePreferences:
        return await _repository.updatePreferences(
          preferences: params.preferences!,
        );

      case RecommendationOperation.getPreferences:
        return await _repository.getPreferences();
    }
  }

  ValidationFailure? _validateParams(ManageRecommendationsParams params) {
    // Recommendation ID validation for operations that require it
    if (params.operation == RecommendationOperation.markAsRead ||
        params.operation == RecommendationOperation.delete) {
      if (params.recommendationId == null || params.recommendationId!.isEmpty) {
        return ValidationFailure(
            'Recommendation ID is required for this operation');
      }
    }

    // Preferences validation for update operation
    if (params.operation == RecommendationOperation.updatePreferences) {
      if (params.preferences == null || params.preferences!.isEmpty) {
        return ValidationFailure(
            'Preferences are required for update operation');
      }
    }

    return null;
  }
}

/// Parameters for managing recommendations
class ManageRecommendationsParams {
  const ManageRecommendationsParams({
    required this.operation,
    this.recommendationId,
    this.preferences,
  });

  /// Operation to perform
  final RecommendationOperation operation;

  /// Recommendation ID (required for some operations)
  final String? recommendationId;

  /// Preferences data (required for update operation)
  final Map<String, dynamic>? preferences;
}

/// Recommendation management operations
enum RecommendationOperation {
  markAsRead,
  markAllAsRead,
  delete,
  getUnreadCount,
  updatePreferences,
  getPreferences,
}
