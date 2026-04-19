import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_offer_entity.dart';
import '../../entities/p2p_params.dart';
import '../../repositories/p2p_offers_repository.dart';

@injectable
class UpdateOfferUseCase implements UseCase<P2POfferEntity, UpdateOfferParams> {
  final P2POffersRepository _repository;

  const UpdateOfferUseCase(this._repository);

  @override
  Future<Either<Failure, P2POfferEntity>> call(UpdateOfferParams params) async {
    // Input validation
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.updateOffer(params.offerId, params.updateData);
  }

  ValidationFailure? _validateParams(UpdateOfferParams params) {
    // Validate offer ID
    if (params.offerId.isEmpty) {
      return const ValidationFailure('Offer ID is required');
    }

    // Basic UUID format validation
    if (params.offerId.length < 10) {
      return const ValidationFailure('Invalid offer ID format');
    }

    // Validate update data using the same validation as CreateOfferUseCase
    return _validateOfferData(params.updateData);
  }

  ValidationFailure? _validateOfferData(CreateOfferParams params) {
    // Validate required fields (matching v5 backend schema)
    if (params.type.isEmpty) {
      return const ValidationFailure('Trade type is required');
    }
    if (!['BUY', 'SELL'].contains(params.type)) {
      return const ValidationFailure('Trade type must be BUY or SELL');
    }

    if (params.currency.isEmpty) {
      return const ValidationFailure('Currency is required');
    }

    if (!['FIAT', 'SPOT', 'ECO'].contains(params.walletType)) {
      return const ValidationFailure('Wallet type must be FIAT, SPOT, or ECO');
    }

    // Validate amountConfig (now a Map)
    final amountConfig = params.amountConfig;
    final total = amountConfig['total'] as num?;
    final min = amountConfig['min'] as num?;
    final max = amountConfig['max'] as num?;

    if (total == null || total <= 0) {
      return const ValidationFailure('Total amount must be greater than 0');
    }
    if (min != null && min <= 0) {
      return const ValidationFailure('Minimum amount must be greater than 0');
    }
    if (max != null && max <= 0) {
      return const ValidationFailure('Maximum amount must be greater than 0');
    }
    if (min != null && max != null && min > max) {
      return const ValidationFailure(
          'Minimum amount cannot be greater than maximum amount');
    }
    if (max != null && max > total) {
      return const ValidationFailure(
          'Maximum amount cannot be greater than total amount');
    }

    // Validate priceConfig (now a Map)
    final priceConfig = params.priceConfig;
    final model = priceConfig['model'] as String?;
    final finalPrice = priceConfig['finalPrice'] as num?;
    final marketPrice = priceConfig['marketPrice'] as num?;

    if (model == null || !['FIXED', 'MARGIN'].contains(model)) {
      return const ValidationFailure('Price model must be FIXED or MARGIN');
    }
    if (finalPrice == null || finalPrice <= 0) {
      return const ValidationFailure('Final price must be greater than 0');
    }
    if (model == 'MARGIN' && marketPrice != null && marketPrice <= 0) {
      return const ValidationFailure(
          'Market price must be greater than 0 for margin pricing');
    }

    // Validate tradeSettings (now a Map)
    final tradeSettings = params.tradeSettings;
    final autoCancel = tradeSettings['autoCancel'] as num?;
    final visibility = tradeSettings['visibility'] as String?;

    if (autoCancel == null || autoCancel <= 0) {
      return const ValidationFailure('Auto cancel time must be greater than 0');
    }
    if (visibility == null || !['PUBLIC', 'PRIVATE'].contains(visibility)) {
      return const ValidationFailure('Visibility must be PUBLIC or PRIVATE');
    }

    // Validate userRequirements (if provided)
    if (params.userRequirements != null) {
      final req = params.userRequirements!;
      final minCompletedTrades = req['minCompletedTrades'] as num?;
      final minSuccessRate = req['minSuccessRate'] as num?;
      final minAccountAge = req['minAccountAge'] as num?;

      if (minCompletedTrades != null && minCompletedTrades < 0) {
        return const ValidationFailure(
            'Minimum completed trades must be 0 or greater');
      }
      if (minSuccessRate != null &&
          (minSuccessRate < 0 || minSuccessRate > 100)) {
        return const ValidationFailure(
            'Minimum success rate must be between 0 and 100');
      }
      if (minAccountAge != null && minAccountAge < 0) {
        return const ValidationFailure(
            'Minimum account age must be 0 or greater');
      }
    }

    // Validate payment method IDs
    if (params.paymentMethodIds != null &&
        params.paymentMethodIds!.isNotEmpty) {
      // Check for duplicates
      final uniqueIds = params.paymentMethodIds!.toSet();
      if (uniqueIds.length != params.paymentMethodIds!.length) {
        return const ValidationFailure(
            'Duplicate payment methods are not allowed');
      }
    }

    return null;
  }
}

class UpdateOfferParams {
  final String offerId;
  final CreateOfferParams updateData;
  final bool validateOwnership;
  final String? reason; // Optional reason for update

  const UpdateOfferParams({
    required this.offerId,
    required this.updateData,
    this.validateOwnership = true,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': updateData.type,
      'currency': updateData.currency,
      'walletType': updateData.walletType,
      'amountConfig': updateData.amountConfig,
      'priceConfig': updateData.priceConfig,
      'tradeSettings': updateData.tradeSettings,
    };

    if (updateData.locationSettings != null) {
      map['locationSettings'] = updateData.locationSettings;
    }

    if (updateData.userRequirements != null) {
      map['userRequirements'] = updateData.userRequirements;
    }

    if (updateData.paymentMethodIds != null) {
      map['paymentMethodIds'] = updateData.paymentMethodIds;
    }

    if (reason != null && reason!.isNotEmpty) {
      map['updateReason'] = reason;
    }

    return map;
  }
}
