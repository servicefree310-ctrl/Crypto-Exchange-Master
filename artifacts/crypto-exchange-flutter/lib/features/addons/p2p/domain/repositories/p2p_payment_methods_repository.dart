import 'package:dartz/dartz.dart';
import '../../../../../../../../core/errors/failures.dart';
import '../entities/p2p_payment_method_entity.dart';

/// Repository interface for P2P payment method operations
///
/// Defines all payment method-related operations that can be performed
/// Implementation will handle API calls to backend endpoints
abstract class P2PPaymentMethodsRepository {
  /// Get available payment methods
  /// Matches: GET /api/ext/p2p/payment-method
  Future<Either<Failure, List<P2PPaymentMethodEntity>>> getPaymentMethods({
    bool includeCustom = false,
    bool onlyAvailable = true,
  });

  /// Create a custom payment method
  /// Matches: POST /api/ext/p2p/payment-method
  Future<Either<Failure, P2PPaymentMethodEntity>> createPaymentMethod({
    required String name,
    String? icon,
    String? description,
    String? instructions,
    String? processingTime,
    bool available = true,
  });

  /// Update a payment method
  /// Matches: PUT /api/ext/p2p/payment-method/{id}
  Future<Either<Failure, P2PPaymentMethodEntity>> updatePaymentMethod({
    required String id,
    String? name,
    String? icon,
    String? description,
    String? instructions,
    String? processingTime,
    bool? available,
  });

  /// Delete a payment method
  /// Matches: DELETE /api/ext/p2p/payment-method/{id}
  Future<Either<Failure, void>> deletePaymentMethod({
    required String id,
  });
}
