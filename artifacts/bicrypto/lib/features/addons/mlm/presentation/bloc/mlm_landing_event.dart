import 'package:equatable/equatable.dart';

abstract class MlmLandingEvent extends Equatable {
  const MlmLandingEvent();

  @override
  List<Object?> get props => [];
}

class MlmLandingLoadRequested extends MlmLandingEvent {
  const MlmLandingLoadRequested();
}

class MlmLandingRefreshRequested extends MlmLandingEvent {
  const MlmLandingRefreshRequested();
}

class MlmLandingRetryRequested extends MlmLandingEvent {
  const MlmLandingRetryRequested();
}
