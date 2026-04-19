import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_network_entity.dart';

abstract class MlmNetworkState extends Equatable {
  const MlmNetworkState();

  @override
  List<Object?> get props => [];
}

class MlmNetworkInitial extends MlmNetworkState {
  const MlmNetworkInitial();
}

class MlmNetworkLoading extends MlmNetworkState {
  const MlmNetworkLoading();
}

class MlmNetworkLoaded extends MlmNetworkState {
  const MlmNetworkLoaded({
    required this.network,
  });

  final MlmNetworkEntity network;

  @override
  List<Object?> get props => [network];
}

class MlmNetworkRefreshing extends MlmNetworkState {
  const MlmNetworkRefreshing({
    required this.currentNetwork,
  });

  final MlmNetworkEntity currentNetwork;

  @override
  List<Object?> get props => [currentNetwork];
}

class MlmNetworkError extends MlmNetworkState {
  const MlmNetworkError({
    required this.failure,
    this.previousNetwork,
  });

  final Failure failure;
  final MlmNetworkEntity? previousNetwork;

  @override
  List<Object?> get props => [failure, previousNetwork];
}
