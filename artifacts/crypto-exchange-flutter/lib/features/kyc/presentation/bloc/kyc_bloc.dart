import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_kyc_levels_usecase.dart';
import '../../domain/usecases/get_kyc_level_by_id_usecase.dart';
import '../../domain/usecases/get_kyc_applications_usecase.dart';
import '../../domain/usecases/submit_kyc_application_usecase.dart';
import '../../domain/usecases/update_kyc_application_usecase.dart';
import '../../domain/usecases/upload_kyc_document_usecase.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

@injectable
class KycBloc extends Bloc<KycEvent, KycState> {
  final GetKycLevelsUseCase _getKycLevelsUseCase;
  final GetKycLevelByIdUseCase _getKycLevelByIdUseCase;
  final GetKycApplicationsUseCase _getKycApplicationsUseCase;
  final SubmitKycApplicationUseCase _submitKycApplicationUseCase;
  final UpdateKycApplicationUseCase _updateKycApplicationUseCase;
  final UploadKycDocumentUseCase _uploadKycDocumentUseCase;

  KycBloc(
    this._getKycLevelsUseCase,
    this._getKycLevelByIdUseCase,
    this._getKycApplicationsUseCase,
    this._submitKycApplicationUseCase,
    this._updateKycApplicationUseCase,
    this._uploadKycDocumentUseCase,
  ) : super(const KycInitial()) {
    on<KycLevelsLoadRequested>(_onKycLevelsLoadRequested);
    on<KycLevelByIdLoadRequested>(_onKycLevelByIdLoadRequested);
    on<KycApplicationsLoadRequested>(_onKycApplicationsLoadRequested);
    on<KycApplicationByIdLoadRequested>(_onKycApplicationByIdLoadRequested);
    on<KycApplicationSubmitted>(_onKycApplicationSubmitted);
    on<KycApplicationUpdated>(_onKycApplicationUpdated);
    on<KycDocumentUploaded>(_onKycDocumentUploaded);
    on<KycStateReset>(_onKycStateReset);
    on<KycErrorDismissed>(_onKycErrorDismissed);
  }

  Future<void> _onKycLevelsLoadRequested(
    KycLevelsLoadRequested event,
    Emitter<KycState> emit,
  ) async {
    dev.log('🔵 KYC_BLOC: Loading KYC levels');
    emit(const KycLoading(message: 'Loading KYC levels...'));

    final result = await _getKycLevelsUseCase(NoParams());

    result.fold(
      (failure) {
        dev.log('🔴 KYC_BLOC: Failed to load KYC levels: ${failure.message}');
        emit(KycError(failure: failure, message: failure.message));
      },
      (levels) {
        dev.log('🟢 KYC_BLOC: Successfully loaded ${levels.length} KYC levels');
        emit(KycLevelsLoaded(levels: levels));
      },
    );
  }

  Future<void> _onKycLevelByIdLoadRequested(
    KycLevelByIdLoadRequested event,
    Emitter<KycState> emit,
  ) async {
    dev.log('🔵 KYC_BLOC: Loading KYC level: ${event.levelId}');
    emit(const KycLoading(message: 'Loading KYC level details...'));

    final result = await _getKycLevelByIdUseCase(event.levelId);

    result.fold(
      (failure) {
        dev.log('🔴 KYC_BLOC: Failed to load KYC level: ${failure.message}');
        emit(KycError(failure: failure, message: failure.message));
      },
      (level) {
        dev.log('🟢 KYC_BLOC: Successfully loaded KYC level');
        emit(KycLevelLoaded(level: level));
      },
    );
  }

  Future<void> _onKycApplicationsLoadRequested(
    KycApplicationsLoadRequested event,
    Emitter<KycState> emit,
  ) async {
    dev.log('🔵 KYC_BLOC: Loading KYC applications');
    emit(const KycLoading(message: 'Loading your KYC applications...'));

    final result = await _getKycApplicationsUseCase(NoParams());

    result.fold(
      (failure) {
        dev.log(
            '🔴 KYC_BLOC: Failed to load KYC applications: ${failure.message}');
        emit(KycError(failure: failure, message: failure.message));
      },
      (applications) {
        dev.log(
            '🟢 KYC_BLOC: Successfully loaded ${applications.length} KYC applications');
        emit(KycApplicationsLoaded(applications: applications));
      },
    );
  }

  Future<void> _onKycApplicationByIdLoadRequested(
    KycApplicationByIdLoadRequested event,
    Emitter<KycState> emit,
  ) async {
    dev.log('🔵 KYC_BLOC: Loading KYC application: ${event.applicationId}');
    emit(const KycLoading(message: 'Loading application details...'));

    final result = await _getKycApplicationsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(KycError(failure: failure, message: failure.message));
      },
      (applications) {
        final app = applications.where((a) => a.id == event.applicationId);
        if (app.isNotEmpty) {
          emit(KycApplicationLoaded(application: app.first));
        } else {
          emit(const KycError(
            failure: NotFoundFailure('Application not found'),
            message: 'Application not found',
          ));
        }
      },
    );
  }

  Future<void> _onKycApplicationSubmitted(
    KycApplicationSubmitted event,
    Emitter<KycState> emit,
  ) async {
    dev.log(
        '🔵 KYC_BLOC: Submitting KYC application for level: ${event.levelId}');
    emit(const KycLoading(message: 'Submitting your KYC application...'));

    final params = SubmitKycApplicationParams(
      levelId: event.levelId,
      fields: event.fields,
    );

    final result = await _submitKycApplicationUseCase(params);

    result.fold(
      (failure) {
        dev.log(
            '🔴 KYC_BLOC: Failed to submit KYC application: ${failure.message}');
        emit(KycError(failure: failure, message: failure.message));
      },
      (application) {
        dev.log('🟢 KYC_BLOC: Successfully submitted KYC application');
        emit(KycApplicationSubmitSuccess(
          application: application,
          message: 'Your KYC application has been submitted for review',
        ));
      },
    );
  }

  Future<void> _onKycApplicationUpdated(
    KycApplicationUpdated event,
    Emitter<KycState> emit,
  ) async {
    dev.log('🔵 KYC_BLOC: Updating KYC application: ${event.applicationId}');
    emit(const KycLoading(message: 'Updating your KYC application...'));

    final params = UpdateKycApplicationParams(
      applicationId: event.applicationId,
      fields: event.fields,
    );

    final result = await _updateKycApplicationUseCase(params);

    result.fold(
      (failure) {
        dev.log(
            '🔴 KYC_BLOC: Failed to update KYC application: ${failure.message}');
        emit(KycError(failure: failure, message: failure.message));
      },
      (application) {
        dev.log('🟢 KYC_BLOC: Successfully updated KYC application');
        emit(KycApplicationUpdateSuccess(
          application: application,
          message: 'Your KYC application has been updated',
        ));
      },
    );
  }

  Future<void> _onKycDocumentUploaded(
    KycDocumentUploaded event,
    Emitter<KycState> emit,
  ) async {
    dev.log('🔵 KYC_BLOC: Uploading document for field: ${event.fieldId}');
    emit(KycDocumentUploading(fieldId: event.fieldId));

    final params = UploadKycDocumentParams(filePath: event.filePath);

    final result = await _uploadKycDocumentUseCase(params);

    result.fold(
      (failure) {
        dev.log('🔴 KYC_BLOC: Failed to upload document: ${failure.message}');
        emit(KycDocumentUploadError(
          fieldId: event.fieldId,
          failure: failure,
          message: failure.message,
        ));
      },
      (fileUrl) {
        dev.log('🟢 KYC_BLOC: Successfully uploaded document: $fileUrl');
        emit(KycDocumentUploadedState(
          fileUrl: fileUrl,
          fieldId: event.fieldId,
        ));
      },
    );
  }

  void _onKycStateReset(
    KycStateReset event,
    Emitter<KycState> emit,
  ) {
    dev.log('🔵 KYC_BLOC: Resetting state');
    emit(const KycInitial());
  }

  void _onKycErrorDismissed(
    KycErrorDismissed event,
    Emitter<KycState> emit,
  ) {
    dev.log('🔵 KYC_BLOC: Error dismissed, resetting to initial state');
    emit(const KycInitial());
  }
}
