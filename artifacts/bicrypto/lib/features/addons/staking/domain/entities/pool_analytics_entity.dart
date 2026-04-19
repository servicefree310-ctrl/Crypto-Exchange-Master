import 'package:equatable/equatable.dart';

/// Entity representing detailed analytics for a staking pool
class PoolAnalyticsEntity extends Equatable {
  final String poolId;
  final String poolName;
  final String tokenSymbol;
  final double apr;
  final double totalStaked;
  final int totalStakers;
  final double totalEarnings;
  final List<Map<String, dynamic>> performanceHistory;
  final List<Map<String, dynamic>> stakingGrowth;
  final List<Map<String, dynamic>> withdrawals;
  final String timeframe;

  const PoolAnalyticsEntity({
    required this.poolId,
    required this.poolName,
    required this.tokenSymbol,
    required this.apr,
    required this.totalStaked,
    required this.totalStakers,
    required this.totalEarnings,
    required this.performanceHistory,
    required this.stakingGrowth,
    required this.withdrawals,
    required this.timeframe,
  });

  @override
  List<Object?> get props => [
        poolId,
        poolName,
        tokenSymbol,
        apr,
        totalStaked,
        totalStakers,
        totalEarnings,
        performanceHistory,
        stakingGrowth,
        withdrawals,
        timeframe,
      ];
}
