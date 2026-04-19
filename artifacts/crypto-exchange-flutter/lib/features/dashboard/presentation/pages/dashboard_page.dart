import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_addons.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_market_stats.dart';
import '../widgets/dashboard_trading_pairs.dart';
import '../widgets/announcements_slider.dart';
import '../../../news/presentation/widgets/news_gateway_card.dart';
import '../../../news/presentation/pages/news_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const _DashboardPageView(),
    );
  }
}

class _DashboardPageView extends StatelessWidget {
  const _DashboardPageView();

  @override
  Widget build(BuildContext context) {
    final profileService = getIt<ProfileService>();

    return SafeArea(
      child: StreamBuilder<ProfileEntity?>(
        stream: profileService.profileStream,
        builder: (context, profileSnapshot) {
          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, dashboardState) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.isSmallScreen ? 16.0 : 20.0,
                          8.0,
                          context.isSmallScreen ? 16.0 : 20.0,
                          0.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DashboardHeader(),
                            SizedBox(
                                height: context.isSmallScreen ? 10.0 : 12.0),
                            if (dashboardState is DashboardLoaded) ...[
                              AnnouncementsSlider(
                                  announcements: dashboardState.announcements),
                              SizedBox(
                                  height: context.isSmallScreen ? 10.0 : 12.0),
                              DashboardMarketStats(),
                              SizedBox(
                                  height: context.isSmallScreen ? 10.0 : 12.0),
                              const DashboardAddons(),
                              SizedBox(
                                  height: context.isSmallScreen ? 10.0 : 12.0),
                              const DashboardTradingPairs(),
                              SizedBox(
                                  height: context.isSmallScreen ? 10.0 : 12.0),
                              _buildNewsGateway(context),
                            ] else if (dashboardState is DashboardLoading) ...[
                              _buildLoadingWidgets(context),
                            ] else if (dashboardState is DashboardError) ...[
                              _buildErrorWidget(
                                  context, dashboardState.message),
                            ],
                            SizedBox(
                                height: context.isSmallScreen ? 16.0 : 20.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsGateway(BuildContext context) {
    return NewsGatewayCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewsPage(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidgets(BuildContext context) {
    return Column(
      children: [
        // Loading announcements
        Container(
          height: context.isSmallScreen ? 100.0 : 120.0,
          margin: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 16.0 : 20.0,
          ),
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 10.0 : 12.0),
        // Loading market stats
        Container(
          height: context.isSmallScreen ? 100.0 : 120.0,
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 10.0 : 12.0),
        // Loading addons
        Container(
          height: context.isSmallScreen ? 100.0 : 120.0,
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 10.0 : 12.0),
        // Loading trading pairs
        Container(
          height: context.isSmallScreen ? 100.0 : 120.0,
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 10.0 : 12.0),
        // Loading news gateway (moved to last)
        Container(
          height: context.isSmallScreen ? 120.0 : 140.0,
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius:
                BorderRadius.circular(context.isSmallScreen ? 14.0 : 16.0),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: context.priceDownColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: context.priceDownColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: context.priceDownColor,
            size: 32.0,
          ),
          SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
          Text(
            'Error Loading Dashboard',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 4.0 : 8.0),
          Text(
            message,
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
