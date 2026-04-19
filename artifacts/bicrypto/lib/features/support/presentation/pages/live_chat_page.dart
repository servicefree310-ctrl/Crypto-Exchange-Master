import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/live_chat_bloc.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_header.dart';
import '../widgets/waiting_indicator.dart';

class LiveChatPage extends StatelessWidget {
  const LiveChatPage({super.key, this.ticketId});

  final String? ticketId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LiveChatBloc>()
        ..add(ticketId != null
            ? ResumeLiveChatRequested(ticketId: ticketId!)
            : const InitializeLiveChatRequested()),
      child: const _LiveChatView(),
    );
  }
}

class _LiveChatView extends StatefulWidget {
  const _LiveChatView();

  @override
  State<_LiveChatView> createState() => _LiveChatViewState();
}

class _LiveChatViewState extends State<_LiveChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<LiveChatBloc>().add(SendMessageRequested(message));
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: BlocConsumer<LiveChatBloc, LiveChatState>(
        listener: (context, state) {
          if (state is LiveChatSessionActive && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Header
              ChatHeader(
                onBack: () => Navigator.of(context).pop(),
                onEndChat: () {
                  context.read<LiveChatBloc>().add(const EndChatRequested());
                  Navigator.of(context).pop();
                },
                state: state,
              ),

              // Body
              Expanded(
                child: _buildBody(state),
              ),

              // Input
              if (state is LiveChatSessionActive)
                ChatInputField(
                  controller: _messageController,
                  onSend: _sendMessage,
                  isWaiting: state.chatStatus == 'WAITING',
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(LiveChatState state) {
    if (state is LiveChatLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state is LiveChatError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to connect to live chat',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context
                    .read<LiveChatBloc>()
                    .add(const InitializeLiveChatRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is LiveChatSessionActive) {
      return Container(
        decoration: BoxDecoration(
          color: context.background,
        ),
        child: Column(
          children: [
            // Waiting indicator
            if (state.chatStatus == 'WAITING') WaitingIndicator(state: state),

            // Messages
            Expanded(
              child: state.messages.isEmpty
                  ? _buildEmptyChat(state.chatStatus == 'WAITING')
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return ChatMessageBubble(
                          message: message,
                          isFromAgent: message.isFromAgent,
                          isSystemMessage: message.userId == 'system',
                          animationIndex: index,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    if (state is LiveChatEnded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Chat Ended',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for contacting support',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyChat(bool isWaiting) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isWaiting ? 'Connecting to an agent...' : 'Start your conversation',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isWaiting
                ? 'Please wait while we connect you with a support agent'
                : 'Send a message to get started',
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
