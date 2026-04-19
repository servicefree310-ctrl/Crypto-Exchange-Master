import 'package:equatable/equatable.dart';

import '../../domain/entities/kyc_level_entity.dart';
import '../../domain/entities/kyc_application_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class KycState extends Equatable {
  const KycState();

  @override
  List<Object?> get props => [];
}

// Initial State
class KycInitial extends KycState {
  const KycInitial();
}

// Loading States
class KycLoading extends KycState {
  final String? message;

  const KycLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class KycDocumentUploading extends KycState {
  final String fieldId;
  final double progress;

  const KycDocumentUploading({
    required this.fieldId,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [fieldId, progress];
}

// Success States for KYC Levels
class KycLevelsLoaded extends KycState {
  final List<KycLevelEntity> levels;

  const KycLevelsLoaded({required this.levels});

  @override
  List<Object?> get props => [levels];
}

class KycLevelLoaded extends KycState {
  final KycLevelEntity level;

  const KycLevelLoaded({required this.level});

  @override
  List<Object?> get props => [level];
}

// Success States for KYC Applications
class KycApplicationsLoaded extends KycState {
  final List<KycApplicationEntity> applications;

  const KycApplicationsLoaded({required this.applications});

  @override
  List<Object?> get props => [applications];
}

class KycApplicationLoaded extends KycState {
  final KycApplicationEntity application;

  const KycApplicationLoaded({required this.application});

  @override
  List<Object?> get props => [application];
}

class KycApplicationSubmitSuccess extends KycState {
  final KycApplicationEntity application;
  final String message;

  const KycApplicationSubmitSuccess({
    required this.application,
    this.message = 'KYC application submitted successfully',
  });

  @override
  List<Object?> get props => [application, message];
}

class KycApplicationUpdateSuccess extends KycState {
  final KycApplicationEntity application;
  final String message;

  const KycApplicationUpdateSuccess({
    required this.application,
    this.message = 'KYC application updated successfully',
  });

  @override
  List<Object?> get props => [application, message];
}

// Success States for KYC Documents (renamed to avoid conflict with event)
class KycDocumentUploadedState extends KycState {
  final String fileUrl;
  final String fieldId;
  final String message;

  const KycDocumentUploadedState({
    required this.fileUrl,
    required this.fieldId,
    this.message = 'Document uploaded successfully',
  });

  @override
  List<Object?> get props => [fileUrl, fieldId, message];
}

// Error States
class KycError extends KycState {
  final Failure failure;
  final String message;

  const KycError({
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [failure, message];
}

class KycValidationError extends KycState {
  final Map<String, String> fieldErrors;
  final String message;

  const KycValidationError({
    required this.fieldErrors,
    required this.message,
  });

  @override
  List<Object?> get props => [fieldErrors, message];
}

class KycDocumentUploadError extends KycState {
  final String fieldId;
  final Failure failure;
  final String message;

  const KycDocumentUploadError({
    required this.fieldId,
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [fieldId, failure, message];
}
