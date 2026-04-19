import 'package:equatable/equatable.dart';

abstract class MlmNetworkEvent extends Equatable {
  const MlmNetworkEvent();

  @override
  List<Object?> get props => [];
}

class MlmNetworkLoadRequested extends MlmNetworkEvent {
  const MlmNetworkLoadRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class MlmNetworkRefreshRequested extends MlmNetworkEvent {
  const MlmNetworkRefreshRequested();
}

class MlmNetworkRetryRequested extends MlmNetworkEvent {
  const MlmNetworkRetryRequested();
}
