import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/live_chat_bloc.dart';

class WaitingIndicator extends StatefulWidget {
  const WaitingIndicator({
    super.key,
    required this.state,
  });

  final LiveChatSessionActive state;

  @override
  State<WaitingIndicator> createState() => _WaitingIndicatorState();
}

class _WaitingIndicatorState extends State<WaitingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show if waiting and no messages have been sent by the user yet
    final hasUserMessages =
        widget.state.messages.any((msg) => msg.type == 'client');
    if (widget.state.chatStatus != 'WAITING' || hasUserMessages) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Message
                Row(
                  children: [
                    Text(
                      'Connecting to agent',
                      style: context.bodyM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _dotsController,
                      builder: (context, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            final opacity =
                                ((_dotsController.value * 3 - index) % 3)
                                    .clamp(0.0, 1.0);
                            return Opacity(
                              opacity: opacity,
                              child: Text(
                                '.',
                                style: context.bodyM.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Subtitle
                Text(
                  'Feel free to describe your issue',
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
