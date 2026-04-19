part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final bool forceRefresh;

  const ProfileLoadRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class ProfileUpdateRequested extends ProfileEvent {
  final UpdateProfileParams params;

  const ProfileUpdateRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class ProfileTwoFactorToggleRequested extends ProfileEvent {
  final bool enabled;

  const ProfileTwoFactorToggleRequested(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileClearCacheRequested extends ProfileEvent {
  const ProfileClearCacheRequested();
}

class ProfileAutoFetchRequested extends ProfileEvent {
  const ProfileAutoFetchRequested();
}

class ProfileResetRequested extends ProfileEvent {
  const ProfileResetRequested();
}
