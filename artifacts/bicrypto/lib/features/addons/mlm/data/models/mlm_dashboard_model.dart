import '../../domain/entities/mlm_dashboard_entity.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_model.dart';

class MlmDashboardModel {
  const MlmDashboardModel({
    required this.userProfile,
    required this.stats,
    required this.previousStats,
    required this.mlmSystem,
    this.upline,
    required this.recentReferrals,
    required this.recentRewards,
    required this.earningsChart,
    required this.referralChart,
    required this.networkSummary,
  });

  final MlmUserModel userProfile;
  final MlmStatsModel stats;
  final MlmStatsModel previousStats;
  final String mlmSystem;
  final MlmUserModel? upline;
  final List<dynamic> recentReferrals;
  final List<dynamic> recentRewards;
  final List<MlmChartDataModel> earningsChart;
  final List<MlmChartDataModel> referralChart;
  final MlmNetworkSummaryModel networkSummary;

  factory MlmDashboardModel.fromJson(Map<String, dynamic> json) {
    return MlmDashboardModel(
      userProfile: MlmUserModel.fromJson(json['userProfile'] ?? {}),
      stats: MlmStatsModel.fromJson(json['stats'] ?? {}),
      previousStats: MlmStatsModel.fromJson(json['previousStats'] ?? {}),
      mlmSystem: json['mlmSystem'] ?? 'DIRECT',
      upline:
          json['upline'] != null ? MlmUserModel.fromJson(json['upline']) : null,
      recentReferrals: json['recentReferrals'] ?? [],
      recentRewards: json['recentRewards'] ?? [],
      earningsChart: (json['earningsChart'] as List?)
              ?.map((e) => MlmChartDataModel.fromJson(e))
              .toList() ??
          [],
      referralChart: (json['referralChart'] as List?)
              ?.map((e) => MlmChartDataModel.fromJson(e))
              .toList() ??
          [],
      networkSummary:
          MlmNetworkSummaryModel.fromJson(json['networkSummary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userProfile': userProfile.toJson(),
      'stats': stats.toJson(),
      'previousStats': previousStats.toJson(),
      'mlmSystem': mlmSystem,
      'upline': upline?.toJson(),
      'recentReferrals': recentReferrals,
      'recentRewards': recentRewards,
      'earningsChart': earningsChart.map((e) => e.toJson()).toList(),
      'referralChart': referralChart.map((e) => e.toJson()).toList(),
      'networkSummary': networkSummary.toJson(),
    };
  }
}

class MlmStatsModel {
  const MlmStatsModel({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.pendingReferrals,
    required this.conversionRate,
    required this.totalEarnings,
    required this.weeklyGrowth,
  });

  final int totalReferrals;
  final int activeReferrals;
  final int pendingReferrals;
  final double conversionRate;
  final double totalEarnings;
  final double weeklyGrowth;

  factory MlmStatsModel.fromJson(Map<String, dynamic> json) {
    return MlmStatsModel(
      totalReferrals: json['totalReferrals'] ?? 0,
      activeReferrals: json['activeReferrals'] ?? 0,
      pendingReferrals: json['pendingReferrals'] ?? 0,
      conversionRate: (json['conversionRate'] ?? 0).toDouble(),
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      weeklyGrowth: (json['weeklyGrowth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReferrals': totalReferrals,
      'activeReferrals': activeReferrals,
      'pendingReferrals': pendingReferrals,
      'conversionRate': conversionRate,
      'totalEarnings': totalEarnings,
      'weeklyGrowth': weeklyGrowth,
    };
  }
}

class MlmChartDataModel {
  const MlmChartDataModel({
    required this.period,
    required this.value,
    required this.date,
  });

  final String period;
  final double value;
  final String date;

  factory MlmChartDataModel.fromJson(Map<String, dynamic> json) {
    return MlmChartDataModel(
      period: json['period'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'value': value,
      'date': date,
    };
  }
}

class MlmNetworkSummaryModel {
  const MlmNetworkSummaryModel({
    required this.totalNetworkSize,
    required this.activeMembers,
    required this.networkDepth,
    required this.topPerformers,
    required this.totalMembers,
    required this.maxDepth,
    required this.totalVolume,
  });

  final int totalNetworkSize;
  final int activeMembers;
  final int networkDepth;
  final List<MlmUserModel> topPerformers;
  final int totalMembers;
  final int maxDepth;
  final double totalVolume;

  factory MlmNetworkSummaryModel.fromJson(Map<String, dynamic> json) {
    return MlmNetworkSummaryModel(
      totalNetworkSize: json['totalNetworkSize'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      networkDepth: json['networkDepth'] ?? 0,
      topPerformers: (json['topPerformers'] as List?)
              ?.map((e) => MlmUserModel.fromJson(e))
              .toList() ??
          [],
      totalMembers: json['totalMembers'] ?? json['totalNetworkSize'] ?? 0,
      maxDepth: json['maxDepth'] ?? json['networkDepth'] ?? 0,
      totalVolume: (json['totalVolume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNetworkSize': totalNetworkSize,
      'activeMembers': activeMembers,
      'networkDepth': networkDepth,
      'topPerformers': topPerformers.map((e) => e.toJson()).toList(),
      'totalMembers': totalMembers,
      'maxDepth': maxDepth,
      'totalVolume': totalVolume,
    };
  }
}

// Extension to convert model to entity
extension MlmDashboardModelX on MlmDashboardModel {
  MlmDashboardEntity toEntity() {
    return MlmDashboardEntity(
      userProfile: userProfile.toEntity(),
      stats: stats.toEntity(),
      previousStats: previousStats.toEntity(),
      mlmSystem: _convertStringToMlmSystem(mlmSystem),
      upline: upline?.toEntity(),
      recentReferrals: [], // Will be converted properly when models are complete
      recentRewards: [], // Will be converted properly when models are complete
      earningsChart: earningsChart.map((e) => e.toEntity()).toList(),
      referralChart: referralChart.map((e) => e.toEntity()).toList(),
      networkSummary: networkSummary.toEntity(),
    );
  }

  MlmSystem _convertStringToMlmSystem(String system) {
    switch (system.toUpperCase()) {
      case 'BINARY':
        return MlmSystem.binary;
      case 'UNILEVEL':
        return MlmSystem.unilevel;
      default:
        return MlmSystem.direct;
    }
  }
}

extension MlmStatsModelX on MlmStatsModel {
  MlmStatsEntity toEntity() {
    return MlmStatsEntity(
      totalReferrals: totalReferrals,
      activeReferrals: activeReferrals,
      pendingReferrals: pendingReferrals,
      conversionRate: conversionRate,
      totalEarnings: totalEarnings,
      weeklyGrowth: weeklyGrowth,
    );
  }
}

extension MlmChartDataModelX on MlmChartDataModel {
  MlmChartDataEntity toEntity() {
    return MlmChartDataEntity(
      period: period,
      value: value,
      date: DateTime.parse(date),
    );
  }
}

extension MlmNetworkSummaryModelX on MlmNetworkSummaryModel {
  MlmNetworkSummaryEntity toEntity() {
    return MlmNetworkSummaryEntity(
      totalNetworkSize: totalNetworkSize,
      activeMembers: activeMembers,
      networkDepth: networkDepth,
      topPerformers: topPerformers.map((e) => e.toEntity()).toList(),
      totalMembers: totalMembers,
      maxDepth: maxDepth,
      totalVolume: totalVolume,
    );
  }
}
