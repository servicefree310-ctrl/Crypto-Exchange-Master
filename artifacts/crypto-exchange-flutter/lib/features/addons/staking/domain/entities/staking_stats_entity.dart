import 'package:equatable/equatable.dart';

/// Entity representing overall staking platform statistics
class StakingStatsEntity extends Equatable {
  final double totalStaked;
  final int activeUsers;
  final double avgApr;
  final double totalRewards;

  const StakingStatsEntity({
    required this.totalStaked,
    required this.activeUsers,
    required this.avgApr,
    required this.totalRewards,
  });

  @override
  List<Object?> get props => [totalStaked, activeUsers, avgApr, totalRewards];
}
