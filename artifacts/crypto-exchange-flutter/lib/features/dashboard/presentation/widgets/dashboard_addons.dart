import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import 'package:mobile/features/addons/staking/presentation/pages/staking_page.dart';
import 'package:mobile/features/addons/blog/presentation/pages/blog_list_page.dart';
import 'package:mobile/features/addons/blog/presentation/bloc/blog_bloc.dart';
import 'package:mobile/features/addons/ecommerce/presentation/pages/shop_page.dart';
import 'package:mobile/features/addons/ico/presentation/pages/ico_simple_page.dart';
import 'package:mobile/features/addons/p2p/presentation/pages/p2p_home_page.dart';
import 'package:mobile/features/addons/mlm/presentation/pages/mlm_dashboard_page.dart';
import 'package:mobile/features/instruments/presentation/pages/instruments_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'smart_addon_card.dart';

class DashboardAddons extends StatefulWidget {
  const DashboardAddons({super.key});

  @override
  State<DashboardAddons> createState() => _DashboardAddonsState();
}

class _DashboardAddonsState extends State<DashboardAddons> {
  late SettingsBloc _settingsBloc;
  @override
  void initState() {
    super.initState();
    _settingsBloc = getIt<SettingsBloc>();
    // Load settings when widget initializes
    _settingsBloc.add(const SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // Get settings to check feature availability
          final settings = state is SettingsLoaded || state is SettingsUpdated
              ? (state as dynamic).settings
              : null;

          // Filter addons based on availability and constant preference
          final filteredAddons = _getFilteredAddonsList(settings);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trading Tools',
                    style: context.h5.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isSmallScreen ? 6.0 : 8.0,
                      vertical: context.isSmallScreen ? 2.0 : 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'PRO',
                      style: context.labelS.copyWith(
                        color: context.colors.primary,
                        fontSize: context.isSmallScreen ? 9.0 : 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
              SizedBox(
                height: context.isSmallScreen ? 100.0 : 110.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredAddons.length,
                  itemBuilder: (context, index) {
                    final addon = filteredAddons[index];
                    return Container(
                      width: context.isSmallScreen ? 80.0 : 90.0,
                      margin: EdgeInsets.only(
                        right: index != filteredAddons.length - 1
                            ? (context.isSmallScreen ? 8.0 : 10.0)
                            : 0,
                      ),
                      child: SmartAddonCard(
                        title: addon.title,
                        icon: addon.icon,
                        color: addon.color,
                        description: addon.description,
                        badge: addon.badge,
                        onTap: () => _handleAddonTap(context, addon.icon),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_AddonData> _getFilteredAddonsList(dynamic settings) {
    final allAddons = _getAddonsList();
    final filteredAddons = <_AddonData>[];

    for (final addon in allAddons) {
      if (settings == null) {
        // If settings are not loaded yet, show all features as coming soon if constant is true
        if (AppConstants.defaultShowComingSoon) {
          filteredAddons.add(addon);
        }
      } else {
        // Settings are loaded, check availability and coming soon status
        final isAvailable = settings.isFeatureAvailable(addon.icon);
        final isComingSoon = AppConstants.defaultShowComingSoon &&
            settings.comingSoonFeatures.contains(addon.icon);

        // Include if available or coming soon
        if (isAvailable || isComingSoon) {
          filteredAddons.add(addon);
        }
      }
    }

    return filteredAddons;
  }

  List<_AddonData> _getAddonsList() {
    return [
      _AddonData('Forex', 'forex', const Color(0xFF2196F3), 'Currency pairs', 'CFD'),
      _AddonData('Stocks', 'stocks', const Color(0xFF4CAF50), 'NSE · NASDAQ', 'Live'),
      _AddonData('Commodities', 'commodities', const Color(0xFFFFB300), 'Gold · MCX', 'MCX'),
      _AddonData('P2P Trading', 'p2p', context.priceUpColor, 'Trade with peers', '24/7'),
      _AddonData('Futures', 'futures', context.colors.primary, 'Leverage trading', 'x125'),
      _AddonData('Staking', 'staking', context.colors.tertiary, 'Earn rewards', '12% APY'),
      _AddonData('Launchpad', 'ico', context.warningColor, 'New projects', 'Early'),
      _AddonData('News & Analysis', 'blog', context.colors.secondary, 'Market insights', 'Live'),
      _AddonData('E-commerce', 'ecommerce', context.colors.tertiary, 'Shop crypto', 'Store'),
      _AddonData('MLM', 'mlm', context.priceDownColor, 'Multi-level marketing', 'Network'),
      _AddonData('Mail Wizard', 'mailwizard', context.textSecondary, 'Email automation', 'Pro'),
    ];
  }

  void _handleAddonTap(BuildContext context, String icon) {
    switch (icon) {
      case 'forex':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const InstrumentsPage(category: 'forex'),
          ),
        );
        break;
      case 'stocks':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const InstrumentsPage(category: 'stocks'),
          ),
        );
        break;
      case 'commodities':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const InstrumentsPage(category: 'commodities'),
          ),
        );
        break;
      case 'p2p':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const P2PHomePage()),
        );
        break;
      case 'staking':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StakingPage()),
        );
        break;
      case 'blog':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => BlogBloc(getIt()),
                ),
                BlocProvider.value(
                  value: context.read<AuthBloc>(),
                ),
              ],
              child: const BlogListPage(),
            ),
          ),
        );
        break;
      case 'ecommerce':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ShopPage(),
          ),
        );
        break;
      case 'ico':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IcoSimplePage()),
        );
        break;
      case 'mlm':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MlmDashboardPage(),
          ),
        );
        break;
      case 'mailwizard':
        // TODO: Implement Mail Wizard page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mail Wizard feature coming soon'),
            duration: const Duration(seconds: 1),
            backgroundColor: context.warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
      case 'futures':
        // Navigate to futures tab in main navbar
        HomePage.navigateToTab(context, 'futures');
        break;
      default:
        // For features that are not yet implemented
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${icon.toUpperCase()} feature'),
            duration: const Duration(seconds: 1),
            backgroundColor: context.warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _AddonData {
  final String title;
  final String icon;
  final Color color;
  final String description;
  final String badge;

  _AddonData(
    this.title,
    this.icon,
    this.color,
    this.description,
    this.badge,
  );
}
