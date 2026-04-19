import 'package:equatable/equatable.dart';

abstract class StakingEvent extends Equatable {
  const StakingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load staking pools with optional filters
class LoadStakingData extends StakingEvent {
  final String? status;
  final double? minApr;
  final double? maxApr;
  final String? token;
  final bool forceRefresh;

  const LoadStakingData({
    this.status,
    this.minApr,
    this.maxApr,
    this.token,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [status, minApr, maxApr, token, forceRefresh];
}
