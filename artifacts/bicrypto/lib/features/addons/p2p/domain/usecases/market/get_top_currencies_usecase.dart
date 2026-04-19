import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_market_stats_entity.dart';
import '../../repositories/p2p_market_repository.dart';

/// Use case for retrieving top cryptocurrencies in P2P trading
///
/// Matches v5 backend: GET /api/ext/p2p/market/top
/// - Returns top cryptocurrencies ranked by trade volume
/// - Limited to top 5 by default
/// - Includes currency name and total volume
/// - No authentication required (public data)
@injectable
class GetTopCurrenciesUseCase
    implements UseCase<List<P2PTopCryptoEntity>, GetTopCurrenciesParams> {
  const GetTopCurrenciesUseCase(this._repository);

  final P2PMarketRepository _repository;

  @override
  Future<Either<Failure, List<P2PTopCryptoEntity>>> call(
      GetTopCurrenciesParams params) async {
    // Input validation
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.getTopCurrencies();
  }

  ValidationFailure? _validateParams(GetTopCurrenciesParams params) {
    // Limit validation
    if (params.limit < 1 || params.limit > 20) {
      return ValidationFailure('Limit must be between 1 and 20');
    }

    return null;
  }
}

/// Parameters for getting top currencies
class GetTopCurrenciesParams {
  const GetTopCurrenciesParams({
    this.limit = 5,
  });

  /// Maximum number of currencies to return (1-20)
  final int limit;
}

/// Top currency data
class TopCurrencyData {
  const TopCurrencyData({
    required this.currency,
    required this.totalVolume,
    required this.tradeCount,
    required this.avgPrice,
    required this.change24h,
  });

  /// Currency symbol (e.g., BTC, ETH)
  final String currency;

  /// Total trading volume
  final double totalVolume;

  /// Number of trades
  final int tradeCount;

  /// Average trading price
  final double avgPrice;

  /// 24h change percentage
  final double change24h;
}
