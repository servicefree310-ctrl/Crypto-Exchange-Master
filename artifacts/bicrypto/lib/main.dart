import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:developer' as dev;

import 'injection/injection.dart';
import 'core/config/app_config.dart';
import 'core/constants/api_constants.dart';
import 'core/services/stripe_service.dart';
import 'core/services/websocket_service.dart';
import 'core/services/market_service.dart';
import 'core/services/maintenance_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/global_theme_extensions.dart';
import 'core/widgets/app_logo.dart';
import 'core/utils/orientation_helper.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'features/theme/presentation/bloc/theme_event.dart';
import 'features/theme/presentation/bloc/theme_state.dart';
import 'features/theme/domain/entities/app_theme_entity.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/data/services/profile_service.dart';
import 'features/settings/presentation/widgets/settings_provider.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/addons/ecommerce/presentation/bloc/cart/cart_bloc.dart';
import 'features/addons/ecommerce/presentation/bloc/wishlist/wishlist_bloc.dart';
import 'core/widgets/maintenance_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 GLOBAL ORIENTATION LOCK: Force portrait mode for the entire app
  // Only the fullscreen chart page will manually override this to landscape
  dev.log('🔒 MAIN: Setting global portrait orientation lock');
  await OrientationHelper.lockPortrait();
  dev.log('✅ MAIN: Portrait orientation lock applied globally');

  // Initialize app configuration first
  dev.log('🚀 MAIN: Loading app configuration');
  try {
    await AppConfig.initialize();
    dev.log('✅ MAIN: App configuration loaded successfully');
  } catch (e) {
    dev.log('❌ MAIN: Failed to load app configuration: $e');
    // Show error to user
    runApp(ConfigurationErrorApp(error: e.toString()));
    return;
  }

  dev.log('🚀 MAIN: Initializing dependencies');
  await configureDependencies();

  dev.log('🚀 MAIN: Initializing Stripe');
  final stripeService = getIt<StripeService>();
  try {
    await stripeService.initialize();
  } on SocketException catch (e) {
    debugPrint('⚠️ Stripe initialization failed (offline): $e');
  } catch (e) {
    debugPrint('⚠️ Stripe initialization error: $e');
  }

  dev.log('🚀 MAIN: Initializing global WebSocket and Market services');
  // Initialize global WebSocket service
  final webSocketService = getIt<WebSocketService>();
  try {
    await webSocketService.initializeGlobal();
  } on SocketException catch (e) {
    debugPrint('⚠️ WebSocket init failed (offline): $e');
  } catch (e) {
    debugPrint('⚠️ WebSocket init error: $e');
  }

  // Initialize global Market service
  final marketService = getIt<MarketService>();
  final maintenanceService = getIt<MaintenanceService>();
  try {
    await marketService.initialize();
  } on SocketException catch (e) {
    debugPrint('⚠️ MarketService init failed (offline): $e');
    maintenanceService.setMaintenanceMode(
        true, 'Unable to connect to server. Using offline mode.');
  } catch (e) {
    debugPrint('⚠️ MarketService init error: $e');
    maintenanceService.handleServiceError(e, 'MarketService');
  }

  dev.log('🚀 MAIN: Running app');
  runApp(const CryptoTradingApp());
}

class ConfigurationErrorApp extends StatelessWidget {
  final String error;

  const ConfigurationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Configuration Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load app configuration',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Please ensure assets/config/app_config.json exists and is properly configured.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('🚀 MAIN: Building CryptoTradingApp');

    return BlocProvider<ThemeBloc>(
      create: (context) => getIt<ThemeBloc>()..add(const ThemeLoadRequested()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Determine which theme to use
          ThemeData currentTheme = AppThemes.darkTheme; // Default

          if (themeState is ThemeLoaded) {
            final selectedTheme = themeState.currentTheme;
            final systemTheme = themeState.systemTheme;

            switch (selectedTheme) {
              case AppThemeType.light:
                currentTheme = AppThemes.lightTheme;
                break;
              case AppThemeType.dark:
                currentTheme = AppThemes.darkTheme;
                break;
              case AppThemeType.system:
                // Use system theme
                currentTheme = systemTheme == AppThemeType.dark
                    ? AppThemes.darkTheme
                    : AppThemes.lightTheme;
                break;
            }
          }

          return MaterialApp(
            title: AppConstants.appName,
            theme: currentTheme,
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeInOut,
            debugShowCheckedModeBanner: false,
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) {
                    dev.log(
                        '🚀 MAIN: Creating AuthBloc and checking authentication status');
                    final authBloc = getIt<AuthBloc>();
                    authBloc.add(AuthCheckRequested());
                    return authBloc;
                  },
                ),
                BlocProvider(
                  create: (context) {
                    dev.log('🚀 MAIN: Creating ProfileBloc');
                    final profileBloc = getIt<ProfileBloc>();

                    dev.log(
                        '🚀 MAIN: Initializing ProfileService with ProfileBloc');
                    // Initialize ProfileService with the ProfileBloc
                    final profileService = getIt<ProfileService>();
                    profileService.initialize(profileBloc);
                    dev.log('🚀 MAIN: ProfileService initialization completed');

                    return profileBloc;
                  },
                ),
                BlocProvider(
                  create: (context) {
                    dev.log('🚀 MAIN: Creating CartBloc');
                    return getIt<CartBloc>();
                  },
                ),
                BlocProvider(
                  create: (context) {
                    dev.log('🚀 MAIN: Creating WishlistBloc');
                    return getIt<WishlistBloc>();
                  },
                ),
              ],
              child: const AuthWrapper(),
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialAuthCheck = true;

  @override
  Widget build(BuildContext context) {
    dev.log('🚀 MAIN: Building AuthWrapper');

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        dev.log(
            '🚀 MAIN: BlocListener listenWhen - Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
        // Only listen to unauthenticated state for logout cleanup
        // AuthError is handled by LoginPage itself to avoid navigation issues
        return current is AuthUnauthenticated;
      },
      listener: (context, state) {
        dev.log('🚀 MAIN: AuthWrapper received state: ${state.runtimeType}');

        if (state is AuthUnauthenticated) {
          dev.log('🚀 MAIN: User unauthenticated, performing complete cleanup');

          // Perform comprehensive cleanup
          _performLogoutCleanup(context);

          dev.log('🟢 MAIN: Cleanup completed, ready for login');

          // Force a rebuild after cleanup
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dev.log('🚀 MAIN: Forcing rebuild after cleanup');
            // Trigger a rebuild by accessing the bloc again
            if (context.mounted) {
              context.read<AuthBloc>();
            }
          });
        }
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, profileState) {
          // This listener ensures profile auto-fetch happens after ProfileBloc is ready
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated &&
              profileState is ProfileInitial) {
            dev.log('🚀 MAIN: ProfileBloc ready, auto-fetching profile');
            final profileService = getIt<ProfileService>();
            profileService.autoFetchProfile();
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            dev.log(
                '🚀 MAIN: BlocBuilder buildWhen - Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
            return true; // Always rebuild to track state properly
          },
          builder: (context, state) {
            dev.log('🚀 MAIN: AuthWrapper state: ${state.runtimeType}');

            // Track if we've completed initial auth check
            if (state is! AuthLoading && _isInitialAuthCheck) {
              _isInitialAuthCheck = false;
              dev.log('🟢 MAIN: Initial auth check completed');
            }

            // Show full-screen loading ONLY for initial auth check
            if (state is AuthLoading && _isInitialAuthCheck) {
              dev.log('🚀 MAIN: Showing loading screen for initial auth check');
              return Scaffold(
                backgroundColor: context.colors.surface,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedAppLogo(
                        fontSize: 36,
                        showIcon: false,
                        style: LogoStyle.elegant,
                      ),
                      const SizedBox(height: 32),
                      CircularProgressIndicator(
                        color: context.colors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getLoadingMessage(state),
                        style: context.bodyM.copyWith(
                          color: context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              dev.log(
                  '🚀 MAIN: User authenticated, showing home page with settings check');

              // Trigger profile auto-fetch after the widget tree is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dev.log(
                    '🚀 MAIN: Post-frame callback - triggering profile auto-fetch');
                final profileService = getIt<ProfileService>();
                profileService.autoFetchProfile();
              });

              return const SettingsProvider(
                child: SettingsLoadingWrapper(),
              );
            } else {
              // Handle all other states (AuthUnauthenticated, AuthError, AuthInitial, etc.)
              // Show login page and let it handle error states internally
              if (state is AuthError) {
                dev.log('🔴 MAIN: Auth error state - LoginPage will handle error display');
              } else if (state is AuthUnauthenticated) {
                dev.log('🚀 MAIN: User unauthenticated, showing login page');
              } else {
                dev.log('🚀 MAIN: Showing login page for state: ${state.runtimeType}');
              }
              return const MaintenanceAwareScaffold(child: LoginPage());
            }
          },
        ),
      ),
    );
  }

  String _getLoadingMessage(AuthState state) {
    // You can enhance this to show different messages based on context
    // For now, we'll show a generic message
    return 'Please wait...';
  }

  void _performLogoutCleanup(BuildContext context) {
    dev.log('🔵 MAIN: Starting comprehensive logout cleanup');

    try {
      // Clear profile service data
      final profileService = getIt<ProfileService>();
      profileService.clearCache();
      profileService.reset();
      dev.log('🟢 MAIN: ProfileService cleaned up');

      // Clear any existing snackbars or dialogs
      ScaffoldMessenger.of(context).clearSnackBars();
      dev.log('🟢 MAIN: UI state cleared');

      // Clear navigation stack by popping all routes except root
      Navigator.of(context).popUntil((route) => route.isFirst);
      dev.log('🟢 MAIN: Navigation stack cleared');

      // Force system UI reset using theme colors
      final isDark = context.isDarkMode;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor:
              isDark ? context.colors.surface : context.colors.surface,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      );
      dev.log('🟢 MAIN: System UI reset');

      // Additional cleanup can be added here for other services
      dev.log('🟢 MAIN: Additional service cleanup completed');

      // Force garbage collection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dev.log('🔵 MAIN: Triggering garbage collection');
      });
    } catch (e) {
      dev.log('🔴 MAIN: Error during logout cleanup: $e');
    }
  }
}

class SettingsLoadingWrapper extends StatelessWidget {
  const SettingsLoadingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        // Show loading state until settings are loaded
        if (state is SettingsLoading || state is SettingsInitial) {
          return Scaffold(
            backgroundColor: context.colors.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo.textOnly(
                    fontSize: 32,
                    style: LogoStyle.elegant,
                  ),
                  const SizedBox(height: 32),
                  CircularProgressIndicator(
                    color: context.colors.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Please wait...',
                    style: context.bodyM.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Settings loaded successfully, show the HomePage
        return const MaintenanceAwareScaffold(child: HomePage());
      },
    );
  }
}

/// Wrapper widget that shows maintenance banner when needed
class MaintenanceAwareScaffold extends StatelessWidget {
  const MaintenanceAwareScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maintenanceService = getIt<MaintenanceService>();

    return StreamBuilder<bool>(
      stream: maintenanceService.maintenanceStream,
      initialData: maintenanceService.isInMaintenance,
      builder: (context, snapshot) {
        final isInMaintenance = snapshot.data ?? false;

        if (isInMaintenance) {
          return Scaffold(
            backgroundColor: context.colors.surface,
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: MaintenanceBanner(
                    message: maintenanceService.maintenanceMessage,
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        return child;
      },
    );
  }
}
