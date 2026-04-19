import 'package:dartz/dartz.dart';
import '../../../../../../../../core/errors/failures.dart';
import '../usecases/matching/guided_matching_usecase.dart';
import '../usecases/matching/compare_prices_usecase.dart';

/// Repository interface for P2P matching operations
///
/// Defines all matching-related operations that can be performed
/// Implementation will handle API calls to backend endpoints
abstract class P2PMatchingRepository {
  /// Find matching offers based on criteria
  /// Matches: POST /api/ext/p2p/guided-matching
  Future<Either<Failure, GuidedMatchingResponse>> findMatches({
    required String tradeType,
    required String cryptocurrency,
    required double amount,
    required List<String> paymentMethods,
    required String pricePreference,
    required String traderPreference,
    required String location,
    int maxResults = 30,
  });

  /// Compare P2P prices with market prices
  /// Based on v5's price comparison logic
  Future<Either<Failure, PriceComparisonResponse>> comparePrices({
    required String cryptocurrency,
    required String tradeType,
    required double amount,
    required double p2pPrice,
  });
}
