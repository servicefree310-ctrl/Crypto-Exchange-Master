import '../../domain/entities/ico_offering_entity.dart';

class IcoPhaseModel {
  const IcoPhaseModel({
    required this.id,
    required this.offeringId,
    required this.name,
    required this.tokenPrice,
    required this.allocation,
    required this.remaining,
    required this.duration,
  });

  final String id;
  final String offeringId;
  final String name;
  final double tokenPrice;
  final double allocation;
  final double remaining;
  final int duration;

  factory IcoPhaseModel.fromJson(Map<String, dynamic> json) {
    return IcoPhaseModel(
      id: json['id'] as String,
      offeringId: json['offeringId'] as String,
      name: json['name'] as String,
      tokenPrice: (json['tokenPrice'] as num).toDouble(),
      allocation: (json['allocation'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeringId': offeringId,
      'name': name,
      'tokenPrice': tokenPrice,
      'allocation': allocation,
      'remaining': remaining,
      'duration': duration,
    };
  }

  IcoPhaseEntity toEntity() {
    return IcoPhaseEntity(
      id: id,
      name: name,
      tokenPrice: tokenPrice,
      allocation: allocation,
      remaining: remaining,
      duration: duration,
    );
  }
}
