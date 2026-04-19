import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';

class ProfileCacheManager {
  static const String _cacheKey = 'cached_profile_data';
  static const String _timestampKey = 'cached_profile_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 5);

  final FlutterSecureStorage _secureStorage;

  ProfileCacheManager(this._secureStorage);

  /// Check if cached data is still valid (within 5 minutes)
  Future<bool> isCacheValid() async {
    try {
      final timestampStr = await _secureStorage.read(key: _timestampKey);
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      dev.log('🔵 PROFILE_CACHE: Cache age: ${difference.inMinutes} minutes');
      return difference < _cacheDuration;
    } catch (e) {
      dev.log('🔴 PROFILE_CACHE: Error checking cache validity: $e');
      return false;
    }
  }

  /// Get cached profile data if valid
  Future<ProfileEntity?> getCachedProfile() async {
    try {
      if (!await isCacheValid()) {
        dev.log('🔴 PROFILE_CACHE: Cache expired or invalid');
        return null;
      }

      final cachedData = await _secureStorage.read(key: _cacheKey);
      if (cachedData == null) {
        dev.log('🔴 PROFILE_CACHE: No cached data found');
        return null;
      }

      final jsonData = json.decode(cachedData);
      final profileModel = ProfileModel.fromJson(jsonData);
      
      dev.log('🟢 PROFILE_CACHE: Retrieved cached profile for user: ${profileModel.email}');
      return profileModel;
    } catch (e) {
      dev.log('🔴 PROFILE_CACHE: Error retrieving cached profile: $e');
      
      // If there's a deserialization error, clear the corrupted cache
      if (e.toString().contains('subtype') || e.toString().contains('type')) {
        dev.log('🔴 PROFILE_CACHE: Detected corrupted cache, clearing...');
        await clearCache();
      }
      
      return null;
    }
  }

  /// Cache profile data with current timestamp
  Future<void> cacheProfile(ProfileEntity profile) async {
    try {
      // Convert ProfileEntity to ProfileModel for serialization
      ProfileModel profileModel;
      if (profile is ProfileModel) {
        profileModel = profile;
      } else {
        // Convert entity to model
        profileModel = ProfileModel(
          id: profile.id,
          email: profile.email,
          firstName: profile.firstName,
          lastName: profile.lastName,
          phone: profile.phone,
          avatar: profile.avatar,
          emailVerified: profile.emailVerified,
          status: profile.status,
          role: profile.role,
          emailVerifiedAt: profile.emailVerifiedAt,
          createdAt: profile.createdAt,
          updatedAt: profile.updatedAt,
          roleId: 1, // Default roleId since we don't have it in the entity
          profileInfo: profile.profile != null ? ProfileInfoModel(
            bio: profile.profile!.bio,
            locationInfo: profile.profile!.location != null ? LocationModel(
              address: profile.profile!.location!.address,
              city: profile.profile!.location!.city,
              country: profile.profile!.location!.country,
              zip: profile.profile!.location!.zip,
            ) : null,
            socialLinks: profile.profile!.social != null ? SocialLinksModel(
              twitter: profile.profile!.social!.twitter,
              dribbble: profile.profile!.social!.dribbble,
              instagram: profile.profile!.social!.instagram,
              github: profile.profile!.social!.github,
              gitlab: profile.profile!.social!.gitlab,
              telegram: profile.profile!.social!.telegram,
            ) : null,
          ) : null,
          notificationSettings: profile.settings != null ? NotificationSettingsModel(
            email: profile.settings!.email,
            sms: profile.settings!.sms,
            push: profile.settings!.push,
          ) : null,
          twoFactorAuth: profile.twoFactor != null ? TwoFactorModel(
            type: profile.twoFactor!.type,
            enabled: profile.twoFactor!.enabled,
          ) : null,
        );
      }

      final jsonData = profileModel.toJson();
      final jsonString = json.encode(jsonData);
      final timestamp = DateTime.now().toIso8601String();

      await Future.wait([
        _secureStorage.write(key: _cacheKey, value: jsonString),
        _secureStorage.write(key: _timestampKey, value: timestamp),
      ]);

      dev.log('🟢 PROFILE_CACHE: Cached profile for user: ${profile.email}');
    } catch (e) {
      dev.log('🔴 PROFILE_CACHE: Error caching profile: $e');
    }
  }

  /// Clear cached profile data
  Future<void> clearCache() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _cacheKey),
        _secureStorage.delete(key: _timestampKey),
      ]);
      dev.log('🟢 PROFILE_CACHE: Cache cleared');
    } catch (e) {
      dev.log('🔴 PROFILE_CACHE: Error clearing cache: $e');
    }
  }

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final timestampStr = await _secureStorage.read(key: _timestampKey);
      if (timestampStr == null) return null;
      return DateTime.parse(timestampStr);
    } catch (e) {
      dev.log('🔴 PROFILE_CACHE: Error getting cache timestamp: $e');
      return null;
    }
  }

  /// Check if we have any cached data (regardless of validity)
  Future<bool> hasCachedData() async {
    try {
      final cachedData = await _secureStorage.read(key: _cacheKey);
      return cachedData != null;
    } catch (e) {
      dev.log('🔴 PROFILE_CACHE: Error checking cached data: $e');
      return false;
    }
  }
} 