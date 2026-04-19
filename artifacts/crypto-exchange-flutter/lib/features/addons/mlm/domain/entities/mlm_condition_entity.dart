import 'package:equatable/equatable.dart';
import '../../../../../core/constants/api_constants.dart';

class MlmConditionEntity extends Equatable {
  const MlmConditionEntity({
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
  });

  final String id;
  final String title;
  final String description;
  final double reward;
  final MlmRewardType rewardType;
  final String rewardCurrency;
  final MlmRewardWalletType? rewardWalletType;
  final String? rewardChain;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        reward,
        rewardType,
        rewardCurrency,
        rewardWalletType,
        rewardChain,
        isActive,
        createdAt,
        updatedAt,
      ];

  MlmConditionEntity copyWith({
    String? id,
    String? title,
    String? description,
    double? reward,
    MlmRewardType? rewardType,
    String? rewardCurrency,
    MlmRewardWalletType? rewardWalletType,
    String? rewardChain,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MlmConditionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      rewardType: rewardType ?? this.rewardType,
      rewardCurrency: rewardCurrency ?? this.rewardCurrency,
      rewardWalletType: rewardWalletType ?? this.rewardWalletType,
      rewardChain: rewardChain ?? this.rewardChain,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
