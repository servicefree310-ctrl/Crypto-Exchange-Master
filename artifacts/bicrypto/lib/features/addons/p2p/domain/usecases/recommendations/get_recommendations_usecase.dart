import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_recommendation_repository.dart';
import '../../entities/p2p_recommendation_entity.dart';

/// Use case for getting personalized P2P recommendations
///
/// Provides smart recommendations including:
/// - Personalized offer suggestions
/// - Price optimization alerts
/// - Best match notifications
/// - Market insights
/// - Trader recommendations
@injectable
class GetRecommendationsUseCase
    implements
        UseCase<List<P2PRecommendationEntity>, GetRecommendationsParams> {
  const GetRecommendationsUseCase(this._repository);

  final P2PRecommendationRepository _repository;

  @override
  Future<Either<Failure, List<P2PRecommendationEntity>>> call(
      GetRecommendationsParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Get recommendations based on category
    if (params.category != null) {
      switch (params.category!) {
        case 'price_alerts':
          return await _repository.getPriceAlerts(
            cryptocurrency: params.cryptocurrency,
            limit: params.limit,
          );
        case 'offer_suggestions':
          return await _repository.getOfferSuggestions(
            cryptocurrency: params.cryptocurrency,
            tradeType: params.tradeType,
            limit: params.limit,
          );
        case 'market_insights':
          return await _repository.getMarketInsights(
            cryptocurrency: params.cryptocurrency,
            limit: params.limit,
          );
        case 'trader_recommendations':
          return await _repository.getTraderRecommendations(
            cryptocurrency: params.cryptocurrency,
            limit: params.limit,
          );
        default:
          return await _repository.getRecommendations(
            category: params.category,
            limit: params.limit,
          );
      }
    }

    // 3. Get all recommendations if no specific category
    return await _repository.getRecommendations(
      category: params.category,
      limit: params.limit,
    );
  }

  ValidationFailure? _validateParams(GetRecommendationsParams params) {
    // Limit validation
    if (params.limit < 1 || params.limit > 100) {
      return ValidationFailure('Limit must be between 1 and 100');
    }

    // Category validation (if provided)
    if (params.category != null) {
      final validCategories = [
        'price_alerts',
        'offer_suggestions',
        'market_insights',
        'trader_recommendations',
        'trading',
        'market',
        'security',
        'optimization',
        'social',
      ];
      if (!validCategories.contains(params.category)) {
        return ValidationFailure('Invalid category: ${params.category}');
      }
    }

    // Trade type validation (if provided)
    if (params.tradeType != null) {
      final validTradeTypes = ['buy', 'sell'];
      if (!validTradeTypes.contains(params.tradeType!.toLowerCase())) {
        return ValidationFailure('Trade type must be "buy" or "sell"');
      }
    }

    return null;
  }
}

/// Parameters for getting recommendations
class GetRecommendationsParams {
  const GetRecommendationsParams({
    this.category,
    this.cryptocurrency,
    this.tradeType,
    this.limit = 20,
  });

  /// Category filter (optional)
  final String? category;

  /// Cryptocurrency filter (optional)
  final String? cryptocurrency;

  /// Trade type filter (optional)
  final String? tradeType;

  /// Maximum number of recommendations to return
  final int limit;
}
