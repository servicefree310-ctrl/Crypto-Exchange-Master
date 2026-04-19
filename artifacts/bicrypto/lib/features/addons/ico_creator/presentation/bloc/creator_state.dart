import 'package:equatable/equatable.dart';

import '../../domain/entities/creator_token_entity.dart';

abstract class CreatorState extends Equatable {
  const CreatorState();

  @override
  List<Object?> get props => [];
}

class CreatorInitial extends CreatorState {
  const CreatorInitial();
}

class CreatorLoading extends CreatorState {
  const CreatorLoading();
}

class CreatorError extends CreatorState {
  const CreatorError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CreatorDashboardLoaded extends CreatorState {
  const CreatorDashboardLoaded({required this.tokens});

  final List<CreatorTokenEntity> tokens;

  @override
  List<Object?> get props => [tokens];
}

class CreatorLaunching extends CreatorState {
  const CreatorLaunching();
}

class CreatorLaunchSuccess extends CreatorState {
  const CreatorLaunchSuccess();
}
