part of 'notification_settings_cubit.dart';

enum NotificationSettingsStatus { initial, ready, saving, success, error }

class NotificationSettingsState extends Equatable {
  final bool email;
  final bool sms;
  final bool push;
  final NotificationSettingsStatus status;
  final String? errorMessage;

  const NotificationSettingsState({
    required this.email,
    required this.sms,
    required this.push,
    required this.status,
    this.errorMessage,
  });

  const NotificationSettingsState.initial()
      : this(
          email: true,
          sms: false,
          push: true,
          status: NotificationSettingsStatus.initial,
        );

  NotificationSettingsState copyWith({
    bool? email,
    bool? sms,
    bool? push,
    NotificationSettingsStatus? status,
    String? errorMessage,
  }) {
    return NotificationSettingsState(
      email: email ?? this.email,
      sms: sms ?? this.sms,
      push: push ?? this.push,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, sms, push, status, errorMessage];
}
