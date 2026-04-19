import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/errors/failures.dart';
import '../../entities/p2p_trade_entity.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for initiating a new P2P trade from an offer
///
/// Based on v5 backend pattern where trades are created from offers
/// - Validates offer availability and user eligibility
/// - Creates escrow transaction
/// - Sets initial trade status and timeline
/// - Validates trade amount within offer limits
@injectable
class InitiateTradeUseCase
    implements UseCase<P2PTradeEntity, InitiateTradeParams> {
  const InitiateTradeUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, P2PTradeEntity>> call(
      InitiateTradeParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call to initiate trade
    return await _repository.initiateTrade(
      offerId: params.offerId,
      amount: params.amount,
      fiatAmount: params.fiatAmount,
      paymentMethodId: params.paymentMethodId,
      message: params.message,
      autoAcceptTime: params.autoAcceptTime,
    );
  }

  ValidationFailure? _validateParams(InitiateTradeParams params) {
    // Validate offer ID
    if (params.offerId.isEmpty) {
      return ValidationFailure('Offer ID cannot be empty');
    }

    // Validate UUID format for offer ID
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(params.offerId)) {
      return ValidationFailure('Invalid offer ID format');
    }

    // Validate crypto amount
    if (params.amount <= 0) {
      return ValidationFailure('Trade amount must be greater than 0');
    }

    // Validate precision (max 8 decimal places for crypto)
    final amountString = params.amount.toString();
    final decimalIndex = amountString.indexOf('.');
    if (decimalIndex != -1 && amountString.length - decimalIndex - 1 > 8) {
      return ValidationFailure(
          'Amount precision cannot exceed 8 decimal places');
    }

    // Validate fiat amount if provided
    if (params.fiatAmount != null) {
      if (params.fiatAmount! <= 0) {
        return ValidationFailure('Fiat amount must be greater than 0');
      }

      // Validate fiat precision (max 2 decimal places)
      final fiatString = params.fiatAmount.toString();
      final fiatDecimalIndex = fiatString.indexOf('.');
      if (fiatDecimalIndex != -1 &&
          fiatString.length - fiatDecimalIndex - 1 > 2) {
        return ValidationFailure(
            'Fiat amount precision cannot exceed 2 decimal places');
      }
    }

    // Validate payment method ID
    if (params.paymentMethodId.isEmpty) {
      return ValidationFailure('Payment method ID cannot be empty');
    }

    if (!uuidRegex.hasMatch(params.paymentMethodId)) {
      return ValidationFailure('Invalid payment method ID format');
    }

    // Validate message length
    if (params.message != null && params.message!.length > 500) {
      return ValidationFailure('Message cannot exceed 500 characters');
    }

    // Validate auto accept time
    if (params.autoAcceptTime != null) {
      if (params.autoAcceptTime! < 5 || params.autoAcceptTime! > 60) {
        return ValidationFailure(
            'Auto accept time must be between 5 and 60 minutes');
      }
    }

    return null;
  }
}

/// Parameters for initiating a trade
class InitiateTradeParams {
  const InitiateTradeParams({
    required this.offerId,
    required this.amount,
    this.fiatAmount,
    required this.paymentMethodId,
    this.message,
    this.autoAcceptTime,
  });

  /// ID of the offer to trade against
  final String offerId;

  /// Amount of cryptocurrency to trade
  final double amount;

  /// Fiat amount (calculated if not provided)
  final double? fiatAmount;

  /// Payment method to use for this trade
  final String paymentMethodId;

  /// Optional message to seller
  final String? message;

  /// Auto-accept timeout in minutes (5-60)
  final int? autoAcceptTime;
}
