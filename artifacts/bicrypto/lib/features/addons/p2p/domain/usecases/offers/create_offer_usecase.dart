import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_offer_entity.dart';
import '../../entities/p2p_params.dart';
import '../../repositories/p2p_offers_repository.dart';

@injectable
class CreateOfferUseCase implements UseCase<P2POfferEntity, CreateOfferParams> {
  const CreateOfferUseCase(this._repository);

  final P2POffersRepository _repository;

  @override
  Future<Either<Failure, P2POfferEntity>> call(CreateOfferParams params) async {
    dev.log('🎯 USE CASE: CreateOfferUseCase called');
    dev.log('📋 Received params:');
    dev.log('  Type: ${params.type}');
    dev.log('  Currency: ${params.currency}');
    dev.log('  Wallet Type: ${params.walletType}');
    dev.log('  Amount Config: ${params.amountConfig}');
    dev.log('  Price Config: ${params.priceConfig}');
    dev.log('  Trade Settings: ${params.tradeSettings}');
    dev.log('  Location Settings: ${params.locationSettings}');
    dev.log('  User Requirements: ${params.userRequirements}');
    dev.log('  Payment Method IDs: ${params.paymentMethodIds}');

    // Comprehensive parameter validation
    dev.log('🔍 USE CASE: Starting validation...');
    final validation = _validateParams(params);
    if (validation != null) {
      dev.log('💥 USE CASE: Validation failed - ${validation.message}');
      return Left(validation);
    }

    dev.log('✅ USE CASE: Validation passed, calling repository...');
    final result = await _repository.createOffer(params);

    result.fold(
      (failure) => dev.log('💥 USE CASE: Repository failed - ${failure.message}'),
      (offer) =>
          dev.log('🎉 USE CASE: Repository success - Offer ID: ${offer.id}'),
    );

    return result;
  }

  ValidationFailure? _validateParams(CreateOfferParams params) {
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

    // Validate amountConfig (now a Map) - Server-side checks only
    final amountConfig = params.amountConfig;
    final total = amountConfig['total'] as num?;

    if (total == null || total <= 0) {
      return const ValidationFailure('Total amount must be greater than 0');
    }
    // Note: Min/Max validations are handled at UI level

    // Validate priceConfig (now a Map) - Server-side checks only
    final priceConfig = params.priceConfig;
    final finalPrice = priceConfig['finalPrice'] as num?;

    if (finalPrice == null || finalPrice <= 0) {
      return const ValidationFailure('Final price must be greater than 0');
    }
    // Note: Price model validations are handled at UI level

    // Validate tradeSettings (now a Map) - Basic server-side checks
    final tradeSettings = params.tradeSettings;
    final autoCancel = tradeSettings['autoCancel'] as num?;

    if (autoCancel == null || autoCancel <= 0) {
      return const ValidationFailure('Auto cancel time must be greater than 0');
    }
    // Note: Range limits and visibility validation handled at UI level

    // Validate userRequirements (if provided) - Basic server-side checks only
    if (params.userRequirements != null) {
      final req = params.userRequirements!;
      final minCompletedTrades = req['minCompletedTrades'] as num?;
      final minSuccessRate = req['minSuccessRate'] as num?;
      final minAccountAge = req['minAccountAge'] as num?;

      // Only validate for obviously invalid negative values
      if (minCompletedTrades != null && minCompletedTrades < 0) {
        return const ValidationFailure(
            'Minimum completed trades cannot be negative');
      }
      if (minSuccessRate != null &&
          (minSuccessRate < 0 || minSuccessRate > 100)) {
        return const ValidationFailure(
            'Minimum success rate must be between 0 and 100');
      }
      if (minAccountAge != null && minAccountAge < 0) {
        return const ValidationFailure(
            'Minimum account age cannot be negative');
      }
      // Note: Range limits are handled at UI level
    }

    // Basic payment method validation - UI handles duplicates and limits
    if (params.paymentMethodIds != null &&
        params.paymentMethodIds!.isNotEmpty) {
      // Just ensure the list is not empty if provided
      // Note: Duplicate and limit checks handled at UI level
    }

    // Note: String length validations are handled at UI level

    return null;
  }
}
