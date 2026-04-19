import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../bloc/support_tickets_bloc.dart';
import '../widgets/ticket_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/live_chat_fab.dart';
import 'create_ticket_page.dart';
import 'live_chat_page.dart';
import 'ticket_detail_page.dart';

class SupportTicketsPage extends StatelessWidget {
  const SupportTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SupportTicketsBloc>()..add(const LoadSupportTicketsRequested()),
      child: const SupportTicketsView(),
    );
  }
}

class SupportTicketsView extends StatefulWidget {
  const SupportTicketsView({super.key});

  @override
  State<SupportTicketsView> createState() => _SupportTicketsViewState();
}

class _SupportTicketsViewState extends State<SupportTicketsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SupportTicketsBloc>().loadMoreTickets();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Support Tickets',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: context.textPrimary),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Create Ticket Button
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: context.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search tickets...',
                        hintStyle: TextStyle(color: context.textTertiary),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.textTertiary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: context.textTertiary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _performSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Create Ticket Button
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _showCreateTicketDialog(context),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Create New Ticket',
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: BlocConsumer<SupportTicketsBloc, SupportTicketsState>(
              listener: (context, state) {
                if (state is SupportTicketCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ticket created: ${state.ticket.subject}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SupportTicketsLoading) {
                  return const LoadingWidget();
                }

                if (state is SupportTicketsError && state.tickets.isEmpty) {
                  return core.ErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<SupportTicketsBloc>().add(
                            const LoadSupportTicketsRequested(),
                          );
                    },
                  );
                }

                if (state is SupportTicketsLoaded ||
                    (state is SupportTicketsError &&
                        state.tickets.isNotEmpty)) {
                  final tickets = state is SupportTicketsLoaded
                      ? state.tickets
                      : (state as SupportTicketsError).tickets;

                  final isRefreshing = state is SupportTicketsLoaded
                      ? state.isRefreshing
                      : false;

                  if (tickets.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<SupportTicketsBloc>().add(
                            const RefreshSupportTicketsRequested(),
                          );
                    },
                    color: const Color(0xFF6C5CE7),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: tickets.length + (isRefreshing ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= tickets.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.colors.primary,
                              ),
                            ),
                          );
                        }

                        return TicketCard(
                          ticket: tickets[index],
                          onTap: () => _navigateToTicketDetail(tickets[index]),
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      // Only Live Chat FAB now
      floatingActionButton: const LiveChatFab(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: context.borderColor),
            ),
            child: Icon(
              Icons.support_agent,
              size: 60,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Support Tickets',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first support ticket to get help',
            textAlign: TextAlign.center,
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateTicketDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Ticket'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        context.read<SupportTicketsBloc>().add(
              FilterSupportTicketsRequested(
                  search: query.isEmpty ? null : query),
            );
      }
    });
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );

    // Ensure the widget is still in the tree
    if (!mounted) return;

    // Dispatch filter event only when user taps "Apply"
    if (result != null) {
      context.read<SupportTicketsBloc>().add(
            FilterSupportTicketsRequested(
              status: result['status'] as TicketStatus?,
              importance: result['importance'] as TicketImportance?,
            ),
          );
    }
  }

  void _showCreateTicketDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTicketPage(),
      ),
    ).then((result) {
      // Refresh tickets if a ticket was created
      if (result == true) {
        context.read<SupportTicketsBloc>().add(
              const RefreshSupportTicketsRequested(),
            );
      }
    });
  }

  void _navigateToTicketDetail(SupportTicketEntity ticket) {
    if (ticket.type == TicketType.live) {
      // For live chat tickets, open the live chat interface with session resumption
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveChatPage(ticketId: ticket.id),
        ),
      );
    } else {
      // Navigate to dedicated TicketDetailPage for normal tickets
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketDetailPage(ticketId: ticket.id),
        ),
      );
    }
  }
}
