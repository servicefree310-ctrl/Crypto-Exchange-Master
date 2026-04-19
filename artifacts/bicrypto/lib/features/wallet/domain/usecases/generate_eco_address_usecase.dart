import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/eco_deposit_address_entity.dart';
import '../repositories/eco_deposit_repository.dart';

class GenerateEcoAddressParams {
  final String currency;
  final String chain;
  final String contractType; // PERMIT | NO_PERMIT | NATIVE

  const GenerateEcoAddressParams({
    required this.currency,
    required this.chain,
    required this.contractType,
  });
}

@injectable
class GenerateEcoAddressUseCase
    implements UseCase<EcoDepositAddressEntity, GenerateEcoAddressParams> {
  final EcoDepositRepository _repository;

  const GenerateEcoAddressUseCase(this._repository);

  @override
  Future<Either<Failure, EcoDepositAddressEntity>> call(
      GenerateEcoAddressParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Generate address based on contract type
    switch (params.contractType.toUpperCase()) {
      case 'PERMIT':
        return _repository.generatePermitAddress(params.currency, params.chain);
      case 'NO_PERMIT':
        return _repository.generateNoPermitAddress(
            params.currency, params.chain);
      case 'NATIVE':
        return _repository.generateNativeAddress(params.currency, params.chain);
      default:
        return const Left(ValidationFailure(
            'Invalid contract type. Must be PERMIT, NO_PERMIT, or NATIVE'));
    }
  }

  ValidationFailure? _validateParams(GenerateEcoAddressParams params) {
    if (params.currency.isEmpty) {
      return const ValidationFailure('Currency is required');
    }
    if (params.chain.isEmpty) {
      return const ValidationFailure('Chain is required');
    }
    if (params.contractType.isEmpty) {
      return const ValidationFailure('Contract type is required');
    }
    final validTypes = ['PERMIT', 'NO_PERMIT', 'NATIVE'];
    if (!validTypes.contains(params.contractType.toUpperCase())) {
      return const ValidationFailure(
          'Invalid contract type. Must be PERMIT, NO_PERMIT, or NATIVE');
    }
    return null;
  }
}
