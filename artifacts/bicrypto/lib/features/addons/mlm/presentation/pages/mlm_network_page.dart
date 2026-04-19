import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../../core/widgets/error_widget.dart' as core;
import '../../../../../injection/injection.dart';
import '../../domain/entities/mlm_network_entity.dart';
import '../bloc/mlm_network_bloc.dart';
import '../bloc/mlm_network_event.dart';
import '../bloc/mlm_network_state.dart';
import '../widgets/mlm_network_tree_widget.dart';
import '../widgets/mlm_binary_tree_widget.dart';
import '../widgets/mlm_unilevel_tree_widget.dart';
import '../widgets/mlm_user_node_widget.dart';

class MlmNetworkPage extends StatelessWidget {
  const MlmNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<MlmNetworkBloc>()..add(const MlmNetworkLoadRequested()),
      child: const MlmNetworkView(),
    );
  }
}

class MlmNetworkView extends StatelessWidget {
  const MlmNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: context.cardBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Network Tree',
          style: context.h6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<MlmNetworkBloc>().add(
                  const MlmNetworkRefreshRequested(),
                ),
            tooltip: 'Refresh Network',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showNetworkInfo(context),
            tooltip: 'Network Info',
          ),
        ],
      ),
      body: BlocConsumer<MlmNetworkBloc, MlmNetworkState>(
        listener: (context, state) {
          if (state is MlmNetworkError && state.previousNetwork == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: context.priceDownColor,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => context.read<MlmNetworkBloc>().add(
                        const MlmNetworkRetryRequested(),
                      ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MlmNetworkLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is MlmNetworkError && state.previousNetwork == null) {
            return Center(
              child: core.ErrorWidget(
                message: state.failure.message,
                onRetry: () => context.read<MlmNetworkBloc>().add(
                      const MlmNetworkRetryRequested(),
                    ),
              ),
            );
          }

          final network = _getNetworkFromState(state);
          if (network == null) {
            return const Center(child: LoadingWidget());
          }

          return _buildNetworkContent(context, network, state);
        },
      ),
    );
  }

  MlmNetworkEntity? _getNetworkFromState(MlmNetworkState state) {
    if (state is MlmNetworkLoaded) return state.network;
    if (state is MlmNetworkRefreshing) return state.currentNetwork;
    if (state is MlmNetworkError) return state.previousNetwork;
    return null;
  }

  Widget _buildNetworkContent(
    BuildContext context,
    MlmNetworkEntity network,
    MlmNetworkState state,
  ) {
    final isRefreshing = state is MlmNetworkRefreshing;

    return Column(
      children: [
        // Network Stats Summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              if (isRefreshing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.priceUpColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refreshing...',
                        style: context.labelS.copyWith(
                          color: context.priceUpColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // User Profile Card
              MlmUserNodeWidget(
                user: network.userProfile,
                isCurrentUser: true,
                showStats: true,
              ),

              const SizedBox(height: 16),

              // Network Type Indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSystemColor(network.mlmSystem).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getSystemColor(network.mlmSystem).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${network.mlmSystem.name.toUpperCase()} SYSTEM',
                  style: context.labelM.copyWith(
                    color: _getSystemColor(network.mlmSystem),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Network Tree Visualization
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: _buildNetworkTree(context, network),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNetworkTree(BuildContext context, MlmNetworkEntity network) {
    switch (network.mlmSystem) {
      case MlmSystem.binary:
        return MlmBinaryTreeWidget(
          network: network,
          binaryStructure: network.binaryStructure,
        );
      case MlmSystem.unilevel:
        return MlmUnilevelTreeWidget(
          network: network,
          levels: network.levels ?? [],
        );
      case MlmSystem.direct:
      default:
        return MlmNetworkTreeWidget(
          network: network,
          referrals: network.referrals ?? [],
        );
    }
  }

  Color _getSystemColor(MlmSystem system) {
    switch (system) {
      case MlmSystem.binary:
        return const Color(0xFF8B5CF6); // Purple
      case MlmSystem.unilevel:
        return const Color(0xFF10B981); // Green
      case MlmSystem.direct:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  void _showNetworkInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MLM Systems',
              style: context.h6,
            ),
            const SizedBox(height: 20),
            _buildSystemInfo(
              context,
              'DIRECT',
              'Simple referral system where you earn from direct referrals',
              const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _buildSystemInfo(
              context,
              'BINARY',
              'Two-leg system with left and right downlines for balanced growth',
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 12),
            _buildSystemInfo(
              context,
              'UNILEVEL',
              'Multiple levels of depth with unlimited width per level',
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo(
    BuildContext context,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelM.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
