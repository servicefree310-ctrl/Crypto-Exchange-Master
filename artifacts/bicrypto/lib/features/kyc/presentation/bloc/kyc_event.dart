import 'package:equatable/equatable.dart';

abstract class KycEvent extends Equatable {
  const KycEvent();

  @override
  List<Object?> get props => [];
}

// KYC Levels Events
class KycLevelsLoadRequested extends KycEvent {
  const KycLevelsLoadRequested();
}

class KycLevelByIdLoadRequested extends KycEvent {
  final String levelId;

  const KycLevelByIdLoadRequested({required this.levelId});

  @override
  List<Object?> get props => [levelId];
}

// KYC Applications Events
class KycApplicationsLoadRequested extends KycEvent {
  const KycApplicationsLoadRequested();
}

class KycApplicationByIdLoadRequested extends KycEvent {
  final String applicationId;

  const KycApplicationByIdLoadRequested({required this.applicationId});

  @override
  List<Object?> get props => [applicationId];
}

class KycApplicationSubmitted extends KycEvent {
  final String levelId;
  final Map<String, dynamic> fields;

  const KycApplicationSubmitted({
    required this.levelId,
    required this.fields,
  });

  @override
  List<Object?> get props => [levelId, fields];
}

class KycApplicationUpdated extends KycEvent {
  final String applicationId;
  final Map<String, dynamic> fields;

  const KycApplicationUpdated({
    required this.applicationId,
    required this.fields,
  });

  @override
  List<Object?> get props => [applicationId, fields];
}

// KYC Document Events
class KycDocumentUploaded extends KycEvent {
  final String filePath;
  final String fieldId;

  const KycDocumentUploaded({
    required this.filePath,
    required this.fieldId,
  });

  @override
  List<Object?> get props => [filePath, fieldId];
}

// Reset Events
class KycStateReset extends KycEvent {
  const KycStateReset();
}

class KycErrorDismissed extends KycEvent {
  const KycErrorDismissed();
}
