import 'package:equatable/equatable.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_entity.dart';

class MlmReferralEntity extends Equatable {
  const MlmReferralEntity({
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
  final MlmUserEntity referred;
  final MlmUserEntity? referrer;
  final MlmReferralStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? earnings;
  final int? teamSize;
  final double? performance;
  final int? level;
  final List<MlmReferralEntity>? downlines;

  @override
  List<Object?> get props => [
        id,
        referrerId,
        referredId,
        referred,
        referrer,
        status,
        createdAt,
        updatedAt,
        earnings,
        teamSize,
        performance,
        level,
        downlines,
      ];

  MlmReferralEntity copyWith({
    String? id,
    String? referrerId,
    String? referredId,
    MlmUserEntity? referred,
    MlmUserEntity? referrer,
    MlmReferralStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? earnings,
    int? teamSize,
    double? performance,
    int? level,
    List<MlmReferralEntity>? downlines,
  }) {
    return MlmReferralEntity(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referredId: referredId ?? this.referredId,
      referred: referred ?? this.referred,
      referrer: referrer ?? this.referrer,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      earnings: earnings ?? this.earnings,
      teamSize: teamSize ?? this.teamSize,
      performance: performance ?? this.performance,
      level: level ?? this.level,
      downlines: downlines ?? this.downlines,
    );
  }
}
