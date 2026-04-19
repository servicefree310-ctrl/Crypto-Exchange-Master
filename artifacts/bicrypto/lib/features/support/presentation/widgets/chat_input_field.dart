import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.isWaiting = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isWaiting;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      if (hasText) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.background,
        border: Border(
          top: BorderSide(
            color: context.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.inputBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.borderColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(
                      color: context.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: context.textPrimary,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  onSubmitted: (_) {
                    if (_hasText) {
                      widget.onSend();
                    }
                  },
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _hasText
                          ? LinearGradient(
                              colors: [
                                context.colors.primary,
                                context.colors.primary.withValues(alpha: 0.8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _hasText ? null : context.borderColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _hasText ? widget.onSend : null,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color:
                                _hasText ? Colors.white : context.textTertiary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    final suggestions = [
      'I need help with trading',
      'Wallet issue',
      'Account security',
      'Technical problem',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                widget.controller.text = suggestion;
                _onTextChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Press Enter to send',
            style: TextStyle(
              color: context.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: context.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              // TODO: Open FAQ or help
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('FAQ feature coming soon'),
                  backgroundColor: context.colors.primary,
                ),
              );
            },
            child: Text(
              'View FAQ',
              style: TextStyle(
                color: context.colors.primary.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSend();
    }
  }
}
