import '../../domain/entities/mlm_network_entity.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_model.dart';

class MlmNetworkModel {
  const MlmNetworkModel({
    required this.userProfile,
    required this.mlmSystem,
    this.upline,
    required this.totalRewards,
    required this.treeData,
    this.referrals,
    this.binaryStructure,
    this.levels,
  });

  final MlmUserModel userProfile;
  final String mlmSystem;
  final MlmUserModel? upline;
  final double totalRewards;
  final MlmNetworkNodeModel treeData;
  final List<MlmReferralNodeModel>? referrals;
  final MlmBinaryStructureModel? binaryStructure;
  final List<List<MlmNetworkNodeModel>>? levels;

  factory MlmNetworkModel.fromJson(Map<String, dynamic> json) {
    return MlmNetworkModel(
      userProfile: MlmUserModel.fromJson(json['userProfile'] ?? {}),
      mlmSystem: json['mlmSystem'] ?? 'DIRECT',
      upline:
          json['upline'] != null ? MlmUserModel.fromJson(json['upline']) : null,
      totalRewards: (json['totalRewards'] ?? 0).toDouble(),
      treeData: MlmNetworkNodeModel.fromJson(json['treeData'] ?? {}),
      referrals: json['referrals'] != null
          ? (json['referrals'] as List)
              .map((e) => MlmReferralNodeModel.fromJson(e))
              .toList()
          : null,
      binaryStructure: json['binaryStructure'] != null
          ? MlmBinaryStructureModel.fromJson(json['binaryStructure'])
          : null,
      levels: json['levels'] != null
          ? (json['levels'] as List)
              .map((levelList) => (levelList as List)
                  .map((e) => MlmNetworkNodeModel.fromJson(e))
                  .toList())
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userProfile': userProfile.toJson(),
      'mlmSystem': mlmSystem,
      'upline': upline?.toJson(),
      'totalRewards': totalRewards,
      'treeData': treeData.toJson(),
      'referrals': referrals?.map((e) => e.toJson()).toList(),
      'binaryStructure': binaryStructure?.toJson(),
      'levels': levels
          ?.map((level) => level.map((e) => e.toJson()).toList())
          .toList(),
    };
  }
}

class MlmNetworkNodeModel {
  const MlmNetworkNodeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.status,
    this.joinDate,
    required this.earnings,
    required this.teamSize,
    required this.performance,
    this.role,
    required this.level,
    required this.downlines,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String status;
  final String? joinDate;
  final double earnings;
  final int teamSize;
  final double performance;
  final String? role;
  final int level;
  final List<MlmNetworkNodeModel> downlines;

  factory MlmNetworkNodeModel.fromJson(Map<String, dynamic> json) {
    return MlmNetworkNodeModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatar: json['avatar'],
      status: json['status'] ?? 'active',
      joinDate: json['joinDate'],
      earnings: (json['earnings'] ?? 0).toDouble(),
      teamSize: json['teamSize'] ?? 0,
      performance: (json['performance'] ?? 0).toDouble(),
      role: json['role'],
      level: json['level'] ?? 0,
      downlines: json['downlines'] != null
          ? (json['downlines'] as List)
              .map((e) => MlmNetworkNodeModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'status': status,
      'joinDate': joinDate,
      'earnings': earnings,
      'teamSize': teamSize,
      'performance': performance,
      'role': role,
      'level': level,
      'downlines': downlines.map((e) => e.toJson()).toList(),
    };
  }
}

class MlmReferralNodeModel {
  const MlmReferralNodeModel({
    required this.id,
    required this.referred,
    required this.referrerId,
    required this.status,
    required this.createdAt,
    required this.earnings,
    required this.teamSize,
    required this.performance,
    required this.downlines,
  });

  final String id;
  final MlmNetworkNodeModel referred;
  final String referrerId;
  final String status;
  final String createdAt;
  final double earnings;
  final int teamSize;
  final double performance;
  final List<MlmNetworkNodeModel> downlines;

  factory MlmReferralNodeModel.fromJson(Map<String, dynamic> json) {
    return MlmReferralNodeModel(
      id: json['id'] ?? '',
      referred: MlmNetworkNodeModel.fromJson(json['referred'] ?? {}),
      referrerId: json['referrerId'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      earnings: (json['earnings'] ?? 0).toDouble(),
      teamSize: json['teamSize'] ?? 0,
      performance: (json['performance'] ?? 0).toDouble(),
      downlines: json['downlines'] != null
          ? (json['downlines'] as List)
              .map((e) => MlmNetworkNodeModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referred': referred.toJson(),
      'referrerId': referrerId,
      'status': status,
      'createdAt': createdAt,
      'earnings': earnings,
      'teamSize': teamSize,
      'performance': performance,
      'downlines': downlines.map((e) => e.toJson()).toList(),
    };
  }
}

class MlmBinaryStructureModel {
  const MlmBinaryStructureModel({
    this.left,
    this.right,
  });

  final MlmNetworkNodeModel? left;
  final MlmNetworkNodeModel? right;

  factory MlmBinaryStructureModel.fromJson(Map<String, dynamic> json) {
    return MlmBinaryStructureModel(
      left: json['left'] != null
          ? MlmNetworkNodeModel.fromJson(json['left'])
          : null,
      right: json['right'] != null
          ? MlmNetworkNodeModel.fromJson(json['right'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left?.toJson(),
      'right': right?.toJson(),
    };
  }
}

// Extensions to convert models to entities
extension MlmNetworkModelX on MlmNetworkModel {
  MlmNetworkEntity toEntity() {
    return MlmNetworkEntity(
      userProfile: userProfile.toEntity(),
      mlmSystem: _convertStringToMlmSystem(mlmSystem),
      upline: upline?.toEntity(),
      totalRewards: totalRewards,
      treeData: treeData.toEntity(),
      referrals: referrals?.map((e) => e.toEntity()).toList(),
      binaryStructure: binaryStructure?.toEntity(),
      levels: levels
          ?.map((level) => level.map((e) => e.toEntity()).toList())
          .toList(),
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

extension MlmNetworkNodeModelX on MlmNetworkNodeModel {
  MlmNetworkNodeEntity toEntity() {
    return MlmNetworkNodeEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      status: status,
      joinDate: joinDate,
      earnings: earnings,
      teamSize: teamSize,
      performance: performance,
      role: role,
      level: level,
      downlines: downlines.map((e) => e.toEntity()).toList(),
    );
  }
}

extension MlmReferralNodeModelX on MlmReferralNodeModel {
  MlmReferralNodeEntity toEntity() {
    return MlmReferralNodeEntity(
      id: id,
      referred: referred.toEntity(),
      referrerId: referrerId,
      status: status,
      createdAt: createdAt,
      earnings: earnings,
      teamSize: teamSize,
      performance: performance,
      downlines: downlines.map((e) => e.toEntity()).toList(),
    );
  }
}

extension MlmBinaryStructureModelX on MlmBinaryStructureModel {
  MlmBinaryStructureEntity toEntity() {
    return MlmBinaryStructureEntity(
      left: left?.toEntity(),
      right: right?.toEntity(),
    );
  }
}
