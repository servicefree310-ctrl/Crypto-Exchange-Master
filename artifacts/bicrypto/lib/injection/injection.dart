import 'dart:developer' as dev;

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

// Core
import '../core/network/dio_client.dart';
import '../core/services/global_notification_service.dart';

// Auth Feature
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/get_cached_user_usecase.dart';
import '../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../features/auth/domain/usecases/verify_two_factor_login_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// News Feature

// Wallet Feature
import '../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';
import '../features/wallet/domain/usecases/get_wallets_usecase.dart';
import '../features/wallet/domain/usecases/get_wallets_by_type_usecase.dart';
import '../features/wallet/domain/usecases/get_wallet_usecase.dart';
import '../features/wallet/domain/usecases/get_wallet_by_id_usecase.dart';
import '../features/wallet/domain/usecases/get_wallet_performance_usecase.dart';
import '../features/wallet/presentation/bloc/wallet_bloc.dart';

// Deposit Feature

// SPOT Deposit Feature

// ECO Deposit Feature

// FUTURES Deposit Feature

// Futures Feature

// Profile Feature
import '../features/profile/data/datasources/profile_cache_manager.dart';
import '../features/profile/data/datasources/profile_remote_data_source.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/domain/usecases/toggle_two_factor_usecase.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/profile/data/services/profile_service.dart';

// Transfer feature imports

// Chart feature imports

// Trade Feature

// AI Investment Feature

// Addons Feature

// Blog Feature
import '../features/addons/blog/data/services/blog_author_service.dart';
import '../features/addons/blog/presentation/bloc/blog_bloc.dart';
import '../features/addons/blog/presentation/bloc/authors_bloc.dart';

// Ecommerce Feature
import '../features/addons/ecommerce/domain/usecases/get_products_usecase.dart';
import '../features/addons/ecommerce/domain/usecases/get_categories_usecase.dart';
import '../features/addons/ecommerce/domain/usecases/get_cart_usecase.dart';
import '../features/addons/ecommerce/domain/usecases/add_to_cart_usecase.dart';
import '../features/addons/ecommerce/domain/usecases/update_cart_item_quantity_usecase.dart';
import '../features/addons/ecommerce/domain/usecases/remove_from_cart_usecase.dart';
import '../features/addons/ecommerce/domain/usecases/clear_cart_usecase.dart';
import '../features/addons/ecommerce/presentation/bloc/cart/cart_bloc.dart';
import '../features/addons/ecommerce/presentation/bloc/shop/shop_bloc.dart';

// P2P Feature

// Support Feature
import '../features/support/presentation/bloc/live_chat_bloc.dart';
import '../features/support/presentation/bloc/ticket_detail_bloc.dart';

// Creator Feature
import '../features/addons/ico_creator/data/datasources/creator_remote_datasource.dart';

// MLM/Affiliate Feature
import '../features/addons/mlm/domain/usecases/get_mlm_rewards_usecase.dart';
import '../features/addons/mlm/domain/usecases/claim_mlm_reward_usecase.dart';
import '../features/addons/mlm/domain/usecases/get_mlm_network_usecase.dart';
import '../features/addons/mlm/domain/repositories/mlm_repository.dart';
import '../features/addons/mlm/presentation/bloc/mlm_rewards_bloc.dart';
import '../features/addons/mlm/presentation/bloc/mlm_network_bloc.dart';
import '../features/addons/ico_creator/data/repositories/creator_repository_impl.dart';
import '../features/addons/ico_creator/domain/repositories/creator_repository.dart';
import '../features/addons/ico_creator/presentation/bloc/creator_bloc.dart';
import '../features/addons/ico_creator/domain/usecases/launch_token_usecase.dart';
import '../features/addons/ico_creator/domain/usecases/get_launch_plans_usecase.dart';
import '../features/addons/ico_creator/presentation/bloc/launch_plan_cubit.dart';
import '../features/addons/ico_creator/domain/usecases/get_investors_usecase.dart';
import '../features/addons/ico_creator/domain/usecases/get_creator_stats_usecase.dart';
import '../features/addons/ico_creator/presentation/bloc/investors_cubit.dart';
import '../features/addons/ico_creator/presentation/bloc/stats_cubit.dart';
import '../features/addons/ico_creator/domain/usecases/get_creator_performance_usecase.dart';
import '../features/addons/ico_creator/presentation/bloc/performance_cubit.dart';

// Notification Feature
import '../features/notification/data/datasources/notification_websocket_data_source.dart';

// KYC Feature
import '../features/kyc/data/datasources/kyc_remote_datasource.dart';
import '../features/kyc/data/repositories/kyc_repository_impl.dart';
import '../features/kyc/domain/repositories/kyc_repository.dart';

// Theme Feature

// Legal Feature
import '../features/legal/data/datasources/legal_remote_datasource.dart';
import '../features/legal/data/repositories/legal_repository_impl.dart';
import '../features/legal/domain/repositories/legal_repository.dart';

// Generated config
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // If this function is called more than once (e.g. during Hot Restart) we need
  // to clear any previous registrations to avoid duplicate-registration errors.
  if (getIt.isRegistered<SharedPreferences>()) {
    // Preserve earlier singletons like SharedPreferences by disposing = false
    await getIt.reset(dispose: false);
  }
  // Initialize SharedPreferences first
  final sharedPreferences = await SharedPreferences.getInstance();

  // Register external dependencies that can't be auto-generated
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<http.Client>(http.Client());

  // Manual feature registrations for complex dependencies BEFORE auto-init
  _registerProfileFeature();

  // Initialize the auto-generated dependencies
  getIt.init();

  // Initialize ProfileService after all dependencies are registered
  _initializeProfileService();

  // Manual registrations that need to override auto-generated ones
  _registerAuthFeature();
  _registerWalletFeature();
  _registerDepositFeature();
  _registerSpotDepositFeature();
  _registerEcoDepositFeature();
  _registerFuturesDepositFeature();
  _registerFuturesFeature();
  _registerNotificationFeature();
  _registerTransferFeature();
  _registerChartFeature();
  _registerTradeFeature();
  _registerStakingFeature();
  _registerBlogFeature();
  _registerEcommerceFeature();
  _registerP2PFeature();
  _registerSupportFeature();
  _registerIcoFeature();
  _registerCreatorFeature();
  _registerKycFeature();
  _registerThemeFeature();
  _registerNewsFeature();
  _registerMlmFeature();
  _registerLegalFeature();
}

void _initializeProfileService() {
  // Initialize ProfileService with BlogAuthorService after auto-injection is complete
  try {
    final profileBloc = getIt<ProfileBloc>();
    final blogAuthorService = getIt<BlogAuthorService>();
    getIt<ProfileService>().initialize(profileBloc, blogAuthorService);
    dev.log('🟢 INJECTION: ProfileService initialized successfully');
  } catch (e) {
    dev.log('🔴 INJECTION: Failed to initialize ProfileService: $e');
  }
}

void _registerAuthFeature() {
  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt(),
      secureStorage: getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCachedUserUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckAuthStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => ForgotPasswordUseCase(getIt()));
  getIt.registerLazySingleton(() => LoginWithGoogleUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyTwoFactorLoginUseCase(getIt()));

  // Bloc (avoid duplicate if generated) - Use lazySingleton to maintain state
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerLazySingleton(
      () => AuthBloc(
        loginUseCase: getIt(),
        loginWithGoogleUseCase: getIt(),
        registerUseCase: getIt(),
        logoutUseCase: getIt(),
        getCachedUserUseCase: getIt(),
        checkAuthStatusUseCase: getIt(),
        forgotPasswordUseCase: getIt(),
        verifyTwoFactorLoginUseCase: getIt(),
        profileService: getIt(),
      ),
    );
  }
}

void _registerWalletFeature() {
  // WalletCacheDataSource and WalletRemoteDataSource are auto-registered
  // Need to manually register wallet repository and its dependencies
  if (!getIt.isRegistered<WalletRepository>()) {
    getIt.registerLazySingleton<WalletRepository>(
      () => WalletRepositoryImpl(
        remoteDataSource: getIt(),
        cacheDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );
  }

  // Currency Price Feature - All classes are auto-registered with @injectable
  // No manual registration needed for:
  // - CurrencyPriceRemoteDataSource (auto-registered)
  // - CurrencyPriceRepository (auto-registered)
  // - GetCurrencyPriceUseCase (auto-registered)
  // - GetCurrencyWalletBalanceUseCase (auto-registered)

  // Prevent duplicate Bloc registration after hot restart
  if (getIt.isRegistered<WalletBloc>()) {
    // If the Bloc was previously registered, remove it to allow re-registration for fresh state
    getIt.unregister<WalletBloc>();
  }

  // CurrencyPriceBloc is auto-registered - don't unregister it

  // Use Cases
  getIt.registerLazySingleton<GetWalletsUseCase>(
    () => GetWalletsUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetWalletsByTypeUseCase>(
    () => GetWalletsByTypeUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetWalletUseCase>(
    () => GetWalletUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetWalletByIdUseCase>(
    () => GetWalletByIdUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetWalletPerformanceUseCase>(
    () => GetWalletPerformanceUseCase(getIt()),
  );

  // Blocs
  getIt.registerFactory<WalletBloc>(
    () => WalletBloc(
      getWalletsUseCase: getIt(),
      getWalletsByTypeUseCase: getIt(),
      getWalletUseCase: getIt(),
      getWalletByIdUseCase: getIt(),
      getWalletPerformanceUseCase: getIt(),
    ),
  );

  // CurrencyPriceBloc is auto-registered with @injectable
  // No manual registration needed
}

void _registerProfileFeature() {
  // Data sources
  getIt.registerLazySingleton<ProfileCacheManager>(
    () => ProfileCacheManager(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // Use cases - Only register non-auto-registered ones
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt()),
  );

  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt()),
  );

  getIt.registerLazySingleton<ToggleTwoFactorUseCase>(
    () => ToggleTwoFactorUseCase(getIt()),
  );

  // Two-Factor Setup Use Cases are auto-registered with @injectable
  // No manual registration needed for:
  // - GenerateTwoFactorSecretUseCase
  // - VerifyTwoFactorSetupUseCase
  // - SaveTwoFactorSetupUseCase
  // - TwoFactorSetupBloc

  // Service
  getIt.registerLazySingleton<ProfileService>(
    () => ProfileService.instance,
  );

  // Blocs - Only register non-auto-registered ones
  getIt.registerLazySingleton(
    () => ProfileBloc(
      getProfileUseCase: getIt(),
      updateProfileUseCase: getIt(),
      toggleTwoFactorUseCase: getIt(),
      cacheManager: getIt<ProfileCacheManager>(),
      profileService: getIt<ProfileService>(),
    ),
  );

  // TwoFactorSetupBloc is auto-registered with @injectable
  // No manual registration needed
}

void _registerNotificationFeature() {
  // Manual override for GlobalNotificationService to ensure proper dependency order
  if (getIt.isRegistered<GlobalNotificationService>()) {
    getIt.unregister<GlobalNotificationService>();
  }

  getIt.registerSingleton<GlobalNotificationService>(
    GlobalNotificationService(
      getIt<NotificationWebSocketDataSource>(),
      getIt<ProfileService>(),
    ),
    dispose: (service) => service.dispose(),
  );
}

void _registerDepositFeature() {
  // All deposit classes are now auto-registered by getIt.init()
  // No manual registration needed
}

void _registerSpotDepositFeature() {
  // All SPOT deposit classes are now auto-registered by getIt.init()
  // No manual registration needed
}

void _registerEcoDepositFeature() {
  // All ECO deposit classes are now auto-registered by getIt.init()
  // No manual registration needed
}

void _registerFuturesDepositFeature() {
  // All FUTURES deposit classes are now auto-registered by getIt.init()
  // No manual registration needed
}

void _registerFuturesFeature() {
  // Futures feature dependencies are now auto-registered by @injectable annotations
  // No manual registration needed
}

void _registerTransferFeature() {
  // Transfer feature dependencies are now auto-registered by @injectable annotations
  // No manual registration needed
}

void _registerChartFeature() {
  // Chart feature dependencies are now auto-registered by @injectable annotations
  // No manual registration needed
}

void _registerTradeFeature() {
  // TradingChartBloc is auto-registered with @injectable annotation
  // AiInvestmentBloc is also auto-registered with @injectable annotation
  // No manual registration needed
}

void _registerStakingFeature() {
  // StakingBloc and PositionBloc are now auto-registered with @injectable annotations
  // No manual registration needed
}

void _registerBlogFeature() {
  // Register BlogBloc if not already
  if (!getIt.isRegistered<BlogBloc>()) {
    getIt.registerFactory(() => BlogBloc(getIt()));
  }

  // Register AuthorsBloc for authors feature
  if (!getIt.isRegistered<AuthorsBloc>()) {
    getIt.registerFactory(() => AuthorsBloc(getIt()));
  }
}

void _registerEcommerceFeature() {
  // All e-commerce classes are now auto-registered by @injectable annotations
  // Manual registration for CartBloc - use lazySingleton to maintain state
  if (!getIt.isRegistered<CartBloc>()) {
    getIt.registerLazySingleton(() => CartBloc(
          getCartUseCase: getIt<GetCartUseCase>(),
          addToCartUseCase: getIt<AddToCartUseCase>(),
          updateCartItemQuantityUseCase: getIt<UpdateCartItemQuantityUseCase>(),
          removeFromCartUseCase: getIt<RemoveFromCartUseCase>(),
          clearCartUseCase: getIt<ClearCartUseCase>(),
        ));
  }

  // Manual registration for ShopBloc
  if (!getIt.isRegistered<ShopBloc>()) {
    getIt.registerFactory(() => ShopBloc(
          getIt<GetProductsUseCase>(),
          getIt<GetCategoriesUseCase>(),
        ));
  }
}

void _registerP2PFeature() {
  // P2P feature dependencies are now auto-registered by @injectable annotations
  // No manual registration needed
}

void _registerSupportFeature() {
  // Most support classes are auto-registered by @injectable annotations
  // Manual registration for LiveChatBloc to ensure proper dependency injection
  if (!getIt.isRegistered<LiveChatBloc>()) {
    getIt.registerFactory(() => LiveChatBloc(getIt(), getIt<AuthBloc>()));
  }

  // Register TicketDetailBloc for normal ticket conversations
  if (!getIt.isRegistered<TicketDetailBloc>()) {
    getIt.registerFactory(() => TicketDetailBloc(getIt()));
  }
}

void _registerIcoFeature() {
  // ICO feature now uses real API integration
  // All ICO classes are auto-registered by @injectable annotations
  // No manual registration needed for auto-registered classes
}

void _registerCreatorFeature() {
  // Ensure single registration
  if (!getIt.isRegistered<CreatorRemoteDataSource>()) {
    getIt.registerLazySingleton<CreatorRemoteDataSource>(
        () => CreatorRemoteDataSourceImpl(getIt()));
  }

  if (!getIt.isRegistered<CreatorRepository>()) {
    getIt.registerLazySingleton<CreatorRepository>(
        () => CreatorRepositoryImpl(getIt(), getIt()));
  }

  if (!getIt.isRegistered<LaunchTokenUseCase>()) {
    getIt.registerLazySingleton<LaunchTokenUseCase>(
        () => LaunchTokenUseCase(getIt()));
  }

  if (getIt.isRegistered<CreatorBloc>()) {
    getIt.unregister<CreatorBloc>();
  }

  getIt.registerFactory(() => CreatorBloc(getIt(), getIt()));

  if (!getIt.isRegistered<GetLaunchPlansUseCase>()) {
    getIt.registerLazySingleton<GetLaunchPlansUseCase>(
        () => GetLaunchPlansUseCase(getIt()));
  }

  if (!getIt.isRegistered<LaunchPlanCubit>()) {
    getIt.registerFactory(() => LaunchPlanCubit(getIt()));
  }

  if (!getIt.isRegistered<GetInvestorsUseCase>()) {
    getIt.registerLazySingleton<GetInvestorsUseCase>(
        () => GetInvestorsUseCase(getIt()));
  }

  if (!getIt.isRegistered<GetCreatorStatsUseCase>()) {
    getIt.registerLazySingleton<GetCreatorStatsUseCase>(
        () => GetCreatorStatsUseCase(getIt()));
  }

  if (!getIt.isRegistered<InvestorsCubit>()) {
    getIt.registerFactory(() => InvestorsCubit(getIt()));
  }

  if (!getIt.isRegistered<StatsCubit>()) {
    getIt.registerFactory(() => StatsCubit(getIt()));
  }

  if (!getIt.isRegistered<GetCreatorPerformanceUseCase>()) {
    getIt.registerLazySingleton(() => GetCreatorPerformanceUseCase(getIt()));
  }

  if (!getIt.isRegistered<PerformanceCubit>()) {
    getIt.registerFactory(() => PerformanceCubit(getIt()));
  }
}

void _registerKycFeature() {
  // Manual registration for KYC dependencies to ensure proper injection order
  if (!getIt.isRegistered<KycRemoteDataSource>()) {
    getIt.registerLazySingleton<KycRemoteDataSource>(
      () => KycRemoteDataSourceImpl(getIt<DioClient>()),
    );
  }

  if (!getIt.isRegistered<KycRepository>()) {
    getIt.registerLazySingleton<KycRepository>(
      () => KycRepositoryImpl(getIt<KycRemoteDataSource>()),
    );
  }

  // Use cases are auto-registered via @injectable
  // Bloc is auto-registered via @injectable
}

void _registerThemeFeature() {
  // Theme feature dependencies are auto-registered by @injectable annotations
  // No manual registration needed - ThemeBloc, Use Cases, Repository, and DataSource are all auto-injected
}

void _registerNewsFeature() {
  // News feature dependencies are auto-registered by @injectable annotations
  // No manual registration needed for:
  // - NewsRemoteDataSource
  // - NewsLocalDataSource
  // - NewsRepository
  // - News use cases
  // - NewsBloc
}

void _registerMlmFeature() {
  // MLM/Affiliate feature dependencies are now auto-registered by @injectable annotations
  // Manual override for MlmRewardsBloc to ensure proper dependency injection
  if (getIt.isRegistered<MlmRewardsBloc>()) {
    getIt.unregister<MlmRewardsBloc>();
  }

  getIt.registerFactory(
    () => MlmRewardsBloc(
      getIt<GetMlmRewardsUseCase>(),
      getIt<ClaimMlmRewardUseCase>(),
      getIt<MlmRepository>(),
    ),
  );

  // Manual registration for MlmNetworkBloc
  if (getIt.isRegistered<MlmNetworkBloc>()) {
    getIt.unregister<MlmNetworkBloc>();
  }

  getIt.registerFactory(
    () => MlmNetworkBloc(
      getIt<GetMlmNetworkUseCase>(),
    ),
  );
}

void _registerLegalFeature() {
  // Legal feature dependencies - manual registration
  if (!getIt.isRegistered<LegalRemoteDataSource>()) {
    getIt.registerLazySingleton<LegalRemoteDataSource>(
      () => LegalRemoteDataSourceImpl(getIt<DioClient>()),
    );
  }

  if (!getIt.isRegistered<LegalRepository>()) {
    getIt.registerLazySingleton<LegalRepository>(
      () => LegalRepositoryImpl(getIt<LegalRemoteDataSource>()),
    );
  }
}
