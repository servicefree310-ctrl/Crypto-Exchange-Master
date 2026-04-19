import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_matching_repository.dart';

/// Use case for P2P guided matching
///
/// Matches v5 backend: POST /api/ext/p2p/guided-matching
/// - Finds matching offers based on user criteria
/// - Implements smart scoring algorithm from v5
/// - Calculates estimated savings vs market price
/// - Returns scored and ranked matches
@injectable
class GuidedMatchingUseCase
    implements UseCase<GuidedMatchingResponse, GuidedMatchingParams> {
  const GuidedMatchingUseCase(this._repository);

  final P2PMatchingRepository _repository;

  @override
  Future<Either<Failure, GuidedMatchingResponse>> call(
      GuidedMatchingParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute guided matching
    return await _repository.findMatches(
      tradeType: params.tradeType,
      cryptocurrency: params.cryptocurrency,
      amount: params.amount,
      paymentMethods: params.paymentMethods,
      pricePreference: params.pricePreference,
      traderPreference: params.traderPreference,
      location: params.location,
      maxResults: params.maxResults,
    );
  }

  ValidationFailure? _validateParams(GuidedMatchingParams params) {
    // Trade type validation
    final validTradeTypes = ['buy', 'sell'];
    if (!validTradeTypes.contains(params.tradeType.toLowerCase())) {
      return ValidationFailure('Trade type must be "buy" or "sell"');
    }

    // Cryptocurrency validation
    if (params.cryptocurrency.trim().isEmpty) {
      return ValidationFailure('Cryptocurrency is required');
    }

    // Amount validation
    if (params.amount <= 0) {
      return ValidationFailure('Amount must be greater than 0');
    }

    // Payment methods validation
    if (params.paymentMethods.isEmpty) {
      return ValidationFailure('At least one payment method is required');
    }

    // Price preference validation
    final validPricePrefs = ['best', 'market', 'average', 'flexible'];
    if (!validPricePrefs.contains(params.pricePreference.toLowerCase())) {
      return ValidationFailure(
          'Invalid price preference: ${params.pricePreference}');
    }

    // Trader preference validation
    final validTraderPrefs = ['verified', 'experienced', 'any', 'trusted'];
    if (!validTraderPrefs.contains(params.traderPreference.toLowerCase())) {
      return ValidationFailure(
          'Invalid trader preference: ${params.traderPreference}');
    }

    // Max results validation
    if (params.maxResults < 1 || params.maxResults > 50) {
      return ValidationFailure('Max results must be between 1 and 50');
    }

    return null;
  }
}

/// Parameters for guided matching
class GuidedMatchingParams {
  const GuidedMatchingParams({
    required this.tradeType,
    required this.cryptocurrency,
    required this.amount,
    required this.paymentMethods,
    required this.pricePreference,
    required this.traderPreference,
    required this.location,
    this.maxResults = 30,
  });

  /// Trade type (buy/sell)
  final String tradeType;

  /// Cryptocurrency to trade
  final String cryptocurrency;

  /// Amount to trade
  final double amount;

  /// Preferred payment methods
  final List<String> paymentMethods;

  /// Price preference (best, market, average, flexible)
  final String pricePreference;

  /// Trader preference (verified, experienced, any, trusted)
  final String traderPreference;

  /// Location preference (country code or "any")
  final String location;

  /// Maximum number of results to return
  final int maxResults;
}

/// Guided matching response
class GuidedMatchingResponse {
  const GuidedMatchingResponse({
    required this.matches,
    required this.matchCount,
    required this.estimatedSavings,
    required this.bestPrice,
    required this.marketPrice,
    required this.searchCriteria,
  });

  /// List of matched offers with scores
  final List<MatchedOffer> matches;

  /// Total number of matches found
  final int matchCount;

  /// Estimated savings compared to market price
  final double estimatedSavings;

  /// Best available price
  final double bestPrice;

  /// Current market price
  final double? marketPrice;

  /// Original search criteria
  final GuidedMatchingParams searchCriteria;
}

/// Matched offer with scoring
class MatchedOffer {
  const MatchedOffer({
    required this.id,
    required this.type,
    required this.coin,
    required this.walletType,
    required this.price,
    required this.minLimit,
    required this.maxLimit,
    required this.availableAmount,
    required this.paymentMethods,
    required this.matchScore,
    required this.trader,
    required this.benefits,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String coin;
  final String walletType;
  final double price;
  final double minLimit;
  final double maxLimit;
  final double availableAmount;
  final List<String> paymentMethods;
  final int matchScore; // 0-100
  final TraderInfo trader;
  final List<String> benefits;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Trader information in match
class TraderInfo {
  const TraderInfo({
    required this.id,
    required this.name,
    this.avatar,
    required this.completedTrades,
    required this.completionRate,
    required this.verified,
    required this.responseTime,
    required this.avgRating,
  });

  final String id;
  final String name;
  final String? avatar;
  final int completedTrades;
  final int completionRate; // percentage
  final bool verified;
  final int responseTime; // minutes
  final double avgRating; // 0-5
}
