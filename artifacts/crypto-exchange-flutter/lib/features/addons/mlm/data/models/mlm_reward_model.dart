import '../../domain/entities/mlm_reward_entity.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_model.dart';
import 'mlm_condition_model.dart';

class MlmRewardModel {
  const MlmRewardModel({
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
  final String? walletType;
  final String? chain;
  final bool isClaimed;
  final String createdAt;
  final String? claimedAt;
  final MlmUserModel? referrer;
  final MlmConditionModel? condition;
  final String type;
  final String status;
  final double amount;
  final String? description;

  factory MlmRewardModel.fromJson(Map<String, dynamic> json) {
    return MlmRewardModel(
      id: json['id'] ?? '',
      referrerId: json['referrerId'] ?? '',
      conditionId: json['conditionId'],
      reward: (json['reward'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      walletType: json['walletType'],
      chain: json['chain'],
      isClaimed: json['isClaimed'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      claimedAt: json['claimedAt'],
      referrer: json['referrer'] != null
          ? MlmUserModel.fromJson(json['referrer'])
          : null,
      condition: json['condition'] != null
          ? MlmConditionModel.fromJson(json['condition'])
          : null,
      type: json['type'] ?? 'REFERRAL',
      status:
          json['status'] ?? (json['isClaimed'] == true ? 'CLAIMED' : 'PENDING'),
      amount: (json['amount'] ?? json['reward'] ?? 0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrerId': referrerId,
      'conditionId': conditionId,
      'reward': reward,
      'currency': currency,
      'walletType': walletType,
      'chain': chain,
      'isClaimed': isClaimed,
      'createdAt': createdAt,
      'claimedAt': claimedAt,
      'referrer': referrer?.toJson(),
      'condition': condition?.toJson(),
      'type': type,
      'status': status,
      'amount': amount,
      'description': description,
    };
  }
}

extension MlmRewardModelX on MlmRewardModel {
  MlmRewardEntity toEntity() {
    return MlmRewardEntity(
      id: id,
      referrerId: referrerId,
      conditionId: conditionId,
      reward: reward,
      currency: currency,
      walletType: _convertStringToWalletType(walletType),
      chain: chain,
      isClaimed: isClaimed,
      createdAt: DateTime.parse(createdAt),
      claimedAt: claimedAt != null ? DateTime.parse(claimedAt!) : null,
      referrer: referrer?.toEntity(),
      condition: condition?.toEntity(),
      type: _convertStringToRewardType(type),
      status: _convertStringToRewardStatus(status),
      amount: amount,
      description: description,
    );
  }

  MlmRewardWalletType? _convertStringToWalletType(String? walletType) {
    if (walletType == null) return null;
    switch (walletType.toUpperCase()) {
      case 'SPOT':
        return MlmRewardWalletType.spot;
      case 'ECO':
        return MlmRewardWalletType.eco;
      case 'FUTURES':
        return MlmRewardWalletType.futures;
      default:
        return null;
    }
  }

  MlmRewardType _convertStringToRewardType(String type) {
    switch (type.toUpperCase()) {
      case 'PERCENTAGE':
        return MlmRewardType.percentage;
      case 'FIXED':
        return MlmRewardType.fixed;
      case 'TIERED':
        return MlmRewardType.tiered;
      case 'COMMISSION':
        return MlmRewardType.commission;
      case 'BONUS':
        return MlmRewardType.bonus;
      case 'LEVEL_BONUS':
      case 'LEVELBONUS':
        return MlmRewardType.levelBonus;
      default:
        return MlmRewardType.referral;
    }
  }

  MlmRewardStatus _convertStringToRewardStatus(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return MlmRewardStatus.approved;
      case 'CLAIMED':
        return MlmRewardStatus.claimed;
      case 'REJECTED':
        return MlmRewardStatus.rejected;
      default:
        return MlmRewardStatus.pending;
    }
  }
}

extension MlmRewardEntityX on MlmRewardEntity {
  MlmRewardModel toModel() {
    return MlmRewardModel(
      id: id,
      referrerId: referrerId,
      conditionId: conditionId,
      reward: reward,
      currency: currency,
      walletType: walletType?.name.toUpperCase(),
      chain: chain,
      isClaimed: isClaimed,
      createdAt: createdAt.toIso8601String(),
      claimedAt: claimedAt?.toIso8601String(),
      referrer: referrer?.toModel(),
      condition: condition?.toModel(),
      type: type.name.toUpperCase(),
      status: status.name.toUpperCase(),
      amount: amount,
      description: description,
    );
  }
}
