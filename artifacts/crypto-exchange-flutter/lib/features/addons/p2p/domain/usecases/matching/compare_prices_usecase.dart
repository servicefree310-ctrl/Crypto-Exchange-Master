import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_matching_repository.dart';

/// Use case for comparing P2P prices with market prices
///
/// Based on v5's price comparison logic in guided matching
/// - Compares P2P offer prices with current market price
/// - Calculates potential savings or premium
/// - Provides price insights for decision making
@injectable
class ComparePricesUseCase
    implements UseCase<PriceComparisonResponse, ComparePricesParams> {
  const ComparePricesUseCase(this._repository);

  final P2PMatchingRepository _repository;

  @override
  Future<Either<Failure, PriceComparisonResponse>> call(
      ComparePricesParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Compare prices
    return await _repository.comparePrices(
      cryptocurrency: params.cryptocurrency,
      tradeType: params.tradeType,
      amount: params.amount,
      p2pPrice: params.p2pPrice,
    );
  }

  ValidationFailure? _validateParams(ComparePricesParams params) {
    // Cryptocurrency validation
    if (params.cryptocurrency.trim().isEmpty) {
      return ValidationFailure('Cryptocurrency is required');
    }

    // Trade type validation
    final validTradeTypes = ['buy', 'sell'];
    if (!validTradeTypes.contains(params.tradeType.toLowerCase())) {
      return ValidationFailure('Trade type must be "buy" or "sell"');
    }

    // Amount validation
    if (params.amount <= 0) {
      return ValidationFailure('Amount must be greater than 0');
    }

    // P2P price validation
    if (params.p2pPrice <= 0) {
      return ValidationFailure('P2P price must be greater than 0');
    }

    return null;
  }
}

/// Parameters for price comparison
class ComparePricesParams {
  const ComparePricesParams({
    required this.cryptocurrency,
    required this.tradeType,
    required this.amount,
    required this.p2pPrice,
  });

  /// Cryptocurrency to compare
  final String cryptocurrency;

  /// Trade type (buy/sell)
  final String tradeType;

  /// Trade amount
  final double amount;

  /// P2P offer price to compare
  final double p2pPrice;
}

/// Price comparison response
class PriceComparisonResponse {
  const PriceComparisonResponse({
    required this.marketPrice,
    required this.p2pPrice,
    required this.difference,
    required this.percentageDifference,
    required this.estimatedSavings,
    required this.isPremium,
    required this.recommendation,
    required this.priceInsights,
  });

  /// Current market price
  final double marketPrice;

  /// P2P offer price
  final double p2pPrice;

  /// Absolute difference
  final double difference;

  /// Percentage difference
  final double percentageDifference;

  /// Estimated savings (negative if premium)
  final double estimatedSavings;

  /// Whether P2P price is at premium
  final bool isPremium;

  /// Price recommendation
  final String recommendation;

  /// Additional price insights
  final List<String> priceInsights;
}
