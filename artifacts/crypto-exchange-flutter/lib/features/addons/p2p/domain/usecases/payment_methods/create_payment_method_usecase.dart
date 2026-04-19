import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_payment_method_entity.dart';
import '../../repositories/p2p_payment_methods_repository.dart';

/// Use case for creating a custom P2P payment method
///
/// Matches v5 backend: POST /api/ext/p2p/payment-method
/// - Creates custom payment method for authenticated user
/// - Validates required fields and user permissions
/// - Sets default icon and availability if not provided
/// - Returns created payment method with ID
@injectable
class CreatePaymentMethodUseCase
    implements UseCase<P2PPaymentMethodEntity, CreatePaymentMethodParams> {
  const CreatePaymentMethodUseCase(this._repository);

  final P2PPaymentMethodsRepository _repository;

  @override
  Future<Either<Failure, P2PPaymentMethodEntity>> call(
      CreatePaymentMethodParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Create payment method
    return await _repository.createPaymentMethod(
      name: params.name,
      icon: params.icon,
      description: params.description,
      instructions: params.instructions,
      processingTime: params.processingTime,
      available: params.available,
    );
  }

  ValidationFailure? _validateParams(CreatePaymentMethodParams params) {
    // Name is required
    if (params.name.trim().isEmpty) {
      return ValidationFailure('Payment method name is required');
    }

    // Name length validation
    if (params.name.length < 2 || params.name.length > 100) {
      return ValidationFailure(
          'Payment method name must be between 2 and 100 characters');
    }

    // Description length validation
    if (params.description?.isNotEmpty == true &&
        params.description!.length > 500) {
      return ValidationFailure('Description must not exceed 500 characters');
    }

    // Instructions length validation
    if (params.instructions?.isNotEmpty == true &&
        params.instructions!.length > 1000) {
      return ValidationFailure('Instructions must not exceed 1000 characters');
    }

    // Processing time validation
    if (params.processingTime?.isNotEmpty == true &&
        params.processingTime!.length > 100) {
      return ValidationFailure(
          'Processing time must not exceed 100 characters');
    }

    return null;
  }
}

/// Parameters for creating a payment method
class CreatePaymentMethodParams {
  const CreatePaymentMethodParams({
    required this.name,
    this.icon,
    this.description,
    this.instructions,
    this.processingTime,
    this.available = true,
  });

  /// Payment method name (required)
  final String name;

  /// Icon identifier or URL
  final String? icon;

  /// Description of the payment method
  final String? description;

  /// Instructions for using this payment method
  final String? instructions;

  /// Expected processing time
  final String? processingTime;

  /// Whether the payment method is available
  final bool available;
}
