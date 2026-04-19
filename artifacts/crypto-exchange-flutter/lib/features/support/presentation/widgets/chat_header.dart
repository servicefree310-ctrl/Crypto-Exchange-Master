import 'package:flutter/material.dart';
import '../bloc/live_chat_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.onBack,
    this.onEndChat,
    required this.state,
  });

  final VoidCallback onBack;
  final VoidCallback? onEndChat;
  final LiveChatState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Back Button
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: context.textPrimary,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: context.borderColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Agent Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      _getTitle(),
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      _getSubtitle(),
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Indicator
              _buildStatusIndicator(context),

              const SizedBox(width: 12),

              // End Chat Button
              if (onEndChat != null && _shouldShowEndButton())
                IconButton(
                  onPressed: onEndChat,
                  icon: Icon(
                    Icons.call_end,
                    color: context.priceDownColor,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: context.priceDownColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (state is LiveChatSessionActive) {
      final activeState = state as LiveChatSessionActive;
      if (activeState.chatStatus == 'WAITING') {
        return 'Connecting...';
      } else if (activeState.ticket.agentName != null) {
        return activeState.ticket.agentName!;
      }
    }
    return 'Support Agent';
  }

  String _getSubtitle() {
    if (state is LiveChatSessionActive) {
      final activeState = state as LiveChatSessionActive;
      if (activeState.chatStatus == 'WAITING') {
        return 'Please wait for an agent...';
      } else if (activeState.isAgentConnected) {
        return 'Online • Ready to help';
      }
    } else if (state is LiveChatLoading) {
      return 'Initializing...';
    } else if (state is LiveChatError) {
      return 'Connection failed';
    }
    return '${AppConstants.appName} Support';
  }

  Widget _buildStatusIndicator(BuildContext context) {
    if (state is LiveChatSessionActive) {
      final activeState = state as LiveChatSessionActive;

      if (activeState.isAgentConnected &&
          activeState.chatStatus == 'CONNECTED') {
        return _buildConnectedIndicator(context);
      } else if (activeState.chatStatus == 'WAITING') {
        return _buildWaitingIndicator(context);
      }
    }

    return _buildOfflineIndicator(context);
  }

  Widget _buildConnectedIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.priceUpColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.priceUpColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.priceUpColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Online',
            style: context.labelS.copyWith(
              color: context.priceUpColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.warningColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(context.warningColor),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Waiting',
            style: context.labelS.copyWith(
              color: context.warningColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.textTertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: context.labelS.copyWith(
              color: context.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowEndButton() {
    return state is LiveChatSessionActive &&
        (state as LiveChatSessionActive).chatStatus != 'ENDED';
  }
}
