import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../injection/injection.dart';
import '../bloc/ticket_detail_bloc.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/ticket_header.dart';

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TicketDetailBloc>()
        ..add(LoadTicketRequested(ticketId: ticketId)),
      child: const _TicketDetailView(),
    );
  }
}

class _TicketDetailView extends StatefulWidget {
  const _TicketDetailView();

  @override
  State<_TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<_TicketDetailView> {
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
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendReply() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<TicketDetailBloc>().add(SendReplyRequested(text));
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: BlocConsumer<TicketDetailBloc, TicketDetailState>(
        listener: (context, state) {
          if (state is TicketDetailLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TicketDetailLoading || state is TicketDetailInitial) {
            return const Center(child: LoadingWidget());
          }

          if (state is TicketDetailError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          }

          if (state is TicketDetailLoaded) {
            final ticket = state.ticket;
            final messages = state.ticket.messages;
            return Column(
              children: [
                TicketHeader(
                  ticket: ticket,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ChatMessageBubble(
                        message: msg,
                        isFromAgent: msg.isFromAgent,
                        animationIndex: index,
                      );
                    },
                  ),
                ),
                _buildInputArea(state.isClosed, state.isSending),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInputArea(bool isClosed, bool isSending) {
    if (isClosed) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'Ticket is closed. You cannot reply to this ticket.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D29),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your reply...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendReply(),
              ),
            ),
            IconButton(
              icon: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: isSending ? null : _sendReply,
            ),
          ],
        ),
      ),
    );
  }
}
