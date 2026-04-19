import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/pow_captcha_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
    String? recaptchaToken,
  });
  Future<void> logout();
  Future<UserModel> verifyTwoFactor(
      {required String userId, required String code});
  Future<UserModel> verifyTwoFactorLogin(
      {required String userId, required String otp});
  Future<void> refreshToken();
  Future<void> requestPasswordReset({required String email});
  Future<void> resetPassword(
      {required String token, required String newPassword});
  Future<void> changePassword(
      {required String currentPassword, required String newPassword});
  Future<void> verifyEmail({required String token});
  Future<void> resendEmailVerification();
  Future<UserModel> googleSignIn({required String idToken});
  Future<UserModel> googleRegister({required String idToken, String? referralCode});
  Future<Map<String, dynamic>> enableTwoFactor({required String type});
  Future<void> disableTwoFactor({required String code});
  Future<void> resendTwoFactorCode({required String userId, required String type});
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  String? _tempAccessToken;
  String? _tempSessionId;
  String? _tempCsrfToken;

  AuthRemoteDataSourceImpl({required this.client});

  // Getters for tokens
  String? get lastAccessToken => _tempAccessToken;
  String? get lastSessionId => _tempSessionId;
  String? get lastCsrfToken => _tempCsrfToken;

  void clearTokens() {
    _tempAccessToken = null;
    _tempSessionId = null;
    _tempCsrfToken = null;
  }

  @override
  Future<UserModel> login(
      {required String email, required String password}) async {
    dev.log('🔵 AUTH_REMOTE_DS: Starting login for email: $email');

    try {
      dev.log('🔵 AUTH_REMOTE_DS: Making POST request to ${ApiConstants.login}');
      dev.log(
          '🔵 AUTH_REMOTE_DS: Request data: {email: $email, password: [HIDDEN]}');

      final response = await client.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      dev.log(
          '🔵 AUTH_REMOTE_DS: Response received - Status: ${response.statusCode}');
      dev.log('🔵 AUTH_REMOTE_DS: Response headers: ${response.headers}');
      dev.log('🔵 AUTH_REMOTE_DS: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        dev.log('🔵 AUTH_REMOTE_DS: Checking response structure...');
        dev.log('🔵 AUTH_REMOTE_DS: Has twoFactor: ${data['twoFactor'] != null}');
        dev.log('🔵 AUTH_REMOTE_DS: Has user: ${data['user'] != null}');
        dev.log('🔵 AUTH_REMOTE_DS: Has message: ${data['message'] != null}');
        dev.log('🔵 AUTH_REMOTE_DS: Has cookies: ${data['cookies'] != null}');

        // Check if 2FA is required (matches V5 backend response)
        if (data['twoFactor'] != null && data['twoFactor']['enabled'] == true) {
          final userId = data['id'];
          final twoFactorType = data['twoFactor']['type'] ?? 'EMAIL';
          dev.log(
              '🟡 AUTH_REMOTE_DS: 2FA verification required - userId: $userId, type: $twoFactorType');
          throw TwoFactorRequiredException(
            userId: userId,
            twoFactorType: twoFactorType,
          );
        }

        // Handle successful login with cookies/tokens format
        if (data['cookies'] != null && data['message'] != null) {
          dev.log('🔵 AUTH_REMOTE_DS: Login successful with cookies format');
          final cookies = data['cookies'];
          final accessToken = cookies['accessToken'];
          final sessionId = cookies['sessionId'];
          final csrfToken = cookies['csrfToken'];

          dev.log('🔵 AUTH_REMOTE_DS: Extracting user info from access token');

          // Extract user info from JWT token
          final userInfo = _extractUserFromJWT(accessToken);
          dev.log('🔵 AUTH_REMOTE_DS: Extracted user info: $userInfo');

          // Store tokens globally for later use
          _tempAccessToken = accessToken;
          _tempSessionId = sessionId;
          _tempCsrfToken = csrfToken;

          // Create user model with extracted info and email
          final userModel = UserModel(
            id: userInfo['id'],
            email: email, // Use the email from login request
            firstName:
                'User', // Default name, will be updated from profile API later
            lastName:
                '', // Default name, will be updated from profile API later
            role: (userInfo['role'] ?? 0).toString(),
            emailVerified: true, // Assume verified since login was successful
            status: 'ACTIVE',
            avatar: null,
            phone: null,
            emailVerifiedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          dev.log(
              '🟢 AUTH_REMOTE_DS: Login successful, created UserModel for: $email');
          return userModel;
        }

        // Fallback for direct user data response (if API format changes)
        if (data['user'] != null) {
          dev.log(
              '🟢 AUTH_REMOTE_DS: Login successful with direct user data format');
          return UserModel.fromJson(data['user']);
        }

        dev.log('🔴 AUTH_REMOTE_DS: Unexpected response format');
        throw const FormatException(
            'Unexpected response format from login API');
      } else {
        dev.log(
            '🔴 AUTH_REMOTE_DS: Login failed with status: ${response.statusCode}');
        throw ServerException('Login failed');
      }
    } on DioException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: DioException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error type: ${e.type}');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      dev.log('🔴 AUTH_REMOTE_DS: Response status: ${e.response?.statusCode}');
      dev.log('🔴 AUTH_REMOTE_DS: Response data: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: General exception caught: $e');
      dev.log('🔴 AUTH_REMOTE_DS: Exception type: ${e.runtimeType}');
      if (e is AuthException) {
        dev.log('🔴 AUTH_REMOTE_DS: Re-throwing AuthException');
        rethrow;
      }
      throw ServerException('Unexpected error during login');
    }
  }

  // Helper method to extract user info from JWT token
  Map<String, dynamic> _extractUserFromJWT(String token) {
    try {
      dev.log('🔵 AUTH_REMOTE_DS: Decoding JWT token');

      // JWT tokens have 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        throw FormatException('Invalid JWT token format');
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if necessary (JWT base64 encoding might not have padding)
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      // Decode base64
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> decodedPayload = json.decode(decodedString);

      dev.log('🔵 AUTH_REMOTE_DS: JWT payload decoded: $decodedPayload');

      // Extract user info from the 'sub' (subject) field
      final sub = decodedPayload['sub'];
      if (sub != null && sub is Map) {
        dev.log('🔵 AUTH_REMOTE_DS: User info found in sub: $sub');
        return {
          'id': sub['id'] ?? '',
          'role': sub['role'] ?? 0,
        };
      }

      // Fallback: try to get user info from top level
      return {
        'id': decodedPayload['userId'] ?? decodedPayload['id'] ?? '',
        'role': decodedPayload['role'] ?? 0,
      };
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Error decoding JWT token: $e');
      // Return default values if JWT decoding fails
      return {
        'id': 'unknown',
        'role': 0,
      };
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
    String? recaptchaToken,
  }) async {
    dev.log('🔵 AUTH_REMOTE_DS: Starting registration for email: $email');
    dev.log(
        '🔵 AUTH_REMOTE_DS: Registration data: {firstName: $firstName, lastName: $lastName, email: $email, referralCode: $referralCode}');

    try {
      // Step 1: Get PoW challenge from backend
      dev.log('🔵 AUTH_REMOTE_DS: Requesting PoW challenge');
      final challengeResponse = await client.get(
        '${ApiConstants.powChallenge}?action=register',
      );

      final challengeData = PowChallenge.fromJson(challengeResponse.data);
      dev.log('🔵 AUTH_REMOTE_DS: Received PoW challenge (difficulty: ${challengeData.difficulty})');

      // Step 2: Solve the PoW challenge
      dev.log('🔵 AUTH_REMOTE_DS: Solving PoW challenge...');
      final solution = await PowCaptchaService.solvePowChallenge(
        challenge: challengeData.challenge,
        difficulty: challengeData.difficulty,
      );
      dev.log('🔵 AUTH_REMOTE_DS: PoW challenge solved!');

      // Step 3: Submit registration with PoW solution
      dev.log(
          '🔵 AUTH_REMOTE_DS: Making POST request to ${ApiConstants.register}');

      final requestData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        if (referralCode != null) 'ref': referralCode,
        'powSolution': solution.toJson(), // Add PoW solution
      };

      dev.log(
          '🔵 AUTH_REMOTE_DS: Request data: ${requestData.map((k, v) => MapEntry(k, k == 'password' ? '[HIDDEN]' : v))}');

      final response = await client.post(
        ApiConstants.register,
        data: requestData,
      );

      dev.log(
          '🔵 AUTH_REMOTE_DS: Registration response received - Status: ${response.statusCode}');
      dev.log('🔵 AUTH_REMOTE_DS: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        dev.log('🔵 AUTH_REMOTE_DS: Checking registration response structure...');
        dev.log('🔵 AUTH_REMOTE_DS: Has user: ${data['user'] != null}');
        dev.log('🔵 AUTH_REMOTE_DS: Has cookies: ${data['cookies'] != null}');
        dev.log('🔵 AUTH_REMOTE_DS: Has message: ${data['message'] != null}');
        dev.log('🔵 AUTH_REMOTE_DS: Message: ${data['message']}');

        // Handle successful registration with cookies/tokens (user auto-logged in)
        if (data['cookies'] != null && data['message'] != null) {
          dev.log('🟢 AUTH_REMOTE_DS: Registration successful with auto-login (cookies format)');
          final cookies = data['cookies'];
          final accessToken = cookies['accessToken'];
          final sessionId = cookies['sessionId'];
          final csrfToken = cookies['csrfToken'];

          dev.log('🔵 AUTH_REMOTE_DS: Extracting user info from access token');

          // Extract user info from JWT token
          final userInfo = _extractUserFromJWT(accessToken);
          dev.log('🔵 AUTH_REMOTE_DS: Extracted user info: $userInfo');

          // Store tokens globally for later use
          _tempAccessToken = accessToken;
          _tempSessionId = sessionId;
          _tempCsrfToken = csrfToken;

          // Create user model with extracted info and registration email
          final userModel = UserModel(
            id: userInfo['id'],
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: (userInfo['role'] ?? 0).toString(),
            emailVerified: true, // Auto-verified when email verification is disabled
            status: 'ACTIVE',
            avatar: null,
            phone: null,
            emailVerifiedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          dev.log(
              '🟢 AUTH_REMOTE_DS: Registration successful, user auto-logged in: $email');
          return userModel;
        }

        // Handle direct user data response (old format or if API returns user directly)
        if (data['user'] != null) {
          dev.log(
              '🟢 AUTH_REMOTE_DS: Registration successful with direct user data format');
          return UserModel.fromJson(data['user']);
        }

        // Check if email verification is required (no cookies, just message)
        if (data['user'] == null && data['cookies'] == null && data['message'] != null) {
          dev.log(
              '🟡 AUTH_REMOTE_DS: Email verification required: ${data['message']}');
          throw AuthException(data['message']);
        }

        dev.log('🔴 AUTH_REMOTE_DS: Unexpected registration response format');
        throw const FormatException(
            'Unexpected response format from registration API');
      } else {
        dev.log(
            '🔴 AUTH_REMOTE_DS: Registration failed with status: ${response.statusCode}');
        throw ServerException('Registration failed');
      }
    } on BadRequestException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration BadRequestException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      rethrow;
    } on ValidationException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration ValidationException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      rethrow;
    } on UnauthorizedException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration UnauthorizedException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      rethrow;
    } on NetworkException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration NetworkException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      rethrow;
    } on ServerException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration ServerException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration AuthException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      rethrow;
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Registration unexpected exception caught: $e');
      dev.log('🔴 AUTH_REMOTE_DS: Exception type: ${e.runtimeType}');
      throw ServerException('Unexpected error during registration: $e');
    }
  }

  @override
  Future<void> logout() async {
    dev.log('🔵 AUTH_REMOTE_DS: Starting logout process');

    try {
      dev.log('🔵 AUTH_REMOTE_DS: Making POST request to ${ApiConstants.logout}');
      await client.post(ApiConstants.logout);
      dev.log('🟢 AUTH_REMOTE_DS: Logout API call successful');
    } on DioException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Logout API failed with DioException');
      dev.log('🔴 AUTH_REMOTE_DS: Error type: ${e.type}');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      dev.log('🔴 AUTH_REMOTE_DS: Response status: ${e.response?.statusCode}');
      dev.log('🔴 AUTH_REMOTE_DS: Response data: ${e.response?.data}');

      // If logout fails due to authentication issues (401), we still want to clear local data
      if (e.response?.statusCode == 401) {
        dev.log(
            '🟡 AUTH_REMOTE_DS: Logout failed due to authentication, but continuing with local cleanup');
        // Don't throw exception for 401 - just continue with local cleanup
      } else {
        // For other errors, still continue but log them
        dev.log(
            '🟡 AUTH_REMOTE_DS: Logout API failed, but continuing with local cleanup');
      }
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Logout general exception: $e');
      dev.log('🟡 AUTH_REMOTE_DS: Continuing with local cleanup despite error');
    }

    // Always clear local tokens regardless of API response
    dev.log('🔵 AUTH_REMOTE_DS: Clearing local tokens');
    clearTokens();
    dev.log('🟢 AUTH_REMOTE_DS: Logout process completed');
  }

  @override
  Future<UserModel> verifyTwoFactor(
      {required String userId, required String code}) async {
    try {
      final response = await client.post(
        ApiConstants.twoFactorAuth,
        data: {
          'userId': userId,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return UserModel.fromJson(data['user']);
      } else {
        throw ServerException('2FA verification failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during 2FA verification');
    }
  }

  @override
  Future<UserModel> verifyTwoFactorLogin(
      {required String userId, required String otp}) async {
    dev.log('🔵 AUTH_REMOTE_DS: Starting 2FA login verification for user: $userId');

    try {
      dev.log('🔵 AUTH_REMOTE_DS: Making POST request to /api/auth/otp/login');

      final response = await client.post(
        '/api/auth/otp/login',
        data: {
          'id': userId,
          'otp': otp,
        },
      );

      dev.log('🔵 AUTH_REMOTE_DS: 2FA verification response - Status: ${response.statusCode}');
      dev.log('🔵 AUTH_REMOTE_DS: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle cookies/tokens similar to login
        if (data['cookies'] != null) {
          dev.log('🔵 AUTH_REMOTE_DS: 2FA verification successful with cookies format');
          final cookies = data['cookies'];
          _tempAccessToken = cookies['accessToken'];
          _tempSessionId = cookies['sessionId'];
          _tempCsrfToken = cookies['csrfToken'];
        }

        // Fetch complete user profile
        dev.log('🔵 AUTH_REMOTE_DS: Fetching user profile after 2FA verification');
        final profileResponse = await client.get('/api/user/profile');

        if (profileResponse.statusCode == 200) {
          dev.log('🟢 AUTH_REMOTE_DS: 2FA verification successful, user profile fetched');
          return UserModel.fromJson(profileResponse.data);
        } else {
          throw ServerException('Failed to fetch user profile after 2FA');
        }
      } else {
        dev.log('🔴 AUTH_REMOTE_DS: 2FA verification failed with status: ${response.statusCode}');
        throw ServerException('2FA verification failed');
      }
    } on DioException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: 2FA verification DioException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error type: ${e.type}');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      dev.log('🔴 AUTH_REMOTE_DS: Response status: ${e.response?.statusCode}');
      dev.log('🔴 AUTH_REMOTE_DS: Response data: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: 2FA verification general exception: $e');
      throw ServerException('Unexpected error during 2FA verification');
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      await client.post(ApiConstants.refreshToken);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during token refresh');
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    dev.log(
        '🔵 AUTH_REMOTE_DS: Starting password reset request for email: $email');

    try {
      dev.log(
          '🔵 AUTH_REMOTE_DS: Making POST request to ${ApiConstants.forgotPassword}');

      final response = await client.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      dev.log(
          '🔵 AUTH_REMOTE_DS: Password reset response - Status: ${response.statusCode}');
      dev.log('🔵 AUTH_REMOTE_DS: Response data: ${response.data}');
      dev.log('🟢 AUTH_REMOTE_DS: Password reset request successful');
    } on DioException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Password reset DioException caught');
      dev.log('🔴 AUTH_REMOTE_DS: Error type: ${e.type}');
      dev.log('🔴 AUTH_REMOTE_DS: Error message: ${e.message}');
      dev.log('🔴 AUTH_REMOTE_DS: Response status: ${e.response?.statusCode}');
      dev.log('🔴 AUTH_REMOTE_DS: Response data: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Password reset general exception: $e');
      throw ServerException('Unexpected error during password reset request');
    }
  }

  @override
  Future<void> resetPassword(
      {required String token, required String newPassword}) async {
    try {
      await client.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during password reset');
    }
  }

  @override
  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      await client.post(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during password change');
    }
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    try {
      await client.post(
        ApiConstants.verifyEmail,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during email verification');
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    try {
      await client.post(
        '${ApiConstants.verifyEmail}/resend',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
          'Unexpected error during email verification resend');
    }
  }

  @override
  Future<UserModel> googleSignIn({required String idToken}) async {
    dev.log('🔵 AUTH_REMOTE_DS: Starting Google Sign In');
    try {
      final response = await client.post(
        ApiConstants.googleLogin, // Fixed: Use correct endpoint
        data: {'token': idToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        dev.log('🔵 AUTH_REMOTE_DS: Google login successful');

        // Handle cookies/tokens (same as regular login)
        if (data['cookies'] != null) {
          final cookies = data['cookies'];
          _tempAccessToken = cookies['accessToken'];
          _tempSessionId = cookies['sessionId'];
          _tempCsrfToken = cookies['csrfToken'];
        }

        // Check if user data is nested or direct
        if (data['user'] != null) {
          return UserModel.fromJson(data['user']);
        } else if (data['id'] != null) {
          // User data is at root level
          return UserModel.fromJson(data);
        } else {
          throw const FormatException('Invalid Google login response format');
        }
      } else {
        throw ServerException('Google sign in failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Google sign in error: $e');
      throw ServerException('Unexpected error during Google sign in');
    }
  }

  @override
  Future<UserModel> googleRegister({required String idToken, String? referralCode}) async {
    dev.log('🔵 AUTH_REMOTE_DS: Starting Google Registration');
    try {
      final requestData = {
        'token': idToken,
        if (referralCode != null && referralCode.isNotEmpty) 'ref': referralCode,
      };

      final response = await client.post(
        ApiConstants.googleRegister, // Use correct endpoint
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        dev.log('🔵 AUTH_REMOTE_DS: Google registration successful');

        // Handle cookies/tokens (same as regular login)
        if (data['cookies'] != null) {
          final cookies = data['cookies'];
          _tempAccessToken = cookies['accessToken'];
          _tempSessionId = cookies['sessionId'];
          _tempCsrfToken = cookies['csrfToken'];
        }

        // Check if user data is nested or direct
        if (data['user'] != null) {
          return UserModel.fromJson(data['user']);
        } else if (data['id'] != null) {
          // User data is at root level
          return UserModel.fromJson(data);
        } else {
          throw const FormatException('Invalid Google registration response format');
        }
      } else {
        throw ServerException('Google registration failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Google registration error: $e');
      throw ServerException('Unexpected error during Google registration');
    }
  }

  @override
  Future<Map<String, dynamic>> enableTwoFactor({required String type}) async {
    try {
      final response = await client.post(
        '${ApiConstants.twoFactorAuth}/enable',
        data: {'type': type},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException('2FA enable failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during 2FA enable');
    }
  }

  @override
  Future<void> disableTwoFactor({required String code}) async {
    try {
      await client.post(
        '${ApiConstants.twoFactorAuth}/disable',
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during 2FA disable');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await client.put(
        ApiConstants.updateProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return UserModel.fromJson(responseData['user']);
      } else {
        throw ServerException('Profile update failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error during profile update');
    }
  }

  @override
  Future<void> resendTwoFactorCode({
    required String userId,
    required String type,
  }) async {
    dev.log('🔵 AUTH_REMOTE_DS: Resending 2FA code for user: $userId, type: $type');

    try {
      final response = await client.post(
        ApiConstants.twoFactorResend,
        data: {
          'id': userId,
          'type': type,
        },
      );

      dev.log('🔵 AUTH_REMOTE_DS: Resend 2FA code response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        dev.log('🟢 AUTH_REMOTE_DS: 2FA code resent successfully');
        return;
      }

      throw AuthException('Failed to resend 2FA code');
    } on DioException catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Error resending 2FA code: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      dev.log('🔴 AUTH_REMOTE_DS: Unexpected error resending 2FA code: $e');
      throw AuthException('Failed to resend 2FA code: $e');
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return BadRequestException(
          e.response?.data?['message'] ?? 'Bad request',
        );
      case 401:
        return UnauthorizedException(
          e.response?.data?['message'] ?? 'Unauthorized',
        );
      case 403:
        return ForbiddenException(
          e.response?.data?['message'] ?? 'Forbidden',
        );
      case 404:
        return NotFoundException(
          e.response?.data?['message'] ?? 'Not found',
        );
      case 422:
        return ValidationException(
          e.response?.data?['message'] ?? 'Validation failed',
          e.response?.data?['errors'],
        );
      case 500:
        return ServerException(
          e.response?.data?['message'] ?? 'Internal server error',
        );
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return TimeoutException('Request timeout');
        }
        if (e.type == DioExceptionType.connectionError) {
          return ConnectionException('No internet connection');
        }
        return NetworkException('Network error');
    }
  }
}
