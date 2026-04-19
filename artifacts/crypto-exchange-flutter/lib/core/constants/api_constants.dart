import '../config/app_config.dart';

class ApiConstants {
  // Base URL - Using configuration
  static String get baseUrl => AppConfig.instance.baseUrl;

  // WebSocket URL
  static String get wsBaseUrl => AppConfig.instance.wsBaseUrl;

  // API Endpoints
  static const String apiVersion = '/api';

  // Exchange Configuration - Following v5 backend structure
  // Default to binance, supports: binance, kucoin, okx, xt, kraken
  static String get exchangeProvider =>
      AppConfig.instance.defaultExchangeProvider; // First 3 letters

  // Default Trading Pair
  static String get defaultTradingPair => AppConfig.instance.defaultTradingPair;

  // Auth Endpoints
  static const String login = '$apiVersion/auth/login/flutter';
  static const String googleLogin =
      '$apiVersion/auth/login/google'; // Google OAuth login
  static const String googleRegister =
      '$apiVersion/auth/register/google'; // Google OAuth registration
  static const String register = '$apiVersion/auth/register';
  static const String powChallenge =
      '$apiVersion/auth/pow/challenge'; // PoW CAPTCHA challenge endpoint
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String verifyEmail = '$apiVersion/auth/verify';
  static const String forgotPassword = '$apiVersion/auth/reset';
  static const String resetPassword = '$apiVersion/auth/reset/confirm';
  static const String changePassword = '$apiVersion/auth/change-password';
  static const String twoFactorAuth = '$apiVersion/auth/2fa';
  static const String twoFactorResend =
      '$apiVersion/auth/otp/resend'; // Resend 2FA OTP

  // User Endpoints
  static const String userProfile = '$apiVersion/user/profile';
  static const String updateProfile = '$apiVersion/user/profile';
  static const String userSettings = '$apiVersion/user/settings';

  // Market Endpoints - Updated to match backend
  static const String markets = '$apiVersion/exchange/market';
  static const String ticker = '$apiVersion/exchange/ticker';
  static const String tickerSymbol =
      '$apiVersion/exchange/ticker'; // For specific symbol: /currency/pair
  static const String orderbook = '$apiVersion/exchange/orderbook';
  static const String trades = '$apiVersion/exchange/trades';

  // Chart Endpoints - Following v5 structure exactly
  static const String chartHistory = '$apiVersion/exchange/chart';

  // WebSocket Market Endpoints (for future use)
  static const String wsMarketTicker = '$apiVersion/exchange/ticker';
  static const String wsMarketData = '$apiVersion/exchange/market';

  // WebSocket Futures Endpoints
  static const String wsFuturesMarket = '/api/futures/market';

  // Watchlist Endpoints (if available in backend)
  static const String watchlist = '$apiVersion/user/watchlist';

  // Trading Endpoints
  static const String orders = '$apiVersion/exchange/order'; // Listing orders
  static const String createOrder =
      '$apiVersion/exchange/order'; // Create order
  static const String cancelOrder =
      '$apiVersion/exchange/order'; // Cancel order by ID appended
  static const String orderHistory = orders; // Alias for clarity

  // Wallet Endpoints
  static const String wallet = '$apiVersion/finance/wallet';
  static const String wallets = wallet; // Backward-compatible alias
  static const String transactions = '$apiVersion/finance/transaction';
  static const String deposit = '$apiVersion/finance/deposit';
  static const String withdraw = '$apiVersion/finance/withdraw';

  // Withdraw Endpoints
  static const String withdrawCurrencies =
      '$apiVersion/finance/currency'; // with ?action=withdraw&walletType={type}
  static const String withdrawMethods =
      '$apiVersion/finance/currency'; // /{walletType}/{currency}?action=withdraw
  static const String withdrawSpot = '$apiVersion/finance/withdraw/spot';
  static const String withdrawFiat = '$apiVersion/finance/withdraw/fiat';
  static const String ecoWithdraw = '$apiVersion/ecosystem/withdraw';
  static const String ecoWithdrawMax = '$apiVersion/ecosystem/withdraw/max';

  // Transfer Endpoints
  static const String transferOptions = '/api/finance/wallet/transfer-options';
  static const String transferCurrency = '/api/finance/currency';
  static const String transfer = '/api/finance/transfer';
  static const String transferValidate = '$transfer/validate';

  // SPOT Endpoints
  static const String spotCurrencies =
      '$apiVersion/finance/currency?action=deposit&walletType=SPOT';
  static const String spotNetworks = '$apiVersion/finance/currency/SPOT';
  static const String spotDepositAddress = '$apiVersion/finance/currency/SPOT';
  static const String spotDeposit = '$apiVersion/finance/deposit/spot';
  static const String spotDepositWs = '/api/finance/deposit/spot';

  // ECO Endpoints
  static const String ecoCurrencies =
      '$apiVersion/finance/currency?action=deposit&walletType=ECO';
  static const String ecoTokens = '$apiVersion/finance/currency/ECO';
  static const String ecoWallet = '$apiVersion/ecosystem/wallet';
  static const String ecoDepositUnlock = '$apiVersion/ecosystem/deposit/unlock';
  static const String ecoDepositWs = '/api/ecosystem/deposit';

  // FUTURES Endpoints
  static const String futuresCurrencies =
      '$apiVersion/finance/currency?action=deposit&walletType=FUTURES';
  static const String futuresTokens = '$apiVersion/finance/currency/FUTURES';

  // Content Endpoints
  static const String announcements = '$apiVersion/content/announcements';
  static const String faqs = '$apiVersion/content/faqs';
  static const String support = '$apiVersion/support';

  // Support Endpoints
  static const String supportTickets = '$apiVersion/user/support/ticket';
  static const String supportTicketDetail =
      '$apiVersion/user/support/ticket'; // append /{id}
  static const String supportTicketReply =
      '$apiVersion/user/support/ticket'; // append /{id}
  static const String supportTicketClose =
      '$apiVersion/user/support/ticket'; // append /{id}/close
  static const String supportTicketReview =
      '$apiVersion/user/support/ticket'; // append /{id}/review
  static const String supportLiveChat = '$apiVersion/user/support/chat';
  static const String supportLiveChatMessage = '$apiVersion/user/support/chat';

  // Support WebSocket
  static const String supportWebSocket = '$apiVersion/user/support/ticket';

  // Blog Endpoints
  static const String blogPosts = '$apiVersion/blog/post';
  static const String blogPostDetail =
      '$apiVersion/blog/post'; // append /{slug}
  static const String blogCategories = '$apiVersion/blog/category';
  static const String blogTags = '$apiVersion/blog/tag';
  static const String blogAuthors = '$apiVersion/blog/author';
  static const String blogTopAuthors = '$apiVersion/blog/author/top';
  static const String blogComments = '$apiVersion/blog/comment';
  static const String blogPostComments =
      '$apiVersion/blog/comment'; // append /{postId}
  static const String blogAuthorApply =
      '$apiVersion/blog/author'; // POST to apply

  // Author Management Endpoints (for approved authors)
  static const String blogAuthorManage = '$apiVersion/blog/author/manage';
  static const String blogAuthorCreatePost =
      '$apiVersion/blog/author/manage'; // POST
  static const String blogAuthorUpdatePost =
      '$apiVersion/blog/author/manage'; // PUT /{id}
  static const String blogAuthorDeletePost =
      '$apiVersion/blog/author/manage'; // DELETE /{id}
  static const String blogAuthorPostStatus =
      '$apiVersion/blog/author/manage/status'; // PUT /{id}

  // Ecommerce Endpoints
  static const String ecommerceProducts = '/api/ecommerce/product';
  // For product detail append '/{slug}'
  static const String ecommerceProduct = '/api/ecommerce/product';

  static const String ecommerceCategories = '/api/ecommerce/category';
  // For category detail append '/{slug}'
  static const String ecommerceCategory = '/api/ecommerce/category';
  // For products under a category: '/{slug}/product'
  static const String ecommerceCategoryProducts = '/api/ecommerce/category';

  // Orders
  static const String ecommerceOrders = '/api/ecommerce/order';
  // Order detail append '/{id}'
  static const String ecommerceOrder = '/api/ecommerce/order';
  // Track order: '/{id}/track'

  // Wishlist
  static const String ecommerceWishlist = '/api/ecommerce/wishlist';
  // Wishlist item delete append '/{productId}'

  // Digital product download
  static const String ecommerceDownload =
      '/api/ecommerce/download'; // append '/{orderItemId}'

  // Reviews - POST to /api/ecommerce/review/{productId}
  static const String ecommerceReviews = '/api/ecommerce/review';
  static const String ecommerceProductReviews =
      '/api/ecommerce/review'; // append '/{productId}'

  // Discount/Coupon Endpoints
  static const String ecommerceDiscountValidate =
      '/api/ecommerce/discount/validate';
  static const String ecommerceDiscountApply =
      '/api/ecommerce/discount'; // append '/{productId}'

  // Shipping methods
  static const String ecommerceShipping = '/api/ecommerce/shipping';

  // Landing page data (stats, featured, trending, best sellers, reviews)
  static const String ecommerceLanding = '/api/ecommerce/landing';

  // Dashboard stats
  static const String ecommerceStats = '/api/ecommerce/stats';

  // Payment Gateway Keys
  static String get stripePublishableKey =>
      AppConfig.instance.stripePublishableKey;

  // Auth Provider Keys
  static String get googleServerClientId =>
      AppConfig.instance.googleServerClientId;

  // New wallet symbol balance endpoint
  static const String walletSymbolBalance = '$apiVersion/finance/wallet/symbol';

  // Staking Endpoints
  static const String stakingPools = '$apiVersion/staking/pool';
  static const String stakingPoolById =
      '$apiVersion/staking/pool'; // append '/{id}'
  static const String stakingPoolAnalytics =
      '$apiVersion/staking/pool'; // '/{id}/analytics'
  static const String stakingStats = '$apiVersion/staking/stats';
  static const String stakingPositions = '$apiVersion/staking/position';
  static const String stakingPositionById =
      '$apiVersion/staking/position'; // '/{id}'
  static const String stakingWithdraw =
      '$apiVersion/staking/position'; // '/{id}/withdraw'
  static const String stakingClaim =
      '$apiVersion/staking/position'; // '/{id}/claim'
  static const String stakingSummary = '$apiVersion/staking/user/summary';
  static const String stakingEarnings = '$apiVersion/staking/user/earnings';
  static const String stakingRewardCalc =
      '$apiVersion/staking/calculate-rewards';

  // ICO (Initial Coin Offering) Endpoints
  // Public ICO Endpoints
  static const String icoOffers = '/api/ico/offer';
  static const String icoOfferById = '/api/ico/offer'; // append '/{id}'
  static const String icoFeaturedOffers = '/api/ico/offer/featured';
  static const String icoBlockchains = '/api/ico/blockchain';
  static const String icoTokenTypes = '/api/ico/token/type';
  static const String icoLaunchPlans = '/api/ico/plan';
  static const String icoStats = '/api/ico/stats';

  // User ICO Endpoints
  static const String icoPortfolio = '/api/ico/portfolio';
  static const String icoPortfolioPerformance =
      '/api/ico/portfolio/performance';
  static const String icoTransactions = '/api/ico/transaction';
  static const String icoTransactionById =
      '/api/ico/transaction'; // append '/{id}'
  static const String icoCreateInvestment =
      '/api/ico/transaction'; // POST endpoint

  // ICO Creator Endpoints
  static const String icoCreatorTokens = '/api/ico/creator/token';
  static const String icoCreatorTokenById = '/api/ico/creator/token';
  static const String icoCreatorLaunch = '/api/ico/creator/launch';
  static const String icoLaunchPlan = '/api/ico/creator/launch/plan';
  static const String icoCreatorInvestors = '/api/ico/creator/investor';
  static const String icoCreatorStats = '/api/ico/creator/stat';
  static const String icoCreatorTokenTeam = '/api/ico/creator/token';
  static const String icoCreatorTokenRoadmap = '/api/ico/creator/token';
  static const String icoCreatorPerformance = '/api/ico/creator/performance';

  // Token Simulator (client-side only, no backend needed)
  // Token Economics calculations are done locally

  // ICO Creator Token Management (append '/{tokenId}')
  static const String icoCreatorTokenPlan =
      '/api/ico/creator/token'; // '/{id}/plan'
  static const String icoCreatorTokenRoadmapItem =
      '/api/ico/creator/token'; // '/{id}/roadmap/{roadmapId}'

  // ICO Creator Team Management (append '/{tokenId}/team/{teamId}')
  static const String icoCreatorTeamMember =
      '/api/ico/creator/token'; // '/{id}/team/{teamId}'

  // ICO Creator Performance (append '/{id}')
  static const String icoCreatorTokenPerformance =
      '/api/ico/creator/token'; // '/{id}/performance'

  // ICO Creator Updates (append '/{id}')
  static const String icoCreatorTokenUpdate =
      '/api/ico/creator/token'; // '/{id}/update'

  // Futures Trading Endpoints
  static const String futuresMarkets = '/api/futures/market';
  static const String futuresPositions = '/api/futures/position';
  static const String futuresOrders = '/api/futures/order';
  static const String futuresLeverage = '/api/futures/leverage';
  static const String futuresChart = '/api/futures/chart';

  // Forex Trading Endpoints
  static const String forexCurrencies = '/api/forex/currency';
  static const String forexPlans = '/api/forex/plan';
  static const String forexInvestments = '/api/forex/investment';
  static const String forexSignals = '/api/forex/signal';

  // AI Investment Endpoints
  static const String aiPlans = '/api/ai/plan';
  static const String aiInvestments = '/api/ai/investment';
  static const String aiTrades = '/api/ai/trade';

  // Ecosystem/ERC20 Token Endpoints
  static const String ecosystemTokens = '/api/ecosystem/token';
  static const String ecosystemMasterWallet = '/api/ecosystem/master-wallet';
  static const String ecosystemPool = '/api/ecosystem/pool';
  static const String ecosystemStaking = '/api/ecosystem/staking';

  // ========================================
  // MLM/AFFILIATE PROGRAM ENDPOINTS
  // Based on v5 backend: /api/affiliate/*
  // ========================================

  // MLM Dashboard
  static const String mlmDashboard = '/api/affiliate';
  static const String mlmDashboardAnalytics =
      '/api/affiliate'; // with ?period=1m|3m|6m|1y

  // MLM Referrals Management
  static const String mlmReferrals = '/api/affiliate/referral';
  static const String mlmReferralById =
      '/api/affiliate/referral'; // append '/{id}'
  static const String mlmReferralAnalysis =
      '/api/affiliate/referral/analysis'; // POST
  static const String mlmReferralNode =
      '/api/affiliate/referral/node'; // GET network node structure

  // MLM Rewards Management
  static const String mlmRewards = '/api/affiliate/reward';
  static const String mlmRewardById = '/api/affiliate/reward'; // append '/{id}'
  static const String mlmRewardClaim =
      '/api/affiliate/reward'; // POST '/{id}/claim'

  // MLM Network Structure
  static const String mlmNetwork = '/api/affiliate/network';
  static const String mlmNetworkNode =
      '/api/affiliate/network'; // GET user network tree

  // MLM Conditions (Reward Requirements)
  static const String mlmConditions = '/api/affiliate/condition';
  static const String mlmConditionById =
      '/api/affiliate/condition'; // append '/{id}'

  // MLM Analytics & Statistics
  static const String mlmAnalytics = '/api/affiliate/analytics';
  static const String mlmPerformance = '/api/affiliate/performance';

  // MLM Landing Page (public)
  static const String mlmLanding = '/api/affiliate/landing';

  // Legacy Affiliate Endpoints (for backward compatibility)
  static const String affiliateStats = '/api/affiliate/stats';
  static const String affiliateReferrals = '/api/affiliate/referral';
  static const String affiliateCommissions = '/api/affiliate/commission';

  // FAQ Endpoints
  static const String faqCategories = '/api/faq/category';
  static const String faqQuestions = '/api/faq';
  static const String faqQuestion = '/api/faq'; // append '/{id}'

  // Payment Gateway Endpoints
  static const String paymentGateways = '/api/payment/gateway';
  static const String paymentMethods = '/api/payment/method';

  // ========================================
  // P2P TRADING ENDPOINTS
  // Based on v5 backend: /api/p2p/*
  // ========================================

  // P2P Offer Endpoints
  static const String p2pOffers = '/api/p2p/offer';
  static const String p2pOfferById = '/api/p2p/offer'; // append '/{id}'
  static const String p2pCreateOffer = '/api/p2p/offer'; // POST
  static const String p2pUpdateOffer = '/api/p2p/offer'; // PUT /{id}
  static const String p2pDeleteOffer = '/api/p2p/offer'; // DELETE /{id}
  static const String p2pPopularOffers = '/api/p2p/offer/popularity';

  // P2P Trade Endpoints
  static const String p2pTrades = '/api/p2p/trade';
  static const String p2pTradeById = '/api/p2p/trade'; // append '/{id}'
  static const String p2pCreateTrade = '/api/p2p/trade'; // POST
  static const String p2pConfirmTrade = '/api/p2p/trade'; // POST /{id}/confirm
  static const String p2pCancelTrade = '/api/p2p/trade'; // POST /{id}/cancel
  static const String p2pDisputeTrade = '/api/p2p/trade'; // POST /{id}/dispute
  static const String p2pReleaseEscrow = '/api/p2p/trade'; // POST /{id}/release
  static const String p2pReviewTrade = '/api/p2p/trade'; // POST /{id}/review

  // P2P Payment Methods
  static const String p2pPaymentMethods = '/api/p2p/payment-method';
  static const String p2pPaymentMethodById =
      '/api/p2p/payment-method'; // append '/{id}'
  static const String p2pCreatePaymentMethod =
      '/api/p2p/payment-method'; // POST
  static const String p2pUpdatePaymentMethod =
      '/api/p2p/payment-method'; // PUT /{id}
  static const String p2pDeletePaymentMethod =
      '/api/p2p/payment-method'; // DELETE /{id}

  // P2P Market Data
  static const String p2pMarketStats = '/api/p2p/market/stats';
  static const String p2pMarketTop = '/api/p2p/market/top';
  static const String p2pMarketHighlights = '/api/p2p/market/highlight';

  // P2P Location Endpoints
  static const String p2pLocations = '/api/p2p/location';
  static const String p2pLocationById = '/api/p2p/location'; // append '/{id}'
  static const String p2pCreateLocation = '/api/p2p/location'; // POST
  static const String p2pUpdateLocation = '/api/p2p/location'; // PUT /{id}
  static const String p2pDeleteLocation = '/api/p2p/location'; // DELETE /{id}'

  // P2P Dashboard Endpoints
  static const String p2pDashboardStats = '/api/p2p/dashboard/stats';
  static const String p2pDashboardActivity = '/api/p2p/dashboard/activity';
  static const String p2pDashboardPortfolio = '/api/p2p/dashboard/portfolio';
  static const String p2pDashboardData = '/api/p2p/dashboard';

  // P2P Guided Matching
  static const String p2pGuidedMatching = '/api/p2p/guided-matching';

  // P2P Dispute System
  static const String p2pDisputes = '/api/p2p/dispute';
  static const String p2pDisputeById = '/api/p2p/dispute'; // append '/{id}'
  static const String p2pDisputeEvidence =
      '/api/p2p/dispute'; // POST /{id}/evidence
  static const String p2pDisputeMessages =
      '/api/p2p/dispute'; // GET /{id}/messages

  // P2P User Profile & Reviews
  static const String p2pUserProfile = '/api/p2p/user/profile';
  static const String p2pUserReviews = '/api/p2p/user/reviews';
  static const String p2pReviews = '/api/p2p/review';
  static const String p2pReviewById = '/api/p2p/review'; // append '/{id}'

  // P2P Trade Messages
  static const String p2pTradeMessages = '/api/p2p/trade'; // GET /{id}/message
  static const String p2pSendMessage = '/api/p2p/trade'; // POST /{id}/message

  // P2P Base URL for convenience
  static const String p2pBaseUrl = '/api/p2p';

  // User WebSocket - personal notifications & announcements
  static const String userWebSocket = '/api/user';

  // Notifications API
  static const String notifications = '/api/user/notification';

  // ========================================
  // KYC ENDPOINTS
  // Based on v5 backend: /api/user/kyc/*
  // ========================================

  // KYC Level Endpoints
  static const String kycLevels = '/api/user/kyc/level';
  static const String kycLevelById = '/api/user/kyc/level'; // append '/{id}'

  // KYC Application Endpoints
  static const String kycApplications = '/api/user/kyc/application';
  static const String kycApplicationById =
      '/api/user/kyc/application'; // append '/{id}'
  static const String submitKycApplication =
      '/api/user/kyc/application'; // POST
  static const String updateKycApplication =
      '/api/user/kyc/application'; // PUT /{id}
  static const String kycStatus = '/api/user/kyc/status';

  // KYC Document Upload (base64 JSON upload)
  static const String kycDocumentUpload = '/api/upload/kyc-document';

  // ========================================
  // SETTINGS ENDPOINTS
  // Based on v5 backend: /api/settings
  // ========================================

  // Settings API
  static const String settings = '/api/settings';

  // ========================================
  // AI INVESTMENT ENDPOINTS
  // Based on v5 backend: /api/ai/investment/*
  // ========================================

  // AI Investment Plans
  static const String aiInvestmentPlans = '/api/ai/investment/plan';

  // AI Investment Operations
  static const String aiInvestmentOperations = '/api/ai/investment/log';
  static const String aiInvestmentById =
      '/api/ai/investment/log'; // append '/{id}'
  static const String createAiInvestment = '/api/ai/investment/log'; // POST
}

class AppConstants {
  // App Info
  static String get appName => AppConfig.instance.appName;
  static String get appVersion => AppConfig.instance.appVersion;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String sessionIdKey = 'session_id';
  static const String csrfTokenKey = 'csrf_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String settingsKey = 'app_settings';
  static const String settingsTimestampKey = 'settings_timestamp';
  static const String showComingSoonKey = 'show_coming_soon';

  // Theme
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';

  // Default Values
  static const int requestTimeoutDuration = 30000; // 30 seconds
  static const int connectTimeoutDuration = 30000; // 30 seconds
  static const int receiveTimeoutDuration = 30000; // 30 seconds

  // Cache Strategy - Permanent cache with background updates
  // static const int marketDataCacheDuration =
  //     -1; // Permanent cache (never expires)
  // static const int tickerDataCacheDuration =
  //     -1; // Permanent cache (never expires)
  static int get backgroundUpdateInterval => AppConfig.instance
      .backgroundUpdateInterval; // Background update interval from config
  static const int websocketUpdateInterval =
      1; // WebSocket updates every second

  // Settings Cache Strategy
  static int get settingsCacheDuration =>
      AppConfig.instance.settingsCacheDuration; // From config
  static const int settingsBackgroundUpdateInterval =
      300; // 5 minutes background update
  static bool get defaultShowComingSoon =>
      AppConfig.instance.defaultShowComingSoon; // From config

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

enum OrderType {
  market,
  limit,
  stopLoss,
  takeProfit,
}

enum OrderSide {
  buy,
  sell,
}

enum OrderStatus {
  pending,
  open,
  closed,
  cancelled,
  rejected,
}

enum TransactionType {
  deposit,
  withdraw,
  trade,
  fee,
  bonus,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum WalletType {
  fiat,
  spot,
  eco,
  futures,
}

enum TransferType {
  wallet,
  client,
}

enum TransferStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum ProductType {
  downloadable,
  physical,
}

enum MlmSystem {
  direct,
  binary,
  unilevel,
}

enum MlmReferralStatus {
  pending,
  active,
  rejected,
}

enum MlmRewardType {
  percentage,
  fixed,
  tiered,
  referral,
  commission,
  bonus,
  levelBonus,
}

enum MlmRewardStatus {
  pending,
  approved,
  claimed,
  rejected,
}

enum MlmRewardWalletType {
  spot,
  eco,
  futures,
}

enum MlmNodePosition {
  left,
  right,
}
