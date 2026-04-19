import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/toggle_two_factor_usecase.dart';
import '../../data/datasources/profile_cache_manager.dart';
import '../../data/services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ToggleTwoFactorUseCase toggleTwoFactorUseCase;
  final ProfileCacheManager _cacheManager;
  final ProfileService? _profileService;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.toggleTwoFactorUseCase,
    required ProfileCacheManager cacheManager,
    ProfileService? profileService,
  })  : _cacheManager = cacheManager,
        _profileService = profileService,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileTwoFactorToggleRequested>(_onProfileTwoFactorToggleRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileClearCacheRequested>(_onProfileClearCacheRequested);
    on<ProfileAutoFetchRequested>(_onProfileAutoFetchRequested);
    on<ProfileResetRequested>(_onProfileResetRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log(
        '🔵 PROFILE_BLOC: ProfileLoadRequested event received (forceRefresh: ${event.forceRefresh})');

    // If not forcing refresh, try to get cached data first
    if (!event.forceRefresh) {
      final cachedProfile = await _cacheManager.getCachedProfile();
      if (cachedProfile != null) {
        final cacheTimestamp = await _cacheManager.getCacheTimestamp();
        dev.log('🟢 PROFILE_BLOC: Using cached profile data');
        emit(ProfileLoaded(
          cachedProfile,
          isFromCache: true,
          cacheTimestamp: cacheTimestamp,
        ));
        return;
      }
    }

    emit(ProfileLoading());
    await _fetchProfileFromApi(emit);
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log('🔵 PROFILE_BLOC: ProfileRefreshRequested event received');

    // Get current profile if available
    ProfileEntity? currentProfile;
    if (state is ProfileLoaded) {
      currentProfile = (state as ProfileLoaded).profile;
    }

    emit(ProfileRefreshing(currentProfile: currentProfile));
    await _fetchProfileFromApi(emit);
  }

  Future<void> _onProfileAutoFetchRequested(
    ProfileAutoFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log('🔵 PROFILE_BLOC: ProfileAutoFetchRequested event received');

    // Check if we have valid cached data
    final cachedProfile = await _cacheManager.getCachedProfile();
    if (cachedProfile != null) {
      final cacheTimestamp = await _cacheManager.getCacheTimestamp();
      dev.log('🟢 PROFILE_BLOC: Auto-fetch using cached profile data');
      emit(ProfileLoaded(
        cachedProfile,
        isFromCache: true,
        cacheTimestamp: cacheTimestamp,
      ));
      return;
    }

    // No valid cache, fetch from API
    dev.log('🔵 PROFILE_BLOC: Auto-fetch from API (no valid cache)');
    emit(ProfileLoading());
    await _fetchProfileFromApi(emit);
  }

  Future<void> _onProfileClearCacheRequested(
    ProfileClearCacheRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log('🔵 PROFILE_BLOC: ProfileClearCacheRequested event received');
    await _cacheManager.clearCache();
    emit(ProfileCacheCleared());
  }

  Future<void> _onProfileResetRequested(
    ProfileResetRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log(
        '🔵 PROFILE_BLOC: ProfileResetRequested event received - resetting to initial state');
    await _cacheManager.clearCache();
    emit(ProfileInitial());
    dev.log('🟢 PROFILE_BLOC: Profile reset completed');
  }

  Future<void> _fetchProfileFromApi(Emitter<ProfileState> emit) async {
    dev.log('🔵 PROFILE_BLOC: Fetching profile from API');

    emit(ProfileLoading());

    final result = await getProfileUseCase(NoParams());

    await result.fold(
      (failure) async {
        dev.log('🔴 PROFILE_BLOC: Failed to load profile: ${failure.message}');
        emit(ProfileError(failure.message));
      },
      (profile) async {
        dev.log('🟢 PROFILE_BLOC: Profile loaded successfully from API');

        // Cache the profile and wait for completion
        await _cacheManager.cacheProfile(profile);

        // ProfileService will automatically update via stream listener

        // Emit success state
        emit(ProfileLoaded(
          profile,
          isFromCache: false,
          cacheTimestamp: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log('🔵 PROFILE_BLOC: ProfileUpdateRequested event received');
    emit(ProfileUpdating());

    final result = await updateProfileUseCase(event.params);

    result.fold(
      (failure) {
        dev.log(
            '🔴 PROFILE_BLOC: Failed to update profile: ${failure.toString()}');
        emit(ProfileError(failure.toString()));
      },
      (_) async {
        dev.log('🟢 PROFILE_BLOC: Profile updated successfully');
        emit(ProfileUpdateSuccess());

        // Clear cache and reload profile after successful update
        await _cacheManager.clearCache();
        add(ProfileLoadRequested(forceRefresh: true));
      },
    );
  }

  Future<void> _onProfileTwoFactorToggleRequested(
    ProfileTwoFactorToggleRequested event,
    Emitter<ProfileState> emit,
  ) async {
    dev.log('🔵 PROFILE_BLOC: ProfileTwoFactorToggleRequested event received');
    emit(ProfileUpdating());

    final result = await toggleTwoFactorUseCase(
      ToggleTwoFactorParams(enabled: event.enabled),
    );

    result.fold(
      (failure) {
        dev.log('🔴 PROFILE_BLOC: Failed to toggle 2FA: ${failure.toString()}');
        emit(ProfileError(failure.toString()));
      },
      (_) async {
        dev.log('🟢 PROFILE_BLOC: 2FA toggled successfully');
        emit(ProfileUpdateSuccess());

        // Clear cache and reload profile after successful update
        await _cacheManager.clearCache();
        add(ProfileLoadRequested(forceRefresh: true));
      },
    );
  }

  /// Get current profile from state or cache
  ProfileEntity? get currentProfile {
    if (state is ProfileLoaded) {
      return (state as ProfileLoaded).profile;
    }
    return null;
  }

  /// Check if profile data is available (from state or cache)
  Future<bool> get hasProfileData async {
    if (currentProfile != null) return true;
    return await _cacheManager.hasCachedData();
  }

  /// Get profile data (from state or cache)
  Future<ProfileEntity?> getProfileData() async {
    if (currentProfile != null) return currentProfile;
    return await _cacheManager.getCachedProfile();
  }
}
