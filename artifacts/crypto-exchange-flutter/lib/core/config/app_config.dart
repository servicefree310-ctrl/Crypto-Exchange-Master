import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// App configuration loaded from assets/config/app_config.json
/// This allows users to configure their app without modifying code
class AppConfig {
  static AppConfig? _instance;
  static bool _initialized = false;

  // Configuration values
  late final String baseUrl;
  late final String wsBaseUrl;
  late final String appName;
  late final String appVersion;

  // Optional API Keys (can be empty)
  late final String stripePublishableKey;
  late final String googleServerClientId;
  late final String recaptchaSiteKey;

  // Authentication feature flags
  late final bool googleAuthEnabled;
  late final bool walletAuthEnabled;
  late final String walletConnectProjectId;
  late final bool recaptchaEnabled;

  // 2FA Configuration
  late final bool twoFactorEnabled;
  late final bool twoFactorSmsEnabled;
  late final bool twoFactorEmailEnabled;
  late final bool twoFactorAppEnabled;

  // Email verification
  late final bool emailVerificationEnabled;

  // Exchange configuration
  late final String defaultExchangeProvider;
  late final String defaultTradingPair;

  // Feature settings
  late final bool defaultShowComingSoon;

  // Cache settings
  late final int settingsCacheDuration;
  late final int backgroundUpdateInterval;

  // Private constructor
  AppConfig._();

  /// Get the singleton instance
  static AppConfig get instance {
    if (!_initialized) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize configuration from JSON file
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load configuration file
      final configString =
          await rootBundle.loadString('assets/config/app_config.json');
      final configJson = json.decode(configString) as Map<String, dynamic>;

      // Create instance
      _instance = AppConfig._();

      // Load required settings
      _instance!.baseUrl = configJson['baseUrl'] ?? 'https://example.com';
      _instance!.wsBaseUrl = configJson['wsBaseUrl'] ?? 'wss://example.com';
      _instance!.appName = configJson['appName'] ?? 'CryptoX Exchange';
      _instance!.appVersion = configJson['appVersion'] ?? '5.0.0';

      // Load optional API keys
      _instance!.stripePublishableKey =
          configJson['stripePublishableKey'] ?? '';
      _instance!.googleServerClientId =
          configJson['googleServerClientId'] ?? '';
      _instance!.recaptchaSiteKey =
          configJson['recaptchaSiteKey'] ?? '';

      // Load authentication feature flags
      _instance!.googleAuthEnabled = configJson['googleAuthEnabled'] ?? true;
      _instance!.walletAuthEnabled = configJson['walletAuthEnabled'] ?? false;
      _instance!.walletConnectProjectId =
          configJson['walletConnectProjectId'] ?? '';
      _instance!.recaptchaEnabled = configJson['recaptchaEnabled'] ?? false;

      // Load 2FA configuration
      _instance!.twoFactorEnabled = configJson['twoFactorEnabled'] ?? true;
      _instance!.twoFactorSmsEnabled =
          configJson['twoFactorSmsEnabled'] ?? true;
      _instance!.twoFactorEmailEnabled =
          configJson['twoFactorEmailEnabled'] ?? true;
      _instance!.twoFactorAppEnabled =
          configJson['twoFactorAppEnabled'] ?? true;

      // Load email verification
      _instance!.emailVerificationEnabled =
          configJson['emailVerificationEnabled'] ?? true;

      // Load exchange settings
      _instance!.defaultExchangeProvider =
          configJson['defaultExchangeProvider'] ?? 'bin';
      _instance!.defaultTradingPair =
          configJson['defaultTradingPair'] ?? 'BTC/USDT';

      // Load feature settings
      _instance!.defaultShowComingSoon =
          configJson['defaultShowComingSoon'] ?? true;

      // Load cache settings
      _instance!.settingsCacheDuration =
          configJson['settingsCacheDuration'] ?? 3600;
      _instance!.backgroundUpdateInterval =
          configJson['backgroundUpdateInterval'] ?? 60;

      _initialized = true;
    } catch (e) {
      // If config file is missing or invalid, throw a helpful error
      throw Exception(
        'Failed to load app configuration. Please ensure assets/config/app_config.json exists and is valid.\n'
        'Error: $e',
      );
    }
  }

  /// Reset configuration (useful for testing)
  static void reset() {
    _instance = null;
    _initialized = false;
  }

  /// Initialize with explicit values for testing only.
  /// Bypasses asset bundle loading so unit tests don't need to mount Flutter
  /// asset infrastructure. Idempotent — repeated calls reset and re-init.
  ///
  /// **DO NOT call from app runtime code.** Production code must use
  /// [initialize] which loads `assets/config/app_config.json`. This helper
  /// is annotated with [visibleForTesting] so the analyzer flags any
  /// non-test caller.
  @visibleForTesting
  static void initializeForTesting({
    String baseUrl = 'http://localhost:0',
    String wsBaseUrl = 'ws://localhost:0',
    String appName = 'CryptoX Exchange',
    String appVersion = '0.0.0-test',
    String defaultTradingPair = 'BTC/USDT',
  }) {
    _instance = AppConfig._();
    _instance!.baseUrl = baseUrl;
    _instance!.wsBaseUrl = wsBaseUrl;
    _instance!.appName = appName;
    _instance!.appVersion = appVersion;
    _instance!.stripePublishableKey = '';
    _instance!.googleServerClientId = '';
    _instance!.recaptchaSiteKey = '';
    _instance!.googleAuthEnabled = false;
    _instance!.walletAuthEnabled = false;
    _instance!.walletConnectProjectId = '';
    _instance!.recaptchaEnabled = false;
    _instance!.twoFactorEnabled = false;
    _instance!.twoFactorSmsEnabled = false;
    _instance!.twoFactorEmailEnabled = false;
    _instance!.twoFactorAppEnabled = false;
    _instance!.emailVerificationEnabled = false;
    _instance!.defaultExchangeProvider = 'bin';
    _instance!.defaultTradingPair = defaultTradingPair;
    _instance!.defaultShowComingSoon = false;
    _instance!.settingsCacheDuration = 3600;
    _instance!.backgroundUpdateInterval = 60;
    _initialized = true;
  }
}
