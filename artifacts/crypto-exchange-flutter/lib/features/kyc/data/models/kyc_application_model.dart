import '../../domain/entities/kyc_application_entity.dart';
import 'kyc_level_model.dart';

class KycApplicationModel extends KycApplicationEntity {
  const KycApplicationModel({
    required super.id,
    required super.userId,
    required super.levelId,
    required super.status,
    required super.data,
    super.adminNotes,
    super.reviewedAt,
    super.createdAt,
    super.updatedAt,
    super.level,
    super.verificationResult,
  });

  factory KycApplicationModel.fromJson(Map<String, dynamic> json) {
    return KycApplicationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      levelId: json['levelId'] as String,
      status:
          KycApplicationStatusExtension.fromString(json['status'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      adminNotes: json['adminNotes'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      level: json['level'] != null
          ? KycLevelModel.fromJson(json['level'] as Map<String, dynamic>)
          : null,
      verificationResult: json['verificationResult'] != null
          ? KycVerificationResultModel.fromJson(
              json['verificationResult'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'levelId': levelId,
      'status': status.value,
      'data': data,
      'adminNotes': adminNotes,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'level': (level as KycLevelModel?)?.toJson(),
      'verificationResult':
          (verificationResult as KycVerificationResultModel?)?.toJson(),
    };
  }
}

class KycVerificationResultModel extends KycVerificationResultEntity {
  const KycVerificationResultModel({
    required super.id,
    required super.applicationId,
    super.serviceId,
    required super.status,
    super.result,
    super.createdAt,
    super.updatedAt,
  });

  factory KycVerificationResultModel.fromJson(Map<String, dynamic> json) {
    return KycVerificationResultModel(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      serviceId: json['serviceId'] as String?,
      status: json['status'] as String,
      result: json['result'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'serviceId': serviceId,
      'status': status,
      'result': result,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
