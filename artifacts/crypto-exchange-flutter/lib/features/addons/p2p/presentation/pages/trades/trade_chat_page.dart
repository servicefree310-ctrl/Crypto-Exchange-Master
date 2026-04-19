import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/trades/trade_chat_bloc.dart';
import '../../bloc/trades/trade_chat_event.dart';
import '../../bloc/trades/trade_chat_state.dart';

/// Trade Chat Page – real-time messaging between buyer & seller.
class TradeChatPage extends StatefulWidget {
  const TradeChatPage({super.key, required this.tradeId});

  final String tradeId;

  @override
  State<TradeChatPage> createState() => _TradeChatPageState();
}

class _TradeChatPageState extends State<TradeChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TradeChatBloc>().add(TradeChatStarted(widget.tradeId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          context.colors.surface,
      appBar: AppBar(
        title: const Text('Trade Chat'),
        backgroundColor:
            context.colors.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessages()),
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return BlocBuilder<TradeChatBloc, TradeChatState>(
      builder: (context, state) {
        List<Map<String, dynamic>> messages = [];
        bool isLoading = false;
        if (state is TradeChatLoading || state is TradeChatSending) {
          isLoading = true;
          messages = state is TradeChatSending ? state.messages : [];
        } else if (state is TradeChatLoaded) {
          messages = state.messages;
        } else if (state is TradeChatError) {
          messages = state.messages;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isSelf = msg['isSelf'] == true || msg['sender'] == 'self';
                final text =
                    msg['message'] ?? msg['note'] ?? msg['event'] ?? '';
                final createdAtRaw = msg['createdAt'] ?? msg['time'];
                DateTime? time;
                if (createdAtRaw is DateTime) {
                  time = createdAtRaw;
                } else if (createdAtRaw is String) {
                  time = DateTime.tryParse(createdAtRaw);
                }
                return Align(
                  alignment:
                      isSelf ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isSelf
                          ? context.colors.primary.withValues(alpha: 0.15)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? context.colors.surface
                              : context.colors.surface),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (time != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(time),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.textSecondary,
                                      fontSize: 11,
                                    ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
            if (isLoading)
              Positioned(
                top: 8,
                right: 8,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.colors.primary),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
            top: BorderSide(
                color: context.borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: context.colors.secondary),
            onPressed: () {
              // TODO: implement file/image picker & upload (future step)
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                hintText: 'Type a message…',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: context.colors.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<TradeChatBloc>().add(TradeChatMessageSent(text));
    _messageController.clear();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
