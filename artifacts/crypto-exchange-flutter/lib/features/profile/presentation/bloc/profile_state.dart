part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final bool isFromCache;
  final DateTime? cacheTimestamp;

  const ProfileLoaded(
    this.profile, {
    this.isFromCache = false,
    this.cacheTimestamp,
  });

  @override
  List<Object?> get props => [profile, isFromCache, cacheTimestamp];
}

class ProfileRefreshing extends ProfileState {
  final ProfileEntity? currentProfile;

  const ProfileRefreshing({this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}

class ProfileError extends ProfileState {
  final String message;
  final ProfileEntity? cachedProfile;

  const ProfileError(this.message, {this.cachedProfile});

  @override
  List<Object?> get props => [message, cachedProfile];
}

class ProfileCacheCleared extends ProfileState {
  const ProfileCacheCleared();
}
