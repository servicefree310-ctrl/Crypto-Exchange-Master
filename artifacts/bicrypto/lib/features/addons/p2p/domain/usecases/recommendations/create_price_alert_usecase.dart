import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_recommendation_repository.dart';
import '../../entities/p2p_recommendation_entity.dart';

/// Use case for creating price alerts
///
/// Creates smart price alerts for:
/// - Price drops/rises
/// - Target price reached
/// - Market opportunities
/// - Price optimization suggestions
@injectable
class CreatePriceAlertUseCase
    implements UseCase<P2PRecommendationEntity, CreatePriceAlertParams> {
  const CreatePriceAlertUseCase(this._repository);

  final P2PRecommendationRepository _repository;

  @override
  Future<Either<Failure, P2PRecommendationEntity>> call(
      CreatePriceAlertParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Create price alert
    return await _repository.createPriceAlert(
      cryptocurrency: params.cryptocurrency,
      targetPrice: params.targetPrice,
      alertType: params.alertType,
    );
  }

  ValidationFailure? _validateParams(CreatePriceAlertParams params) {
    // Cryptocurrency validation
    if (params.cryptocurrency.trim().isEmpty) {
      return ValidationFailure('Cryptocurrency is required');
    }

    // Target price validation
    if (params.targetPrice <= 0) {
      return ValidationFailure('Target price must be greater than 0');
    }

    // Alert type validation
    final validAlertTypes = [
      PriceAlertType.priceDrop,
      PriceAlertType.priceRise,
      PriceAlertType.targetReached,
      PriceAlertType.marketOpportunity,
    ];
    if (!validAlertTypes.contains(params.alertType)) {
      return ValidationFailure('Invalid alert type');
    }

    // Optional amount validation
    if (params.amount != null && params.amount! <= 0) {
      return ValidationFailure('Amount must be greater than 0');
    }

    return null;
  }
}

/// Parameters for creating price alert
class CreatePriceAlertParams {
  const CreatePriceAlertParams({
    required this.cryptocurrency,
    required this.targetPrice,
    required this.alertType,
    this.amount,
    this.offerId,
  });

  /// Cryptocurrency to monitor
  final String cryptocurrency;

  /// Target price for the alert
  final double targetPrice;

  /// Type of price alert
  final PriceAlertType alertType;

  /// Optional trade amount
  final double? amount;

  /// Optional offer ID to track
  final String? offerId;
}
