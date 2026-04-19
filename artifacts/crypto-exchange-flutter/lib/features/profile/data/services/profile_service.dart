import 'dart:async';
import 'dart:developer' as dev;

import '../../domain/entities/profile_entity.dart';
import '../../presentation/bloc/profile_bloc.dart';
import '../../../addons/blog/data/services/blog_author_service.dart';
import '../../../auth/domain/entities/author_entity.dart';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();

  ProfileService._();

  ProfileBloc? _profileBloc;
  BlogAuthorService? _blogAuthorService;
  final StreamController<ProfileEntity?> _profileController =
      StreamController<ProfileEntity?>.broadcast();

  /// Stream of profile changes
  Stream<ProfileEntity?> get profileStream => _profileController.stream;

  /// Current profile data
  ProfileEntity? _currentProfile;
  ProfileEntity? get currentProfile => _currentProfile;

  /// Initialize the service with ProfileBloc and BlogAuthorService
  void initialize(ProfileBloc profileBloc,
      [BlogAuthorService? blogAuthorService]) {
    dev.log('🔵 PROFILE_SERVICE: Initializing ProfileService');
    _profileBloc = profileBloc;
    _blogAuthorService = blogAuthorService;

    // Listen to profile bloc state changes
    _profileBloc!.stream.listen((state) {
      if (state is ProfileLoaded) {
        _currentProfile = state.profile;
        _profileController.add(state.profile);
        dev.log('🟢 PROFILE_SERVICE: Profile updated - ${state.profile.email}');
      } else if (state is ProfileError && state.cachedProfile != null) {
        _currentProfile = state.cachedProfile;
        _profileController.add(state.cachedProfile);
        dev.log(
            '🟡 PROFILE_SERVICE: Using cached profile - ${state.cachedProfile!.email}');
      }
    });
  }

  /// Auto-fetch profile after login
  void autoFetchProfile() {
    dev.log('🔵 PROFILE_SERVICE: Auto-fetching profile after login');
    dev.log(
        '🔵 PROFILE_SERVICE: ProfileBloc is ${_profileBloc != null ? 'available' : 'NULL'}');

    if (_profileBloc != null) {
      dev.log('🔵 PROFILE_SERVICE: Adding ProfileAutoFetchRequested event');
      _profileBloc!.add(const ProfileAutoFetchRequested());

      // Also fetch author status
      _fetchAndUpdateAuthorStatus();
    } else {
      dev.log(
          '🔴 PROFILE_SERVICE: ProfileBloc is null, cannot auto-fetch profile');
    }
  }

  /// Fetch author status and update current profile
  Future<void> _fetchAndUpdateAuthorStatus() async {
    if (_blogAuthorService == null) {
      dev.log('🔴 PROFILE_SERVICE: BlogAuthorService not available');
      return;
    }

    try {
      dev.log('🔵 PROFILE_SERVICE: Fetching author status');
      final authorEntity = await _blogAuthorService!.getCurrentUserAuthor();

      if (authorEntity != null && _currentProfile != null) {
        dev.log('🟢 PROFILE_SERVICE: Author status found, updating profile');

        // Create updated profile with author data
        final updatedProfile = ProfileEntity(
          id: _currentProfile!.id,
          email: _currentProfile!.email,
          firstName: _currentProfile!.firstName,
          lastName: _currentProfile!.lastName,
          phone: _currentProfile!.phone,
          avatar: _currentProfile!.avatar,
          emailVerified: _currentProfile!.emailVerified,
          status: _currentProfile!.status,
          role: _currentProfile!.role,
          emailVerifiedAt: _currentProfile!.emailVerifiedAt,
          createdAt: _currentProfile!.createdAt,
          updatedAt: _currentProfile!.updatedAt,
          profile: _currentProfile!.profile,
          settings: _currentProfile!.settings,
          twoFactor: _currentProfile!.twoFactor,
          kycLevel: _currentProfile!.kycLevel,
          author: authorEntity,
        );

        _currentProfile = updatedProfile;
        _profileController.add(updatedProfile);
        dev.log(
            '🟢 PROFILE_SERVICE: Profile updated with author status: ${authorEntity.status}');
      } else {
        dev.log('🔵 PROFILE_SERVICE: No author status found for user');
      }
    } catch (e) {
      dev.log('🔴 PROFILE_SERVICE: Error fetching author status: $e');
    }
  }

  /// Refresh profile data
  void refreshProfile() {
    dev.log('🔵 PROFILE_SERVICE: Refreshing profile');
    _profileBloc?.add(const ProfileRefreshRequested());
  }

  /// Load profile with optional force refresh
  void loadProfile({bool forceRefresh = false}) {
    dev.log('🔵 PROFILE_SERVICE: Loading profile (forceRefresh: $forceRefresh)');
    _profileBloc?.add(ProfileLoadRequested(forceRefresh: forceRefresh));
  }

  /// Clear profile cache
  void clearCache() {
    dev.log('🔵 PROFILE_SERVICE: Clearing profile cache');
    _profileBloc?.add(const ProfileClearCacheRequested());
    _currentProfile = null;
    _profileController.add(null);
  }

  /// Reset service state completely (used during logout)
  void reset() {
    dev.log('🔵 PROFILE_SERVICE: Resetting ProfileService state');
    _currentProfile = null;
    _profileController.add(null);

    // Reset the ProfileBloc to initial state if available
    if (_profileBloc != null) {
      // Use the new reset event to properly reset the bloc state
      _profileBloc!.add(const ProfileResetRequested());

      // Note: We don't dispose the bloc here as it's managed by the DI container
      // The bloc will be recreated when needed
      dev.log('🟢 PROFILE_SERVICE: ProfileBloc reset event sent');
    }

    dev.log('🟢 PROFILE_SERVICE: Service reset completed');
  }

  /// Check if profile data is available
  Future<bool> hasProfileData() async {
    if (_currentProfile != null) return true;
    return await _profileBloc?.hasProfileData ?? false;
  }

  /// Get profile data (from state or cache)
  Future<ProfileEntity?> getProfileData() async {
    if (_currentProfile != null) return _currentProfile;
    return await _profileBloc?.getProfileData();
  }

  /// Get user's full name
  String get userFullName {
    if (_currentProfile != null) {
      return '${_currentProfile!.firstName} ${_currentProfile!.lastName}';
    }
    return 'User';
  }

  /// Get user's email
  String get userEmail {
    return _currentProfile?.email ?? '';
  }

  /// Get user's avatar URL
  String? get userAvatar {
    return _currentProfile?.avatar;
  }

  /// Check if user's email is verified
  bool get isEmailVerified {
    return _currentProfile?.emailVerified ?? false;
  }

  /// Check if user's phone is verified
  bool get isPhoneVerified {
    return _currentProfile?.phone != null;
  }

  /// Check if 2FA is enabled
  bool get isTwoFactorEnabled {
    return _currentProfile?.twoFactor?.enabled ?? false;
  }

  /// Calculate security score based on user's security features
  int get securityScore {
    if (_currentProfile == null) return 0;

    int score = 0;

    // Base score for having an account
    score += 30;

    // 2FA enabled
    if (isTwoFactorEnabled) score += 30;

    // Email verified
    if (isEmailVerified) score += 20;

    // Phone verified
    if (isPhoneVerified) score += 20;

    return score;
  }

  /// Get security score color based on score
  String getSecurityScoreColor() {
    if (securityScore >= 80) return 'green';
    if (securityScore >= 50) return 'amber';
    return 'red';
  }

  /// Get security score text description
  String getSecurityScoreText() {
    if (securityScore >= 80) return 'Excellent';
    if (securityScore >= 50) return 'Good';
    if (securityScore >= 30) return 'Fair';
    return 'Poor';
  }

  /// Get security score progress color
  String getSecurityScoreProgressColor() {
    if (securityScore >= 80) return '#10b981'; // green
    if (securityScore >= 50) return '#f59e0b'; // amber
    return '#ef4444'; // red
  }

  /// Get user's role
  String get userRole {
    return _currentProfile?.role ?? 'User';
  }

  /// Check if user is an author (has author record)
  bool get isAuthor {
    return _currentProfile?.author != null;
  }

  /// Check if user is an approved author
  bool get isApprovedAuthor {
    return _currentProfile?.author?.status == AuthorStatus.approved;
  }

  /// Check if user has pending author application
  bool get hasPendingAuthorApplication {
    return _currentProfile?.author?.status == AuthorStatus.pending;
  }

  /// Get user's author status
  AuthorStatus? get authorStatus {
    return _currentProfile?.author?.status;
  }

  /// Get user's status
  String get userStatus {
    return _currentProfile?.status ?? 'UNKNOWN';
  }

  /// Check if user is active
  bool get isUserActive {
    return userStatus == 'ACTIVE';
  }

  /// Get user's KYC level (null if not verified)
  int? get userKycLevel {
    return _currentProfile?.kycLevel;
  }

  /// Check if user is KYC verified
  bool get isKycVerified {
    return (userKycLevel ?? 0) > 0;
  }

  /// Dispose resources
  void dispose() {
    dev.log('🔵 PROFILE_SERVICE: Disposing ProfileService');
    _profileController.close();
    _currentProfile = null;
    _profileBloc = null;
  }
}
