import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transfer_option_entity.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';

class TransferTypeSelectorWidget extends StatefulWidget {
  final List<TransferOptionEntity> walletTypes;

  const TransferTypeSelectorWidget({
    super.key,
    required this.walletTypes,
  });

  @override
  State<TransferTypeSelectorWidget> createState() =>
      _TransferTypeSelectorWidgetState();
}

class _TransferTypeSelectorWidgetState extends State<TransferTypeSelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimations = List.generate(
      2,
      (index) => Tween<Offset>(
        begin: Offset(0, 0.2 + (index * 0.1)),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.2 + (index * 0.1),
          0.6 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      )),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Transfer Type',
                  style: context.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to transfer your funds',
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Wallet to Wallet Transfer
          SlideTransition(
            position: _slideAnimations[0],
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _TransferTypeCard(
                icon: Icons.swap_horiz_rounded,
                title: 'Between My Wallets',
                description: 'Transfer funds between your own wallet types',
                iconColor: context.colors.primary,
                gradientColors: [
                  context.colors.primary.withValues(alpha: 0.1),
                  context.colors.primary.withValues(alpha: 0.05),
                ],
                badge: 'FREE',
                badgeColor: context.colors.primary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<TransferBloc>().add(
                        const TransferTypeSelected(transferType: 'wallet'),
                      );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User to User Transfer
          SlideTransition(
            position: _slideAnimations[1],
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _TransferTypeCard(
                icon: Icons.send_rounded,
                title: 'Send to Another User',
                description: 'Transfer funds to another user\'s wallet',
                iconColor: const Color(0xFF00D4AA),
                gradientColors: [
                  const Color(0xFF00D4AA).withValues(alpha: 0.1),
                  const Color(0xFF00D4AA).withValues(alpha: 0.05),
                ],
                badge: '1% FEE',
                badgeColor: context.orangeAccent,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<TransferBloc>().add(
                        const TransferTypeSelected(transferType: 'client'),
                      );
                },
              ),
            ),
          ),

          const Spacer(),

          // Info box with enhanced design
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? context.colors.surface
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: context.colors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Information',
                          style: context.labelM.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Wallet transfers are free and instant. User transfers include a 1% fee with minimum 0.01.',
                          style: context.labelS.copyWith(
                            color: context.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferTypeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final List<Color> gradientColors;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _TransferTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.gradientColors,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  State<_TransferTypeCard> createState() => _TransferTypeCardState();
}

class _TransferTypeCardState extends State<_TransferTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _hoverController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed
                      ? widget.iconColor.withValues(alpha: 0.3)
                      : context.isDarkMode
                          ? const Color(0xFF3A4553).withValues(alpha: 0.5)
                          : const Color(0xFFE5E7EB),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.iconColor.withValues(alpha: _isPressed ? 0.15 : 0.08),
                    blurRadius: _isPressed ? 20 : 12,
                    offset: Offset(0, _isPressed ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.iconColor.withValues(alpha: 0.2),
                          widget.iconColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.iconColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: context.h6.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.badgeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.badgeColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.badge,
                                style: TextStyle(
                                  color: widget.badgeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: context.bodyM.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: context.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
