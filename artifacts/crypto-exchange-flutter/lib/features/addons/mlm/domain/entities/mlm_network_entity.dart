import 'package:equatable/equatable.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_entity.dart';

class MlmNetworkEntity extends Equatable {
  const MlmNetworkEntity({
    required this.userProfile,
    required this.mlmSystem,
    this.upline,
    required this.totalRewards,
    required this.treeData,
    this.referrals,
    this.binaryStructure,
    this.levels,
  });

  final MlmUserEntity userProfile;
  final MlmSystem mlmSystem;
  final MlmUserEntity? upline;
  final double totalRewards;
  final MlmNetworkNodeEntity treeData;
  final List<MlmReferralNodeEntity>? referrals; // For DIRECT system
  final MlmBinaryStructureEntity? binaryStructure; // For BINARY system
  final List<List<MlmNetworkNodeEntity>>? levels; // For UNILEVEL system

  @override
  List<Object?> get props => [
        userProfile,
        mlmSystem,
        upline,
        totalRewards,
        treeData,
        referrals,
        binaryStructure,
        levels,
      ];

  MlmNetworkEntity copyWith({
    MlmUserEntity? userProfile,
    MlmSystem? mlmSystem,
    MlmUserEntity? upline,
    double? totalRewards,
    MlmNetworkNodeEntity? treeData,
    List<MlmReferralNodeEntity>? referrals,
    MlmBinaryStructureEntity? binaryStructure,
    List<List<MlmNetworkNodeEntity>>? levels,
  }) {
    return MlmNetworkEntity(
      userProfile: userProfile ?? this.userProfile,
      mlmSystem: mlmSystem ?? this.mlmSystem,
      upline: upline ?? this.upline,
      totalRewards: totalRewards ?? this.totalRewards,
      treeData: treeData ?? this.treeData,
      referrals: referrals ?? this.referrals,
      binaryStructure: binaryStructure ?? this.binaryStructure,
      levels: levels ?? this.levels,
    );
  }
}

class MlmNetworkNodeEntity extends Equatable {
  const MlmNetworkNodeEntity({
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
  final List<MlmNetworkNodeEntity> downlines;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        avatar,
        status,
        joinDate,
        earnings,
        teamSize,
        performance,
        role,
        level,
        downlines,
      ];
}

class MlmReferralNodeEntity extends Equatable {
  const MlmReferralNodeEntity({
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
  final MlmNetworkNodeEntity referred;
  final String referrerId;
  final String status;
  final String createdAt;
  final double earnings;
  final int teamSize;
  final double performance;
  final List<MlmNetworkNodeEntity> downlines;

  @override
  List<Object?> get props => [
        id,
        referred,
        referrerId,
        status,
        createdAt,
        earnings,
        teamSize,
        performance,
        downlines,
      ];
}

class MlmBinaryStructureEntity extends Equatable {
  const MlmBinaryStructureEntity({
    this.left,
    this.right,
  });

  final MlmNetworkNodeEntity? left;
  final MlmNetworkNodeEntity? right;

  @override
  List<Object?> get props => [left, right];
}
