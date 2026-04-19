import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/update_notification_settings_usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../data/services/profile_service.dart';

part 'notification_settings_state.dart';

@injectable
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final UpdateNotificationSettingsUseCase _updateUseCase;
  final ProfileService _profileService;

  NotificationSettingsCubit(this._updateUseCase, this._profileService)
      : super(const NotificationSettingsState.initial());

  void initialize() {
    final settings = _profileService.currentProfile?.settings;
    emit(state.copyWith(
      email: settings?.email ?? false,
      sms: settings?.sms ?? false,
      push: settings?.push ?? false,
      status: NotificationSettingsStatus.ready,
    ));
  }

  void toggleEmail(bool value) {
    emit(state.copyWith(email: value));
  }

  void toggleSms(bool value) {
    emit(state.copyWith(sms: value));
  }

  void togglePush(bool value) {
    emit(state.copyWith(push: value));
  }

  Future<void> save() async {
    emit(state.copyWith(status: NotificationSettingsStatus.saving));
    final params = NotificationSettingsEntity(
      email: state.email,
      sms: state.sms,
      push: state.push,
    );
    final result = await _updateUseCase(params);
    result.fold(
      (failure) => emit(state.copyWith(
          status: NotificationSettingsStatus.error,
          errorMessage: failure.message)),
      (_) {
        // Refresh cached profile so toggles persist next time
        _profileService.refreshProfile();
        emit(state.copyWith(status: NotificationSettingsStatus.success));
      },
    );
  }
}
