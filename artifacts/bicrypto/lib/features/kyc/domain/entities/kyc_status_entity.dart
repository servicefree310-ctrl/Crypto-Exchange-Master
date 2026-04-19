import 'package:equatable/equatable.dart';

import 'kyc_application_entity.dart';

class KycStatusEntity extends Equatable {
  final bool isKycRequired;
  final bool isKycCompleted;
  final String? currentLevel;
  final int? levelNumber;
  final List<String>? availableFeatures;
  final KycApplicationEntity? activeApplication;

  const KycStatusEntity({
    required this.isKycRequired,
    required this.isKycCompleted,
    this.currentLevel,
    this.levelNumber,
    this.availableFeatures,
    this.activeApplication,
  });

  @override
  List<Object?> get props => [
        isKycRequired,
        isKycCompleted,
        currentLevel,
        levelNumber,
        availableFeatures,
        activeApplication,
      ];
}
