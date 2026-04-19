import '../../domain/entities/mlm_referral_entity.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_model.dart';

class MlmReferralModel {
  const MlmReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.referred,
    this.referrer,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.earnings,
    this.teamSize,
    this.performance,
    this.level,
    this.downlines,
  });

  final String id;
  final String referrerId;
  final String referredId;
  final MlmUserModel referred;
  final MlmUserModel? referrer;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final double? earnings;
  final int? teamSize;
  final double? performance;
  final int? level;
  final List<MlmReferralModel>? downlines;

  factory MlmReferralModel.fromJson(Map<String, dynamic> json) {
    return MlmReferralModel(
      id: json['id'] ?? '',
      referrerId: json['referrerId'] ?? '',
      referredId: json['referredId'] ?? '',
      referred: MlmUserModel.fromJson(json['referred'] ?? {}),
      referrer: json['referrer'] != null
          ? MlmUserModel.fromJson(json['referrer'])
          : null,
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'],
      earnings: json['earnings']?.toDouble(),
      teamSize: json['teamSize']?.toInt(),
      performance: json['performance']?.toDouble(),
      level: json['level']?.toInt(),
      downlines: json['downlines'] != null
          ? (json['downlines'] as List)
              .map((e) => MlmReferralModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrerId': referrerId,
      'referredId': referredId,
      'referred': referred.toJson(),
      'referrer': referrer?.toJson(),
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'earnings': earnings,
      'teamSize': teamSize,
      'performance': performance,
      'level': level,
      'downlines': downlines?.map((e) => e.toJson()).toList(),
    };
  }
}

extension MlmReferralModelX on MlmReferralModel {
  MlmReferralEntity toEntity() {
    return MlmReferralEntity(
      id: id,
      referrerId: referrerId,
      referredId: referredId,
      referred: referred.toEntity(),
      referrer: referrer?.toEntity(),
      status: _convertStringToReferralStatus(status),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      earnings: earnings,
      teamSize: teamSize,
      performance: performance,
      level: level,
      downlines: downlines?.map((e) => e.toEntity()).toList(),
    );
  }

  MlmReferralStatus _convertStringToReferralStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return MlmReferralStatus.active;
      case 'REJECTED':
        return MlmReferralStatus.rejected;
      default:
        return MlmReferralStatus.pending;
    }
  }
}

extension MlmReferralEntityX on MlmReferralEntity {
  MlmReferralModel toModel() {
    return MlmReferralModel(
      id: id,
      referrerId: referrerId,
      referredId: referredId,
      referred: referred.toModel(),
      referrer: referrer?.toModel(),
      status: status.name.toUpperCase(),
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
      earnings: earnings,
      teamSize: teamSize,
      performance: performance,
      level: level,
      downlines: downlines?.map((e) => e.toModel()).toList(),
    );
  }
}
