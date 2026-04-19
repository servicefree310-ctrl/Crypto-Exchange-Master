import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../bloc/spot_deposit_bloc.dart';
import '../../bloc/spot_deposit_state.dart';

class SpotNetworkSelector extends StatefulWidget {
  const SpotNetworkSelector({
    super.key,
    required this.currency,
    required this.onNetworkSelected,
  });

  final String currency;
  final Function(String) onNetworkSelected;

  @override
  State<SpotNetworkSelector> createState() => _SpotNetworkSelectorState();
}

class _SpotNetworkSelectorState extends State<SpotNetworkSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpotDepositBloc, SpotDepositState>(
      builder: (context, state) {
        if (state is SpotNetworksLoaded) {
          if (state.networks.isEmpty) {
            return _buildEmptyState();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: state.networks.length,
              itemBuilder: (context, index) {
                final network = state.networks[index];
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    final delay = index * 0.05;
                    final progress =
                        (_fadeAnimation.value - delay).clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, 10 * (1 - progress)),
                      child: Opacity(
                        opacity: progress,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildNetworkCard(network),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is SpotDepositError) {
          return _buildErrorState(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNetworkCard(dynamic network) {
    final maxAmount = network.limits.deposit.max;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardBackground,
            context.cardBackground.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => widget.onNetworkSelected(network.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Network Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.2),
                        Colors.blue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.hub_rounded,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Network Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.chain,
                        style: context.bodyM.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Network Details
                      Row(
                        children: [
                          _buildInfoChip(
                            'Fee: ${network.fee ?? 0.0}',
                            context.warningColor.withValues(alpha: 0.1),
                            context.warningColor,
                          ),
                          const SizedBox(width: 6),
                          _buildInfoChip(
                            'Min: ${network.limits.deposit.min}',
                            context.borderColor.withValues(alpha: 0.1),
                            context.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maxAmount != null
                            ? 'Max: $maxAmount ${widget.currency}'
                            : 'No limit',
                        style: context.bodyS.copyWith(
                          color: context.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.borderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: context.textTertiary,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 40,
                color: context.warningColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Networks Available',
              style: context.bodyL.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'There are no deposit networks available for ${widget.currency}. This currency may not support SPOT deposits.',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(SpotDepositError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.priceDownColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: context.priceDownColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Networks',
              style: context.bodyL.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                state.failure.message.contains('Invalid data format')
                    ? '${widget.currency} is not available for SPOT deposits. Please select a different cryptocurrency.'
                    : state.failure.message,
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_rounded, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Go Back',
                    style: context.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
