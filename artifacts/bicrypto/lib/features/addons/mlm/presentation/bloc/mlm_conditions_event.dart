import 'package:equatable/equatable.dart';

abstract class MlmConditionsEvent extends Equatable {
  const MlmConditionsEvent();

  @override
  List<Object?> get props => [];
}

class MlmConditionsLoadRequested extends MlmConditionsEvent {
  const MlmConditionsLoadRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class MlmConditionsRefreshRequested extends MlmConditionsEvent {
  const MlmConditionsRefreshRequested();
}

class MlmConditionsRetryRequested extends MlmConditionsEvent {
  const MlmConditionsRetryRequested();
}
