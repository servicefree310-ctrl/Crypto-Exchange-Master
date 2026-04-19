import 'package:equatable/equatable.dart';
import 'kyc_level_entity.dart';

class KycApplicationEntity extends Equatable {
  final String id;
  final String userId;
  final String levelId;
  final KycApplicationStatus status;
  final Map<String, dynamic> data;
  final String? adminNotes;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final KycLevelEntity? level;
  final KycVerificationResultEntity? verificationResult;

  const KycApplicationEntity({
    required this.id,
    required this.userId,
    required this.levelId,
    required this.status,
    required this.data,
    this.adminNotes,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
    this.level,
    this.verificationResult,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        levelId,
        status,
        data,
        adminNotes,
        reviewedAt,
        createdAt,
        updatedAt,
        level,
        verificationResult,
      ];

  KycApplicationEntity copyWith({
    String? id,
    String? userId,
    String? levelId,
    KycApplicationStatus? status,
    Map<String, dynamic>? data,
    String? adminNotes,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    KycLevelEntity? level,
    KycVerificationResultEntity? verificationResult,
  }) {
    return KycApplicationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      levelId: levelId ?? this.levelId,
      status: status ?? this.status,
      data: data ?? this.data,
      adminNotes: adminNotes ?? this.adminNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      level: level ?? this.level,
      verificationResult: verificationResult ?? this.verificationResult,
    );
  }

  /// Get a field value from the application data
  T? getFieldValue<T>(String fieldId) {
    return data[fieldId] as T?;
  }

  /// Check if all required fields are completed
  bool get isCompleted {
    if (level?.fields == null) return false;

    for (final field in level!.fields!) {
      if (field.required == true) {
        final value = data[field.id];
        if (value == null || value.toString().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (level?.fields == null || level!.fields!.isEmpty) return 0.0;

    final totalFields = level!.fields!.length;
    final completedFields = level!.fields!.where((field) {
      final value = data[field.id];
      return value != null && value.toString().isNotEmpty;
    }).length;

    return completedFields / totalFields;
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case KycApplicationStatus.pending:
        return '#f59e0b'; // amber
      case KycApplicationStatus.approved:
        return '#10b981'; // green
      case KycApplicationStatus.rejected:
        return '#ef4444'; // red
      case KycApplicationStatus.additionalInfoRequired:
        return '#3b82f6'; // blue
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case KycApplicationStatus.pending:
        return 'Pending Review';
      case KycApplicationStatus.approved:
        return 'Approved';
      case KycApplicationStatus.rejected:
        return 'Rejected';
      case KycApplicationStatus.additionalInfoRequired:
        return 'Additional Information Required';
    }
  }

  /// Check if the application can be edited
  bool get canEdit {
    return status == KycApplicationStatus.pending ||
        status == KycApplicationStatus.additionalInfoRequired;
  }
}

enum KycApplicationStatus {
  pending,
  approved,
  rejected,
  additionalInfoRequired,
}

extension KycApplicationStatusExtension on KycApplicationStatus {
  String get value {
    switch (this) {
      case KycApplicationStatus.pending:
        return 'PENDING';
      case KycApplicationStatus.approved:
        return 'APPROVED';
      case KycApplicationStatus.rejected:
        return 'REJECTED';
      case KycApplicationStatus.additionalInfoRequired:
        return 'ADDITIONAL_INFO_REQUIRED';
    }
  }

  static KycApplicationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return KycApplicationStatus.pending;
      case 'APPROVED':
        return KycApplicationStatus.approved;
      case 'REJECTED':
        return KycApplicationStatus.rejected;
      case 'ADDITIONAL_INFO_REQUIRED':
        return KycApplicationStatus.additionalInfoRequired;
      default:
        return KycApplicationStatus.pending;
    }
  }
}

class KycVerificationResultEntity extends Equatable {
  final String id;
  final String applicationId;
  final String? serviceId;
  final String status;
  final Map<String, dynamic>? result;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KycVerificationResultEntity({
    required this.id,
    required this.applicationId,
    this.serviceId,
    required this.status,
    this.result,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        applicationId,
        serviceId,
        status,
        result,
        createdAt,
        updatedAt,
      ];
}
