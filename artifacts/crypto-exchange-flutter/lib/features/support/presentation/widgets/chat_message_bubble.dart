import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/support_message_entity.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromAgent,
    this.isSystemMessage = false,
    this.animationIndex = 0,
  });

  final SupportMessageEntity message;
  final bool isFromAgent;
  final bool isSystemMessage;
  final int animationIndex;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.animationIndex * 100)),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isFromAgent ? -0.3 : 0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation after a slight delay based on index
    Future.delayed(Duration(milliseconds: widget.animationIndex * 50), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: EdgeInsets.only(
              bottom: 8,
              left:
                  widget.isFromAgent ? 0 : 60, // User messages have left margin
              right: widget.isFromAgent
                  ? 60
                  : 0, // Agent messages have right margin
            ),
            child: Row(
              mainAxisAlignment: widget.isFromAgent
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end, // User messages align to end (right)
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isFromAgent) ...[
                  // Agent avatar on the left
                  _buildAvatar(),
                  const SizedBox(width: 8),
                ],

                // Message content
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isFromAgent
                          ? widget.isSystemMessage
                              ? context.colors.tertiary.withValues(alpha: 0.1)
                              : context.cardBackground
                          : context.colors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: widget.isFromAgent
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                        bottomRight: widget.isFromAgent
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                      ),
                      border: widget.isFromAgent
                          ? Border.all(
                              color: context.borderColor,
                              width: 0.5,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.shadow.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isSystemMessage) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.smart_toy,
                                size: 14,
                                color: context.colors.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Assistant',
                                style: context.labelS.copyWith(
                                  color: context.colors.tertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          widget.message.text,
                          style: context.bodyM.copyWith(
                            color: widget.isFromAgent
                                ? context.textPrimary
                                : Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(DateTime.parse(widget.message.time)),
                          style: context.labelS.copyWith(
                            color: widget.isFromAgent
                                ? context.textTertiary
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!widget.isFromAgent) ...[
                  // User avatar on the right
                  const SizedBox(width: 8),
                  _buildAvatar(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.isFromAgent
            ? context.colors.primary
            : context.colors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        widget.isFromAgent ? Icons.support_agent : Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
