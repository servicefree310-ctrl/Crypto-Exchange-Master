import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spot_network_entity.dart';
import '../repositories/spot_deposit_repository.dart';

class GetSpotNetworksParams extends Equatable {
  const GetSpotNetworksParams({required this.currency});

  final String currency;

  @override
  List<Object> get props => [currency];
}

@injectable
class GetSpotNetworksUseCase
    implements UseCase<List<SpotNetworkEntity>, GetSpotNetworksParams> {
  const GetSpotNetworksUseCase(this._repository);

  final SpotDepositRepository _repository;

  @override
  Future<Either<Failure, List<SpotNetworkEntity>>> call(
      GetSpotNetworksParams params) {
    return _repository.getSpotNetworks(params.currency);
  }
}
