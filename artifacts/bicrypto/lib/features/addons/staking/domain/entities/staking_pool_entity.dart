class StakingPoolEntity {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String symbol;
  final double apr;
  final double minStake;
  final double? maxStake;
  final int lockPeriod; // in days
  final double availableToStake;
  final double totalStaked;
  final String status;
  final String poolType;
  final bool isPromoted;
  final bool autoCompound;
  final int? maxPositionsPerUser;
  final double? earlyWithdrawalPenalty;
  final int order;
  final double tvl; // Total Value Locked
  final int? totalUsers;
  final double? totalRewardsDistributed;
  final double? userStaked;
  final int? userPositionCount;

  const StakingPoolEntity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.symbol,
    required this.apr,
    required this.minStake,
    this.maxStake,
    required this.lockPeriod,
    required this.availableToStake,
    required this.totalStaked,
    required this.status,
    required this.poolType,
    this.isPromoted = false,
    this.autoCompound = false,
    this.maxPositionsPerUser,
    this.earlyWithdrawalPenalty,
    this.order = 0,
    required this.tvl,
    this.totalUsers,
    this.totalRewardsDistributed,
    this.userStaked,
    this.userPositionCount,
  });
}
