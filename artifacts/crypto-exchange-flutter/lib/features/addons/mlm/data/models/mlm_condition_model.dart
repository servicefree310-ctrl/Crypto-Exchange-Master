import '../../domain/entities/mlm_condition_entity.dart';
import '../../../../../core/constants/api_constants.dart';

class MlmConditionModel {
  const MlmConditionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.rewardType,
    required this.rewardCurrency,
    this.rewardWalletType,
    this.rewardChain,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.name,
    this.type,
    this.image,
  });

  final String id;
  final String title;
  final String description;
  final double reward;
  final String rewardType;
  final String rewardCurrency;
  final String? rewardWalletType;
  final String? rewardChain;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;
  final String? name;
  final String? type;
  final String? image;

  factory MlmConditionModel.fromJson(Map<String, dynamic> json) {
    return MlmConditionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      reward: (json['reward'] ?? 0).toDouble(),
      rewardType: json['rewardType'] ?? 'FIXED',
      rewardCurrency: json['rewardCurrency'] ?? 'USD',
      rewardWalletType: json['rewardWalletType'],
      rewardChain: json['rewardChain'],
      isActive: json['isActive'] ?? json['status'] ?? true,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'],
      name: json['name'],
      type: json['type'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'rewardType': rewardType,
      'rewardCurrency': rewardCurrency,
      'rewardWalletType': rewardWalletType,
      'rewardChain': rewardChain,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'type': type,
      'image': image,
    };
  }
}

extension MlmConditionModelX on MlmConditionModel {
  MlmConditionEntity toEntity() {
    return MlmConditionEntity(
      id: id,
      title: title,
      description: description,
      reward: reward,
      rewardType: _convertStringToRewardType(rewardType),
      rewardCurrency: rewardCurrency,
      rewardWalletType: _convertStringToWalletType(rewardWalletType),
      rewardChain: rewardChain,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  MlmRewardType _convertStringToRewardType(String rewardType) {
    switch (rewardType.toUpperCase()) {
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
}

extension MlmConditionEntityX on MlmConditionEntity {
  MlmConditionModel toModel() {
    return MlmConditionModel(
      id: id,
      title: title,
      description: description,
      reward: reward,
      rewardType: rewardType.name.toUpperCase(),
      rewardCurrency: rewardCurrency,
      rewardWalletType: rewardWalletType?.name.toUpperCase(),
      rewardChain: rewardChain,
      isActive: isActive,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
    );
  }
}
