import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUserData();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    required String csrfToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getSessionId();
  Future<String?> getCsrfToken();
  Future<void> clearTokens();
  Future<bool> hasValidTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  // On Flutter web, flutter_secure_storage uses Web Crypto API which throws
  // intermittent OperationError, breaking login persistence. Fall back to
  // SharedPreferences (less secure but reliable) for tokens on web only.
  Future<void> _writeToken(String key, String value) async {
    if (kIsWeb) {
      await sharedPreferences.setString('_tok_$key', value);
    } else {
      await secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _readToken(String key) async {
    if (kIsWeb) {
      return sharedPreferences.getString('_tok_$key');
    }
    return secureStorage.read(key: key);
  }

  Future<void> _deleteToken(String key) async {
    if (kIsWeb) {
      await sharedPreferences.remove('_tok_$key');
    } else {
      await secureStorage.delete(key: key);
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    dev.log('🔵 AUTH_LOCAL_DS: Getting cached user');
    
    try {
      final userJson = sharedPreferences.getString(AppConstants.userDataKey);
      dev.log('🔵 AUTH_LOCAL_DS: User JSON from storage: $userJson');
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        dev.log('🔵 AUTH_LOCAL_DS: Decoded user map: $userMap');
        final user = UserModel.fromJson(userMap);
        dev.log('🟢 AUTH_LOCAL_DS: Successfully retrieved cached user: ${user.email}');
        return user;
      }
      
      dev.log('🔵 AUTH_LOCAL_DS: No cached user found');
      return null;
    } catch (e) {
      dev.log('🔴 AUTH_LOCAL_DS: Error getting cached user: $e');
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    dev.log('🔵 AUTH_LOCAL_DS: Caching user: ${user.email}');
    
    try {
      final userJson = json.encode(user.toJson());
      dev.log('🔵 AUTH_LOCAL_DS: User JSON to cache: $userJson');
      
      await sharedPreferences.setString(AppConstants.userDataKey, userJson);
      dev.log('🟢 AUTH_LOCAL_DS: User cached successfully');
    } catch (e) {
      dev.log('🔴 AUTH_LOCAL_DS: Error caching user: $e');
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await sharedPreferences.remove(AppConstants.userDataKey);
    } catch (e) {
      throw CacheException('Failed to clear user data');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    required String csrfToken,
  }) async {
    dev.log('🔵 AUTH_LOCAL_DS: Saving tokens');
    dev.log('🔵 AUTH_LOCAL_DS: AccessToken length: ${accessToken.length}');
    dev.log('🔵 AUTH_LOCAL_DS: RefreshToken length: ${refreshToken.length}');
    dev.log('🔵 AUTH_LOCAL_DS: SessionId: $sessionId');
    dev.log('🔵 AUTH_LOCAL_DS: CsrfToken length: ${csrfToken.length}');
    
    try {
      await Future.wait([
        _writeToken(AppConstants.accessTokenKey, accessToken),
        _writeToken(AppConstants.refreshTokenKey, refreshToken),
        _writeToken(AppConstants.sessionIdKey, sessionId),
        _writeToken(AppConstants.csrfTokenKey, csrfToken),
      ]);
      dev.log('🟢 AUTH_LOCAL_DS: All tokens saved successfully');
    } catch (e) {
      dev.log('🔴 AUTH_LOCAL_DS: Error saving tokens: $e');
      throw CacheException('Failed to save tokens');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _readToken(AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException('Failed to get access token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _readToken(AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to get refresh token');
    }
  }

  @override
  Future<String?> getSessionId() async {
    try {
      return await _readToken(AppConstants.sessionIdKey);
    } catch (e) {
      throw CacheException('Failed to get session ID');
    }
  }

  @override
  Future<String?> getCsrfToken() async {
    try {
      return await _readToken(AppConstants.csrfTokenKey);
    } catch (e) {
      throw CacheException('Failed to get CSRF token');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _deleteToken(AppConstants.accessTokenKey),
        _deleteToken(AppConstants.refreshTokenKey),
        _deleteToken(AppConstants.sessionIdKey),
        _deleteToken(AppConstants.csrfTokenKey),
      ]);
    } catch (e) {
      throw CacheException('Failed to clear tokens');
    }
  }

  @override
  Future<bool> hasValidTokens() async {
    dev.log('🔵 AUTH_LOCAL_DS: Checking for valid tokens');
    
    try {
      final accessToken = await getAccessToken();
      final sessionId = await getSessionId();
      
      dev.log('🔵 AUTH_LOCAL_DS: AccessToken exists: ${accessToken != null}');
      dev.log('🔵 AUTH_LOCAL_DS: SessionId exists: ${sessionId != null}');
      
      final hasTokens = accessToken != null && sessionId != null;
      dev.log('🔵 AUTH_LOCAL_DS: Has valid tokens: $hasTokens');
      
      return hasTokens;
    } catch (e) {
      dev.log('🔴 AUTH_LOCAL_DS: Error checking tokens: $e');
      return false;
    }
  }
} 