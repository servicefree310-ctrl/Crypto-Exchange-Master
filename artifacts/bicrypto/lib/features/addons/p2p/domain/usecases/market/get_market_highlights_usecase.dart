import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_market_stats_entity.dart';
import '../../repositories/p2p_market_repository.dart';

/// Use case for retrieving P2P market highlights
///
/// Matches v5 backend: GET /api/ext/p2p/market/highlight
/// - Returns highlighted market data (top active offers)
/// - Features newest and most popular offers
/// - No authentication required (public data)
/// - Used for market overview and discovery
@injectable
class GetMarketHighlightsUseCase
    implements
        UseCase<List<P2PMarketHighlightEntity>, GetMarketHighlightsParams> {
  const GetMarketHighlightsUseCase(this._repository);

  final P2PMarketRepository _repository;

  @override
  Future<Either<Failure, List<P2PMarketHighlightEntity>>> call(
      GetMarketHighlightsParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Get market highlights
    return await _repository.getMarketHighlights();
  }

  ValidationFailure? _validateParams(GetMarketHighlightsParams params) {
    // Limit validation
    if (params.limit < 1 || params.limit > 20) {
      return ValidationFailure('Limit must be between 1 and 20');
    }

    // Type validation
    final validTypes = ['newest', 'popular', 'trending', 'all'];
    if (params.type != null && !validTypes.contains(params.type)) {
      return ValidationFailure('Invalid highlight type: ${params.type}');
    }

    return null;
  }
}

/// Parameters for getting market highlights
class GetMarketHighlightsParams {
  const GetMarketHighlightsParams({
    this.limit = 5,
    this.type,
  });

  /// Maximum number of highlights to return (1-20)
  final int limit;

  /// Type of highlights (newest, popular, trending, all)
  final String? type;
}
