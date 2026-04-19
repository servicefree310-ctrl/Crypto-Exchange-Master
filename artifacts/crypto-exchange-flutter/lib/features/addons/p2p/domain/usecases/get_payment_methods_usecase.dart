import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/p2p_payment_methods_repository.dart';

@injectable
class GetPaymentMethodsUseCase
    implements UseCase<List<PaymentMethodEntity>, NoParams> {
  const GetPaymentMethodsUseCase(this._repository);

  final P2PPaymentMethodsRepository _repository;

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(
      NoParams params) async {
    // Get payment methods from repository and convert to PaymentMethodEntity
    final result = await _repository.getPaymentMethods(
      includeCustom: true,
      onlyAvailable: true,
    );

    return result.fold(
      (failure) => Left(failure),
      (paymentMethods) {
        // Convert P2PPaymentMethodEntity to PaymentMethodEntity
        final entities = paymentMethods.map((p2pMethod) {
          return PaymentMethodEntity(
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
        }).toList();

        return Right(entities);
      },
    );
  }
}
