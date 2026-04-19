import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spot_deposit_address_entity.dart';
import '../repositories/spot_deposit_repository.dart';

class GenerateSpotDepositAddressParams extends Equatable {
  const GenerateSpotDepositAddressParams({
    required this.currency,
    required this.network,
  });

  final String currency;
  final String network;

  @override
  List<Object> get props => [currency, network];
}

@injectable
class GenerateSpotDepositAddressUseCase
    implements
        UseCase<SpotDepositAddressEntity, GenerateSpotDepositAddressParams> {
  const GenerateSpotDepositAddressUseCase(this._repository);

  final SpotDepositRepository _repository;

  @override
  Future<Either<Failure, SpotDepositAddressEntity>> call(
      GenerateSpotDepositAddressParams params) {
    return _repository.generateDepositAddress(params.currency, params.network);
  }
}
