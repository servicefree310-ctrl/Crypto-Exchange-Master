import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_empty_state.dart';
import '../widgets/transaction_error_widget.dart';
import 'transaction_analytics_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<TransactionBloc>()..add(const TransactionLoadRequested()),
      child: Scaffold(
        backgroundColor: context.background,
        appBar: _buildAppBar(context),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimary,
            size: 18,
          ),
        ),
      ),
      title: Text(
        'Transaction History',
        style: context.h6.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: context.background,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _showSearch(context),
            icon: Icon(
              Icons.search_rounded,
              color: context.textPrimary,
              size: 22,
            ),
            tooltip: 'Search transactions',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: context.borderColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TransactionState state) {
    if (state is TransactionLoading) {
      return _buildLoadingState(context);
    } else if (state is TransactionEmpty) {
      return TransactionEmptyState(
        message: state.message ?? 'No transactions found',
        onRetry: () => context.read<TransactionBloc>().add(
              const TransactionLoadRequested(),
            ),
      );
    } else if (state is TransactionError) {
      return TransactionErrorWidget(
        message: state.message,
        onRetry: () => context.read<TransactionBloc>().add(
              const TransactionRetryRequested(),
            ),
      );
    } else if (state is TransactionLoaded) {
      return _buildTransactionsList(context, state.transactions);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading transactions...',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
      BuildContext context, List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return const TransactionEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<TransactionBloc>()
            .add(const TransactionRefreshRequested());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length + 1, // Add 1 for the banner
        itemBuilder: (context, index) {
          // Show analytics hint banner as first item
          if (index == 0) {
            return GestureDetector(
              onTap: () => _showAnalytics(context),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colors.primary.withValues(alpha: 0.1),
                      context.colors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: context.colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Analytics',
                            style: context.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap the analytics icon above to see detailed insights',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: context.colors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }

          // Adjust index for actual transactions
          final transactionIndex = index - 1;
          final transaction = transactions[transactionIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TransactionListItem(
              transaction: transaction,
              onTap: () => _onTransactionTap(context, transaction),
            ),
          );
        },
      ),
    );
  }

  void _onTransactionTap(BuildContext context, TransactionEntity transaction) {
    // Navigate to transaction details
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTransactionDetailsSheet(context, transaction),
    );
  }

  Widget _buildTransactionDetailsSheet(
      BuildContext context, TransactionEntity transaction) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Transaction Details',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textTertiary),
                ),
              ],
            ),
          ),
          // Transaction details content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTransactionDetails(context, transaction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(
      BuildContext context, TransactionEntity transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(context, 'ID', transaction.id),
        _buildDetailRow(context, 'Type', transaction.displayTitle),
        _buildDetailRow(context, 'Status', transaction.statusDisplayText),
        _buildDetailRow(context, 'Amount',
            '${transaction.amount.toStringAsFixed(8)} ${transaction.walletCurrency}'),
        _buildDetailRow(context, 'Fee',
            '${transaction.fee.toStringAsFixed(8)} ${transaction.walletCurrency}'),
        _buildDetailRow(context, 'Net Amount',
            '${transaction.netAmount.toStringAsFixed(8)} ${transaction.walletCurrency}'),
        if (transaction.description?.isNotEmpty == true)
          _buildDetailRow(context, 'Description', transaction.description!),
        _buildDetailRow(context, 'Date', _formatDate(transaction.createdAt)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.bodyM.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    final state = context.read<TransactionBloc>().state;

    if (state is TransactionLoaded) {
      showSearch(
        context: context,
        delegate: TransactionSearchDelegate(
          transactions: state.transactions,
          onTransactionSelected: (transaction) {
            _onTransactionTap(context, transaction);
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait for transactions to load',
            style: TextStyle(color: context.colors.onPrimary),
          ),
          backgroundColor: context.colors.primary,
        ),
      );
    }
  }

  void _showAnalytics(BuildContext context) {
    // Get transactions from the current loaded state
    final state = context.read<TransactionBloc>().state;

    if (state is TransactionLoaded && state.transactions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionAnalyticsPage(
            transactions: state.transactions,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No transactions available for analytics',
            style: TextStyle(color: context.colors.onPrimary),
          ),
          backgroundColor: context.colors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class TransactionSearchDelegate extends SearchDelegate<TransactionEntity?> {
  final List<TransactionEntity> transactions;
  final Function(TransactionEntity) onTransactionSelected;

  TransactionSearchDelegate({
    required this.transactions,
    required this.onTransactionSelected,
  });

  @override
  String get searchFieldLabel => 'Search by ID, amount, or description';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: context.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter transaction ID, amount,\nor description to search',
              textAlign: TextAlign.center,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredTransactions = transactions.where((transaction) {
      final queryLower = query.toLowerCase();

      // Search by transaction ID
      if (transaction.id.toLowerCase().contains(queryLower)) {
        return true;
      }

      // Search by amount
      if (transaction.amount.toString().contains(query)) {
        return true;
      }

      // Search by description
      if (transaction.description?.toLowerCase().contains(queryLower) == true) {
        return true;
      }

      // Search by type
      if (transaction.displayTitle.toLowerCase().contains(queryLower)) {
        return true;
      }

      // Search by status
      if (transaction.statusDisplayText.toLowerCase().contains(queryLower)) {
        return true;
      }

      // Search by currency
      if (transaction.walletCurrency.toLowerCase().contains(queryLower)) {
        return true;
      }

      return false;
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: context.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found for "$query"',
              style: context.bodyL.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TransactionListItem(
            transaction: transaction,
            onTap: () {
              close(context, transaction);
              onTransactionSelected(transaction);
            },
          ),
        );
      },
    );
  }
}
