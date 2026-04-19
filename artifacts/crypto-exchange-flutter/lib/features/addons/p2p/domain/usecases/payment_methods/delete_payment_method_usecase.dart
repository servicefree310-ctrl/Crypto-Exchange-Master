import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_payment_methods_repository.dart';

/// Use case for deleting a custom P2P payment method
///
/// Matches v5 backend: DELETE /api/ext/p2p/payment-method/{id}
/// - Deletes user-owned custom payment method
/// - Validates user ownership and permissions
/// - Only allows deletion of custom methods (not system methods)
/// - Returns void on successful deletion
@injectable
class DeletePaymentMethodUseCase
    implements UseCase<void, DeletePaymentMethodParams> {
  const DeletePaymentMethodUseCase(this._repository);

  final P2PPaymentMethodsRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeletePaymentMethodParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Delete payment method
    return await _repository.deletePaymentMethod(
      id: params.id,
    );
  }

  ValidationFailure? _validateParams(DeletePaymentMethodParams params) {
    // ID validation
    if (params.id.trim().isEmpty) {
      return ValidationFailure('Payment method ID is required');
    }

    return null;
  }
}

/// Parameters for deleting a payment method
class DeletePaymentMethodParams {
  const DeletePaymentMethodParams({
    required this.id,
  });

  /// Payment method ID to delete
  final String id;
}
