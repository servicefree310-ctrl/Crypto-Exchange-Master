import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/injection/injection.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import '../bloc/staking_bloc.dart';
import '../bloc/staking_event.dart';
import '../bloc/staking_state.dart';
import '../bloc/position_bloc.dart';
import '../bloc/position_event.dart';
import '../bloc/position_state.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';
import '../widgets/mobile_pool_card.dart';
import '../widgets/mobile_position_card.dart';
import '../widgets/mobile_stats_card.dart';
import '../widgets/staking_header.dart';
import 'pool_detail_page.dart';

class StakingPage extends StatefulWidget {
  const StakingPage({super.key});

  @override
  State<StakingPage> createState() => _StakingPageState();
}

class _StakingPageState extends State<StakingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final StakingBloc _stakingBloc;
  late final PositionBloc _positionBloc;
  late final StatsBloc _statsBloc;

  void _refreshAll({bool force = false}) {
    _stakingBloc.add(LoadStakingData(forceRefresh: force));
    _positionBloc.add(LoadUserPositions(forceRefresh: force));
    _statsBloc.add(LoadStakingStats(forceRefresh: force));
  }

  void _refreshPositions({bool force = false}) {
    _positionBloc.add(LoadUserPositions(forceRefresh: force));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Get BLoC instances from DI
    _stakingBloc = getIt<StakingBloc>();
    _positionBloc = getIt<PositionBloc>();
    _statsBloc = getIt<StatsBloc>();

    // Load initial data if not already loaded
    if (_stakingBloc.state is! StakingLoaded) {
      _stakingBloc.add(const LoadStakingData());
    }
    if (_positionBloc.state is! PositionLoaded) {
      _positionBloc.add(const LoadUserPositions());
    }
    if (_statsBloc.state is! StatsLoaded) {
      _statsBloc.add(const LoadStakingStats());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StatsBloc>.value(value: _statsBloc),
        BlocProvider<StakingBloc>.value(value: _stakingBloc),
        BlocProvider<PositionBloc>.value(value: _positionBloc),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              const StakingHeader(),

              // Stats Overview
              BlocBuilder<StatsBloc, StatsState>(
                bloc: _statsBloc,
                builder: (context, state) {
                  if (state is StatsLoaded) {
                    return MobileStatsCard(stats: state.stats);
                  }
                  return const SizedBox(height: 100); // Placeholder height
                },
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.colors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: context.textSecondary,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'My Stakes'),
                    Tab(text: 'All Pools'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview Tab
                    _buildOverviewTab(),

                    // My Stakes Tab
                    _buildMyStakesTab(),

                    // All Pools Tab
                    _buildAllPoolsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return BlocBuilder<StakingBloc, StakingState>(
      bloc: _stakingBloc,
      builder: (context, state) {
        if (state is StakingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StakingLoaded) {
          final promotedPools = state.pools.where((p) => p.isPromoted).toList();
          final activePools =
              state.pools.where((p) => p.status == 'ACTIVE').toList();

          return RefreshIndicator(
            onRefresh: () async {
              _refreshAll(force: true);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Quick Actions',
                  style: context.h6,
                ),
                const SizedBox(height: 12),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Stake Now',
                        subtitle: 'Earn rewards',
                        onTap: () => _tabController.animateTo(2),
                        gradient: LinearGradient(
                          colors: [
                            context.colors.primary,
                            context.colors.primary.withValues(alpha: 0.7)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.trending_up,
                        title: 'Best APR',
                        subtitle:
                            '${activePools.isNotEmpty ? activePools.first.apr.toStringAsFixed(1) : '0'}%',
                        onTap: () {
                          if (activePools.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider<StakingBloc>.value(
                                  value: _stakingBloc,
                                  child: PoolDetailPage(
                                    poolId: activePools.first.id,
                                  ),
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _refreshAll(force: true);
                              }
                            });
                          }
                        },
                        gradient: LinearGradient(
                          colors: [
                            context.priceUpColor,
                            context.priceUpColor.withValues(alpha: 0.7)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Featured Pools
                if (promotedPools.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Pools',
                        style: context.h5,
                      ),
                      TextButton(
                        onPressed: () => _tabController.animateTo(2),
                        child: Text(
                          'See All',
                          style: context.labelM
                              .copyWith(color: context.colors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...promotedPools.take(3).map((pool) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MobilePoolCard(
                          pool: pool,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider<StakingBloc>.value(
                                value: _stakingBloc,
                                child: PoolDetailPage(poolId: pool.id),
                              ),
                            ),
                          ).then((result) {
                            if (result == true) {
                              _refreshAll(force: true);
                            }
                          }),
                        ),
                      )),
                ],

                // Recent Positions
                BlocBuilder<PositionBloc, PositionState>(
                  bloc: _positionBloc,
                  builder: (context, posState) {
                    if (posState is PositionLoaded &&
                        posState.positions.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Recent Stakes',
                            style: context.h5,
                          ),
                          const SizedBox(height: 12),
                          ...posState.positions
                              .take(2)
                              .map((position) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child:
                                        MobilePositionCard(position: position),
                                  )),
                          if (posState.positions.length > 2)
                            Center(
                              child: TextButton(
                                onPressed: () => _tabController.animateTo(1),
                                child: Text(
                                  'View All Stakes (${posState.positions.length})',
                                  style: context.labelM
                                      .copyWith(color: context.colors.primary),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                if (promotedPools.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No featured pools right now. Browse all pools for more opportunities.',
                            style: context.bodyM,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        } else if (state is StakingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: context.colors.error),
                const SizedBox(height: 16),
                Text(state.message, style: context.bodyM),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _stakingBloc.add(
                    const LoadStakingData(forceRefresh: true),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMyStakesTab() {
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      builder: (context, state) {
        if (state is PositionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PositionLoaded) {
          if (state.positions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active stakes',
                    style: context.h6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start staking to earn rewards',
                    style: context.bodyM.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(2),
                    child: const Text('Browse Pools'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshPositions(force: true);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.positions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MobilePositionCard(position: state.positions[index]),
                );
              },
            ),
          );
        } else if (state is PositionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: context.colors.error),
                const SizedBox(height: 16),
                Text(state.message, style: context.bodyM),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshPositions(force: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAllPoolsTab() {
    return BlocBuilder<StakingBloc, StakingState>(
      bloc: _stakingBloc,
      builder: (context, state) {
        if (state is StakingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StakingLoaded) {
          final activePools =
              state.pools.where((p) => p.status == 'ACTIVE').toList();

          if (activePools.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pool_outlined,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pools available',
                    style: context.h6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new staking opportunities',
                    style: context.bodyM.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _stakingBloc.add(const LoadStakingData(forceRefresh: true));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activePools.length,
              itemBuilder: (context, index) {
                final pool = activePools[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MobilePoolCard(
                    pool: pool,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<StakingBloc>.value(
                          value: _stakingBloc,
                          child: PoolDetailPage(poolId: pool.id),
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _refreshAll(force: true);
                      }
                    }),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.labelL.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: context.bodyS.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
