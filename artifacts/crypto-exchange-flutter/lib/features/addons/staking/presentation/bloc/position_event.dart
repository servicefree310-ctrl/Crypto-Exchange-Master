import 'package:equatable/equatable.dart';

abstract class PositionEvent extends Equatable {
  const PositionEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger loading of user positions
class LoadUserPositions extends PositionEvent {
  final String? poolId;
  final String? status;
  final bool forceRefresh;

  const LoadUserPositions({
    this.poolId,
    this.status,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [poolId, status, forceRefresh];
}

/// Request to withdraw a position
class WithdrawRequested extends PositionEvent {
  final String positionId;

  const WithdrawRequested(this.positionId);

  @override
  List<Object?> get props => [positionId];
}

/// Request to claim rewards for a position
class ClaimRewardsRequested extends PositionEvent {
  final String positionId;

  const ClaimRewardsRequested(this.positionId);

  @override
  List<Object?> get props => [positionId];
}
