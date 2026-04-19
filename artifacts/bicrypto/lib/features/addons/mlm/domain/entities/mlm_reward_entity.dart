import 'package:equatable/equatable.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_entity.dart';
import 'mlm_condition_entity.dart';

class MlmRewardEntity extends Equatable {
  const MlmRewardEntity({
    required this.id,
    required this.referrerId,
    this.conditionId,
    required this.reward,
    required this.currency,
    this.walletType,
    this.chain,
    required this.isClaimed,
    required this.createdAt,
    this.claimedAt,
    this.referrer,
    this.condition,
    required this.type,
    required this.status,
    required this.amount,
    this.description,
  });

  final String id;
  final String referrerId;
  final String? conditionId;
  final double reward;
  final String currency;
  final MlmRewardWalletType? walletType;
  final String? chain;
  final bool isClaimed;
  final DateTime createdAt;
  final DateTime? claimedAt;
  final MlmUserEntity? referrer;
  final MlmConditionEntity? condition;
  final MlmRewardType type;
  final MlmRewardStatus status;
  final double amount;
  final String? description;

  @override
  List<Object?> get props => [
        id,
        referrerId,
        conditionId,
        reward,
        currency,
        walletType,
        chain,
        isClaimed,
        createdAt,
        claimedAt,
        referrer,
        condition,
        type,
        status,
        amount,
        description,
      ];

  MlmRewardEntity copyWith({
    String? id,
    String? referrerId,
    String? conditionId,
    double? reward,
    String? currency,
    MlmRewardWalletType? walletType,
    String? chain,
    bool? isClaimed,
    DateTime? createdAt,
    DateTime? claimedAt,
    MlmUserEntity? referrer,
    MlmConditionEntity? condition,
    MlmRewardType? type,
    MlmRewardStatus? status,
    double? amount,
    String? description,
  }) {
    return MlmRewardEntity(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      conditionId: conditionId ?? this.conditionId,
      reward: reward ?? this.reward,
      currency: currency ?? this.currency,
      walletType: walletType ?? this.walletType,
      chain: chain ?? this.chain,
      isClaimed: isClaimed ?? this.isClaimed,
      createdAt: createdAt ?? this.createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
      referrer: referrer ?? this.referrer,
      condition: condition ?? this.condition,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}
