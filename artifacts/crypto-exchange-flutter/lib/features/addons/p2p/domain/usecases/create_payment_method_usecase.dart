import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/p2p_payment_methods_repository.dart';

class CreatePaymentMethodParams extends Equatable {
  const CreatePaymentMethodParams({
    required this.name,
    this.icon,
    this.description,
    this.instructions,
    this.processingTime,
    this.available = true,
  });

  final String name;
  final String? icon;
  final String? description;
  final String? instructions;
  final String? processingTime;
  final bool available;

  @override
  List<Object?> get props => [
        name,
        icon,
        description,
        instructions,
        processingTime,
        available,
      ];
}

@injectable
class CreatePaymentMethodUseCase
    implements UseCase<PaymentMethodEntity, CreatePaymentMethodParams> {
  const CreatePaymentMethodUseCase(this._repository);

  final P2PPaymentMethodsRepository _repository;

  @override
  Future<Either<Failure, PaymentMethodEntity>> call(
      CreatePaymentMethodParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Create payment method through repository
    final result = await _repository.createPaymentMethod(
      name: params.name,
      icon: params.icon,
      description: params.description,
      instructions: params.instructions,
      processingTime: params.processingTime,
      available: params.available,
    );

    return result.fold(
      (failure) => Left(failure),
      (p2pMethod) {
        // Convert P2PPaymentMethodEntity to PaymentMethodEntity
        final entity = PaymentMethodEntity(
          id: p2pMethod.id,
          name: p2pMethod.name,
          icon: p2pMethod.config?['icon'] ?? 'credit_card',
          description: p2pMethod.config?['description'] ?? '',
          available: p2pMethod.isEnabled,
          userId: p2pMethod.config?['userId'],
          processingTime: p2pMethod.config?['processingTime'],
          fees: p2pMethod.config?['fees'],
          instructions: p2pMethod.config?['instructions'],
          popularityRank: p2pMethod.config?['popularityRank'],
        );

        return Right(entity);
      },
    );
  }

  ValidationFailure? _validateParams(CreatePaymentMethodParams params) {
    if (params.name.trim().isEmpty) {
      return const ValidationFailure('Payment method name is required');
    }

    if (params.name.trim().length < 2) {
      return const ValidationFailure(
          'Payment method name must be at least 2 characters');
    }

    if (params.name.trim().length > 50) {
      return const ValidationFailure(
          'Payment method name must be less than 50 characters');
    }

    return null;
  }
}
