import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_payment_method_entity.dart';
import '../../repositories/p2p_payment_methods_repository.dart';

/// Use case for updating a custom P2P payment method
///
/// Matches v5 backend: PUT /api/ext/p2p/payment-method/{id}
/// - Updates existing custom payment method
/// - Validates user ownership
/// - Only updates provided fields (partial update)
/// - Returns updated payment method
@injectable
class UpdatePaymentMethodUseCase
    implements UseCase<P2PPaymentMethodEntity, UpdatePaymentMethodParams> {
  const UpdatePaymentMethodUseCase(this._repository);

  final P2PPaymentMethodsRepository _repository;

  @override
  Future<Either<Failure, P2PPaymentMethodEntity>> call(
      UpdatePaymentMethodParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Update payment method
    return await _repository.updatePaymentMethod(
      id: params.id,
      name: params.name,
      icon: params.icon,
      description: params.description,
      instructions: params.instructions,
      processingTime: params.processingTime,
      available: params.available,
    );
  }

  ValidationFailure? _validateParams(UpdatePaymentMethodParams params) {
    // ID validation
    if (params.id.trim().isEmpty) {
      return ValidationFailure('Payment method ID is required');
    }

    // Name validation (if provided)
    if (params.name?.isNotEmpty == true) {
      if (params.name!.length < 2 || params.name!.length > 100) {
        return ValidationFailure(
            'Payment method name must be between 2 and 100 characters');
      }
    }

    // Description validation (if provided)
    if (params.description?.isNotEmpty == true &&
        params.description!.length > 500) {
      return ValidationFailure('Description must not exceed 500 characters');
    }

    // Instructions validation (if provided)
    if (params.instructions?.isNotEmpty == true &&
        params.instructions!.length > 1000) {
      return ValidationFailure('Instructions must not exceed 1000 characters');
    }

    // Processing time validation (if provided)
    if (params.processingTime?.isNotEmpty == true &&
        params.processingTime!.length > 100) {
      return ValidationFailure(
          'Processing time must not exceed 100 characters');
    }

    return null;
  }
}

/// Parameters for updating a payment method
class UpdatePaymentMethodParams {
  const UpdatePaymentMethodParams({
    required this.id,
    this.name,
    this.icon,
    this.description,
    this.instructions,
    this.processingTime,
    this.available,
  });

  /// Payment method ID
  final String id;

  /// Updated payment method name
  final String? name;

  /// Updated icon identifier or URL
  final String? icon;

  /// Updated description
  final String? description;

  /// Updated instructions
  final String? instructions;

  /// Updated processing time
  final String? processingTime;

  /// Updated availability status
  final bool? available;
}
