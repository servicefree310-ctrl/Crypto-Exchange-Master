import '../../domain/entities/mlm_landing_entity.dart';
import 'mlm_condition_model.dart';

class MlmLandingModel {
  const MlmLandingModel({
    required this.stats,
    required this.conditions,
    required this.topAffiliates,
    required this.recentActivity,
    required this.mlmSystem,
  });

  final MlmLandingStatsModel stats;
  final List<MlmConditionModel> conditions;
  final List<MlmTopAffiliateModel> topAffiliates;
  final List<MlmActivityModel> recentActivity;
  final String mlmSystem;

  factory MlmLandingModel.fromJson(Map<String, dynamic> json) {
    return MlmLandingModel(
      stats: MlmLandingStatsModel.fromJson(json['stats'] ?? {}),
      conditions: (json['conditions'] as List?)
              ?.map((e) => MlmConditionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topAffiliates: (json['topAffiliates'] as List?)
              ?.map((e) =>
                  MlmTopAffiliateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentActivity: (json['recentActivity'] as List?)
              ?.map(
                  (e) => MlmActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mlmSystem: json['mlmSystem'] ?? 'DIRECT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'conditions': conditions.map((e) => e.toJson()).toList(),
      'topAffiliates': topAffiliates.map((e) => e.toJson()).toList(),
      'recentActivity': recentActivity.map((e) => e.toJson()).toList(),
      'mlmSystem': mlmSystem,
    };
  }
}

class MlmLandingStatsModel {
  const MlmLandingStatsModel({
    required this.totalAffiliates,
    required this.totalPaidOut,
    required this.avgMonthlyEarnings,
    required this.successRate,
  });

  final int totalAffiliates;
  final double totalPaidOut;
  final double avgMonthlyEarnings;
  final double successRate;

  factory MlmLandingStatsModel.fromJson(Map<String, dynamic> json) {
    return MlmLandingStatsModel(
      totalAffiliates: json['totalAffiliates'] ?? 0,
      totalPaidOut: (json['totalPaidOut'] ?? 0).toDouble(),
      avgMonthlyEarnings: (json['avgMonthlyEarnings'] ?? 0).toDouble(),
      successRate: (json['successRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAffiliates': totalAffiliates,
      'totalPaidOut': totalPaidOut,
      'avgMonthlyEarnings': avgMonthlyEarnings,
      'successRate': successRate,
    };
  }
}

class MlmTopAffiliateModel {
  const MlmTopAffiliateModel({
    required this.rank,
    this.avatar,
    required this.displayName,
    required this.totalEarnings,
    required this.rewardCount,
    required this.joinedAgo,
  });

  final int rank;
  final String? avatar;
  final String displayName;
  final double totalEarnings;
  final int rewardCount;
  final String joinedAgo;

  factory MlmTopAffiliateModel.fromJson(Map<String, dynamic> json) {
    return MlmTopAffiliateModel(
      rank: json['rank'] ?? 0,
      avatar: json['avatar'],
      displayName: json['displayName'] ?? '',
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      rewardCount: json['rewardCount'] ?? 0,
      joinedAgo: json['joinedAgo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'avatar': avatar,
      'displayName': displayName,
      'totalEarnings': totalEarnings,
      'rewardCount': rewardCount,
      'joinedAgo': joinedAgo,
    };
  }
}

class MlmActivityModel {
  const MlmActivityModel({
    required this.type,
    required this.amount,
    required this.conditionType,
    required this.currency,
    required this.timeAgo,
  });

  final String type;
  final double amount;
  final String conditionType;
  final String currency;
  final String timeAgo;

  factory MlmActivityModel.fromJson(Map<String, dynamic> json) {
    return MlmActivityModel(
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      conditionType: json['conditionType'] ?? '',
      currency: json['currency'] ?? 'USD',
      timeAgo: json['timeAgo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'conditionType': conditionType,
      'currency': currency,
      'timeAgo': timeAgo,
    };
  }
}

// Extension to convert model to entity
extension MlmLandingModelX on MlmLandingModel {
  MlmLandingEntity toEntity() {
    return MlmLandingEntity(
      stats: stats.toEntity(),
      conditions: conditions.map((e) => e.toEntity()).toList(),
      topAffiliates: topAffiliates.map((e) => e.toEntity()).toList(),
      recentActivity: recentActivity.map((e) => e.toEntity()).toList(),
      mlmSystem: mlmSystem,
    );
  }
}

extension MlmLandingStatsModelX on MlmLandingStatsModel {
  MlmLandingStatsEntity toEntity() {
    return MlmLandingStatsEntity(
      totalAffiliates: totalAffiliates,
      totalPaidOut: totalPaidOut,
      avgMonthlyEarnings: avgMonthlyEarnings,
      successRate: successRate,
    );
  }
}

extension MlmTopAffiliateModelX on MlmTopAffiliateModel {
  MlmTopAffiliateEntity toEntity() {
    return MlmTopAffiliateEntity(
      rank: rank,
      avatar: avatar,
      displayName: displayName,
      totalEarnings: totalEarnings,
      rewardCount: rewardCount,
      joinedAgo: joinedAgo,
    );
  }
}

extension MlmActivityModelX on MlmActivityModel {
  MlmActivityEntity toEntity() {
    return MlmActivityEntity(
      type: type,
      amount: amount,
      conditionType: conditionType,
      currency: currency,
      timeAgo: timeAgo,
    );
  }
}
