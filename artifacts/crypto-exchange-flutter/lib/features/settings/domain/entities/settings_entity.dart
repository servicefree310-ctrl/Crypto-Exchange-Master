import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final Map<String, dynamic> settings;
  final List<String> extensions;
  final DateTime lastUpdated;

  const SettingsEntity({
    required this.settings,
    required this.extensions,
    required this.lastUpdated,
  });

  // Helper methods to get specific settings with type safety
  bool get isFeatureEnabled => _getBoolSetting('featureEnabled', true);
  bool get isDepositEnabled => _getBoolSetting('deposit', true);
  bool get isWithdrawEnabled => _getBoolSetting('withdraw', true);
  bool get isTransferEnabled => _getBoolSetting('transfer', true);
  bool get isInvestmentEnabled => _getBoolSetting('investment', true);
  bool get isForexInvestmentEnabled => _getBoolSetting('forexInvestment', true);
  bool get isKycEnabled => _getBoolSetting('kycStatus', false);
  bool get isFiatWalletsEnabled => _getBoolSetting('fiatWallets', true);
  bool get isP2pEnabled => _getBoolSetting('p2pEnabled', false);
  bool get isStakingEnabled => _getBoolSetting('stakingEnabled', false);
  bool get isIcoEnabled => _getBoolSetting('icoEnabled', false);
  bool get isBlogEnabled => _getBoolSetting('blogEnabled', false);
  bool get isEcommerceEnabled => _getBoolSetting('ecommerceEnabled', false);
  bool get isFuturesEnabled => _getBoolSetting('futuresEnabled', false);
  bool get isAiInvestmentEnabled =>
      _getBoolSetting('aiInvestmentEnabled', false);

  // Business logic settings
  String get mlmSystem => _getStringSetting('mlmSystem', 'DIRECT');
  int get binaryLevels => _getIntSetting('binaryLevels', 2);
  double get binaryLevel1 => _getDoubleSetting('binaryLevel1', 10.0);
  double get binaryLevel2 => _getDoubleSetting('binaryLevel2', 10.0);
  int get unilevelLevels => _getIntSetting('unilevelLevels', 2);
  double get unilevelLevel1 => _getDoubleSetting('unilevelLevel1', 0.0);
  double get unilevelLevel2 => _getDoubleSetting('unilevelLevel2', 0.0);
  bool get referralApprovalRequired =>
      _getBoolSetting('referralApprovalRequired', true);
  double get walletTransferFee => _getDoubleSetting('walletTransferFee', 1.0);
  double get spotWithdrawFee => _getDoubleSetting('spotWithdrawFee', 1.0);
  double get p2pCommission => _getDoubleSetting('p2pCommission', 1.0);

  // UI Settings
  bool get themeSwitcherEnabled => _getBoolSetting('themeSwitcher', true);
  bool get layoutSwitcherEnabled => _getBoolSetting('layoutSwitcher', true);
  String get logo => _getStringSetting('logo', '');
  String get fullLogo => _getStringSetting('fullLogo', '');
  String get darkLogo => _getStringSetting('darkLogo', '');
  String get darkFullLogo => _getStringSetting('darkFullLogo', '');
  String get cardLogo => _getStringSetting('cardLogo', '');

  // Social Links
  String get telegramLink => _getStringSetting('telegramLink', '');
  String get linkedinLink => _getStringSetting('linkedinLink', '');
  String get appStoreLink => _getStringSetting('appStoreLink', '');
  String get googlePlayLink => _getStringSetting('googlePlayLink', '');
  String get facebookLink => _getStringSetting('facebookLink', '');
  String get instagramLink => _getStringSetting('instagramLink', '');
  String get twitterLink => _getStringSetting('twitterLink', '');

  // Feature Status Settings
  bool get newsStatus => _getBoolSetting('newsStatus', true);
  bool get floatingLiveChat => _getBoolSetting('floatingLiveChat', true);
  bool get lottieAnimationStatus =>
      _getBoolSetting('lottieAnimationStatus', true);
  bool get depositExpiration => _getBoolSetting('depositExpiration', true);

  // Lottie Animation Settings
  bool get investmentPlansLottieEnabled =>
      _getBoolSetting('investmentPlansLottieEnabled', true);
  bool get affiliateLottieEnabled =>
      _getBoolSetting('affiliateLottieEnabled', true);
  bool get icoLottieEnabled => _getBoolSetting('icoLottieEnabled', true);
  bool get binaryLottieEnabled => _getBoolSetting('binaryLottieEnabled', true);
  bool get mobileVerificationLottieEnabled =>
      _getBoolSetting('mobileVerificationLottieEnabled', true);
  bool get forexLottieEnabled => _getBoolSetting('forexLottieEnabled', true);
  bool get ecommerceLottieEnabled =>
      _getBoolSetting('ecommerceLottieEnabled', true);
  bool get stakingLottieEnabled =>
      _getBoolSetting('stakingLottieEnabled', true);
  bool get investmentLottieEnabled =>
      _getBoolSetting('investmentLottieEnabled', true);
  bool get loginLottieEnabled => _getBoolSetting('loginLottieEnabled', true);
  bool get appVerificationLottieEnabled =>
      _getBoolSetting('appVerificationLottieEnabled', true);
  bool get emailVerificationLottieEnabled =>
      _getBoolSetting('emailVerificationLottieEnabled', true);

  // Layout and UI Settings
  String get blogPostLayout => _getStringSetting('blogPostLayout', 'DEFAULT');
  String get landingPageType => _getStringSetting('landingPageType', 'DEFAULT');
  String get chartType => _getStringSetting('chartType', 'TRADINGVIEW');

  // MLM Settings
  String get mlmSettings => _getStringSetting('mlmSettings', '{}');

  // Ecommerce Settings
  bool get ecommerceTaxEnabled => _getBoolSetting('ecommerceTaxEnabled', false);
  double get ecommerceDefaultTaxRate =>
      _getDoubleSetting('ecommerceDefaultTaxRate', 0.08);
  bool get ecommerceShippingEnabled =>
      _getBoolSetting('ecommerceShippingEnabled', true);
  double get ecommerceDefaultShippingCost =>
      _getDoubleSetting('ecommerceDefaultShippingCost', 9.99);
  double get ecommerceFreeShippingThreshold => _getDoubleSetting(
      'ecommerceFreeShippingThreshold',
      0.0); // 0.0 means no free shipping by default
  bool get ecommerceAllowInternationalShipping =>
      _getBoolSetting('ecommerceAllowInternationalShipping', true);
  int get ecommerceProductsPerPage =>
      _getIntSetting('ecommerceProductsPerPage', 20);
  bool get ecommerceShowOutOfStockProducts =>
      _getBoolSetting('ecommerceShowOutOfStockProducts', true);
  bool get ecommerceShowProductRatings =>
      _getBoolSetting('ecommerceShowProductRatings', true);
  bool get ecommerceShowRelatedProducts =>
      _getBoolSetting('ecommerceShowRelatedProducts', true);
  bool get ecommerceShowFeaturedProducts =>
      _getBoolSetting('ecommerceShowFeaturedProducts', true);

  // Extension checks - Fixed to use the actual extensions array from API
  bool get hasP2pExtension => extensions.contains('p2p');
  bool get hasStakingExtension => extensions.contains('staking');
  bool get hasIcoExtension => extensions.contains('ico');
  bool get hasBlogExtension =>
      extensions.contains('knowledge_base'); // API uses knowledge_base
  bool get hasEcommerceExtension => extensions.contains('ecommerce');
  bool get hasFuturesExtension => extensions.contains('futures');
  bool get hasAiInvestmentExtension =>
      extensions.contains('ai_investment'); // API uses ai_investment
  bool get hasForexExtension => extensions.contains('forex');
  bool get hasEcosystemExtension => extensions.contains('ecosystem');
  bool get hasMlmExtension => extensions.contains('mlm');
  bool get hasMailwizardExtension => extensions.contains('mailwizard');
  bool get hasWalletConnectExtension => extensions.contains('wallet_connect');

  // Helper methods for type-safe setting retrieval
  bool _getBoolSetting(String key, bool defaultValue) {
    final value = settings[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  String _getStringSetting(String key, String defaultValue) {
    final value = settings[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  int _getIntSetting(String key, int defaultValue) {
    final value = settings[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  double _getDoubleSetting(String key, double defaultValue) {
    final value = settings[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  // Check if a feature is available (enabled in settings AND has extension)
  bool isFeatureAvailable(String featureKey) {
    switch (featureKey) {
      case 'p2p':
        return hasP2pExtension;
      case 'staking':
        return hasStakingExtension;
      case 'ico':
        return hasIcoExtension;
      case 'blog':
        return hasBlogExtension;
      case 'ecommerce':
        return hasEcommerceExtension;
      case 'futures':
        return hasFuturesExtension;
      case 'aiInvestment':
        return hasAiInvestmentExtension;
      case 'forex':
        return hasForexExtension;
      case 'ecosystem':
        return hasEcosystemExtension;
      case 'mlm':
        return hasMlmExtension;
      case 'mailwizard':
        return hasMailwizardExtension;
      case 'wallet_connect':
        return hasWalletConnectExtension;
      default:
        return false;
    }
  }

  // Get all available features
  List<String> get availableFeatures {
    final features = <String>[];
    if (isFeatureAvailable('p2p')) features.add('p2p');
    if (isFeatureAvailable('staking')) features.add('staking');
    if (isFeatureAvailable('ico')) features.add('ico');
    if (isFeatureAvailable('blog')) features.add('blog');
    if (isFeatureAvailable('ecommerce')) features.add('ecommerce');
    if (isFeatureAvailable('futures')) features.add('futures');
    if (isFeatureAvailable('aiInvestment')) features.add('aiInvestment');
    if (isFeatureAvailable('forex')) features.add('forex');
    if (isFeatureAvailable('ecosystem')) features.add('ecosystem');
    if (isFeatureAvailable('mlm')) features.add('mlm');
    if (isFeatureAvailable('mailwizard')) features.add('mailwizard');
    if (isFeatureAvailable('wallet_connect')) features.add('wallet_connect');

    return features;
  }

  // Get all coming soon features (features not in extensions array)
  List<String> get comingSoonFeatures {
    final features = <String>[];

    // Check all possible features that might not be in extensions
    final allPossibleFeatures = [
      'p2p',
      'staking',
      'ico',
      'blog',
      'ecommerce',
      'futures',
      'aiInvestment',
      'forex',
      'ecosystem',
      'mlm',
      'mailwizard',
      'wallet_connect'
    ];

    for (final feature in allPossibleFeatures) {
      if (!isFeatureAvailable(feature)) {
        features.add(feature);
      }
    }

    return features;
  }

  @override
  List<Object?> get props => [settings, extensions, lastUpdated];

  SettingsEntity copyWith({
    Map<String, dynamic>? settings,
    List<String>? extensions,
    DateTime? lastUpdated,
  }) {
    return SettingsEntity(
      settings: settings ?? this.settings,
      extensions: extensions ?? this.extensions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
