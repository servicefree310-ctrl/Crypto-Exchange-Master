class StakingPositionEntity {
  final String id;
  final String poolId;
  final String status;
  final DateTime createdAt;
  final DateTime? endDate;
  final double amount;
  final double earningsTotal;
  final double earningsUnclaimed;
  final int? timeRemaining;

  const StakingPositionEntity({
    required this.id,
    required this.poolId,
    required this.status,
    required this.createdAt,
    this.endDate,
    required this.amount,
    required this.earningsTotal,
    required this.earningsUnclaimed,
    this.timeRemaining,
  });
}
