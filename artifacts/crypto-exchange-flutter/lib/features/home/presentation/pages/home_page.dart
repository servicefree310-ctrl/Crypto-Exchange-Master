import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../widgets/trading_tab.dart';
import '../widgets/wallet_tab.dart';
import '../widgets/market_tab.dart';
import '../widgets/future_tab.dart';
import '../../../../core/constants/api_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialTabIndex = 0,
    this.initialTabKey,
    this.tradingSymbol,
    this.tradingMarketData,
    this.tradingInitialAction,
  });

  final int initialTabIndex;
  final String? initialTabKey;
  final String? tradingSymbol;
  final dynamic tradingMarketData;
  final String? tradingInitialAction;

  // Static method to navigate to specific tab
  static void navigateToTab(BuildContext context, String tabKey) {
    final homePageState = context.findAncestorStateOfType<_HomePageState>();
    if (homePageState != null) {
      homePageState._navigateToTab(tabKey);
    }
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  late List<Widget> _tabs;
  late List<_TabData> _tabData;
  bool _initialTabSet = false; // Add flag to track initial tab setting

  @override
  void initState() {
    super.initState();
    // Don't set _currentIndex here, will set it in build based on visible tabs
    _currentIndex = 0; // temporary default
    _initializeTabs();
  }

  void _initializeTabs() {
    // Define all possible tabs with their data
    _tabData = [
      _TabData(
        key: 'dashboard',
        widget: const DashboardPage(),
        iconPath: 'assets/icons/nav_home.svg',
        activeIconPath: 'assets/icons/nav_home_filled.svg',
        label: 'Home',
        gradient: [const Color(0xFF00D4AA), const Color(0xFF00A085)],
        isAlwaysVisible: true,
      ),
      _TabData(
        key: 'market',
        widget: const MarketTab(),
        iconPath: 'assets/icons/nav_market.svg',
        activeIconPath: 'assets/icons/nav_market_filled.svg',
        label: 'Market',
        gradient: [const Color(0xFF6C5CE7), const Color(0xFF5B4BD1)],
        isAlwaysVisible: true,
      ),
      _TabData(
        key: 'trade',
        widget: TradingTab(
          symbol: widget.tradingSymbol,
          marketData: widget.tradingMarketData,
          initialAction: widget.tradingInitialAction,
        ),
        iconPath: 'assets/icons/nav_trade.svg',
        activeIconPath: 'assets/icons/nav_trade_filled.svg',
        label: 'Trade',
        gradient: [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
        isAlwaysVisible: true,
      ),
      _TabData(
        key: 'futures',
        widget: const FutureTab(),
        iconPath: 'assets/icons/nav_future.svg',
        activeIconPath: 'assets/icons/nav_future_filled.svg',
        label: 'Futures',
        gradient: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
        isAlwaysVisible: false, // Will be controlled by settings
        featureKey: 'futures',
      ),
      _TabData(
        key: 'wallet',
        widget: const WalletTab(),
        iconPath: 'assets/icons/nav_wallet.svg',
        activeIconPath: 'assets/icons/nav_wallet_filled.svg',
        label: 'Wallet',
        gradient: [const Color(0xFFE67E22), const Color(0xFFD35400)],
        isAlwaysVisible: true,
      ),
    ];

    // Initially show all tabs, will be filtered by settings
    _tabs = _tabData.map((tab) => tab.widget).toList();
  }

  List<_TabData> _getVisibleTabs(SettingsState settingsState) {
    final visibleTabs = <_TabData>[];

    for (final tab in _tabData) {
      if (tab.isAlwaysVisible) {
        visibleTabs.add(tab);
      } else if (tab.featureKey != null) {
        // Check if feature is available or coming soon
        final isAvailable = _isFeatureAvailable(settingsState, tab.featureKey!);
        final isComingSoon =
            _isFeatureComingSoon(settingsState, tab.featureKey!);

        if (isAvailable || isComingSoon) {
          visibleTabs.add(tab);
        }
      }
    }

    return visibleTabs;
  }

  bool _isFeatureAvailable(SettingsState settingsState, String featureKey) {
    if (settingsState is SettingsLoaded || settingsState is SettingsUpdated) {
      final settings = (settingsState as dynamic).settings;
      return settings?.isFeatureAvailable(featureKey) ?? false;
    }
    return false;
  }

  bool _isFeatureComingSoon(SettingsState settingsState, String featureKey) {
    if (settingsState is SettingsLoaded || settingsState is SettingsUpdated) {
      final settings = (settingsState as dynamic).settings;
      final comingSoonFeatures = settings?.comingSoonFeatures ?? [];
      return AppConstants.defaultShowComingSoon &&
          comingSoonFeatures.contains(featureKey);
    }
    return false;
  }

  int _getAdjustedIndex(int originalIndex) {
    // Convert original index to visible tab index
    final visibleTabs = _getVisibleTabs(context.read<SettingsBloc>().state);
    final originalTab = _tabData[originalIndex];

    for (int i = 0; i < visibleTabs.length; i++) {
      if (visibleTabs[i].key == originalTab.key) {
        return i;
      }
    }

    // If tab not found, return 0 (dashboard)
    return 0;
  }

  int _getOriginalIndex(int visibleIndex) {
    // Convert visible tab index back to original index
    final visibleTabs = _getVisibleTabs(context.read<SettingsBloc>().state);
    if (visibleIndex < visibleTabs.length) {
      final visibleTab = visibleTabs[visibleIndex];
      for (int i = 0; i < _tabData.length; i++) {
        if (_tabData[i].key == visibleTab.key) {
          return i;
        }
      }
    }
    return 0;
  }

  void _navigateToTab(String tabKey) {
    final visibleTabs = _getVisibleTabs(context.read<SettingsBloc>().state);
    for (int i = 0; i < visibleTabs.length; i++) {
      if (visibleTabs[i].key == tabKey) {
        setState(() => _currentIndex = i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProfileBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Handle loading state
          if (settingsState is SettingsLoading ||
              settingsState is SettingsInitial) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Get visible tabs based on settings
          final visibleTabs = _getVisibleTabs(settingsState);
          final visibleTabWidgets =
              visibleTabs.map((tab) => tab.widget).toList();

          // Safety check: ensure we have at least one tab
          if (visibleTabWidgets.isEmpty) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(
                child: Text('No tabs available'),
              ),
            );
          }

          // On first build, set the initial tab
          if (!_initialTabSet) {
            _initialTabSet = true;

            // First try to use the tab key if provided
            if (widget.initialTabKey != null) {
              for (int i = 0; i < visibleTabs.length; i++) {
                if (visibleTabs[i].key == widget.initialTabKey) {
                  _currentIndex = i;
                  break;
                }
              }
            } else if (widget.initialTabIndex > 0 &&
                widget.initialTabIndex < _tabData.length) {
              // Fall back to index-based approach
              final requestedTab = _tabData[widget.initialTabIndex];
              for (int i = 0; i < visibleTabs.length; i++) {
                if (visibleTabs[i].key == requestedTab.key) {
                  _currentIndex = i;
                  break;
                }
              }
            }
          }

          // Safety check: ensure current index is valid
          if (_currentIndex >= visibleTabWidgets.length) {
            _currentIndex = 0;
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: visibleTabWidgets[_currentIndex],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              tabData: visibleTabs,
            ),
          );
        },
      ),
    );
  }
}

class _TabData {
  final String key;
  final Widget widget;
  final String iconPath;
  final String activeIconPath;
  final String label;
  final List<Color> gradient;
  final bool isAlwaysVisible;
  final String? featureKey;

  _TabData({
    required this.key,
    required this.widget,
    required this.iconPath,
    required this.activeIconPath,
    required this.label,
    required this.gradient,
    required this.isAlwaysVisible,
    this.featureKey,
  });
}
