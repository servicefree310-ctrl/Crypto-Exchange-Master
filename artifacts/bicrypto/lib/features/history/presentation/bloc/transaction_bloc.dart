import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/get_transaction_details_usecase.dart';
import '../../domain/usecases/search_transactions_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

@injectable
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(
    this._getTransactionsUseCase,
    this._getTransactionDetailsUseCase,
    this._searchTransactionsUseCase,
  ) : super(const TransactionInitial()) {
    on<TransactionLoadRequested>(_onTransactionLoadRequested);
    on<TransactionLoadMoreRequested>(_onTransactionLoadMoreRequested);
    on<TransactionRefreshRequested>(_onTransactionRefreshRequested);
    on<TransactionDetailsRequested>(_onTransactionDetailsRequested);
    on<TransactionSearchRequested>(_onTransactionSearchRequested);
    on<TransactionSearchMoreRequested>(_onTransactionSearchMoreRequested);
    on<TransactionSearchCleared>(_onTransactionSearchCleared);
    on<TransactionFilterApplied>(_onTransactionFilterApplied);
    on<TransactionFilterCleared>(_onTransactionFilterCleared);
    on<TransactionRetryRequested>(_onTransactionRetryRequested);
  }

  final GetTransactionsUseCase _getTransactionsUseCase;
  final GetTransactionDetailsUseCase _getTransactionDetailsUseCase;
  final SearchTransactionsUseCase _searchTransactionsUseCase;

  // Keep track of current search query and filter for load more functionality
  String? _currentSearchQuery;
  TransactionFilterEntity? _currentFilter;

  Future<void> _onTransactionLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      dev.log(
          '🔄 TRANSACTION_BLOC: Loading transactions - page: ${event.page}, isRefresh: ${event.isRefresh}');

      // Store current filter for load more functionality
      _currentFilter = event.filter;
      _currentSearchQuery =
          null; // Clear search when loading regular transactions

      if (event.isRefresh && state is TransactionLoaded) {
        // Show refreshing state with existing data
        final currentState = state as TransactionLoaded;
        emit(TransactionRefreshing(
          existingTransactions: currentState.transactions,
          filter: event.filter,
        ));
      } else if (event.page == 1) {
        // Initial load
        emit(const TransactionLoading(message: 'Loading transactions...'));
      }

      final result = await _getTransactionsUseCase(GetTransactionsParams(
        filter: event.filter,
        page: event.page,
        pageSize: event.pageSize,
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ TRANSACTION_BLOC: Failed to load transactions - ${failure.message}');
          if (event.isRefresh && state is TransactionRefreshing) {
            // Return to previous loaded state on refresh error
            final refreshingState = state as TransactionRefreshing;
            emit(TransactionLoaded(
              transactions: refreshingState.existingTransactions,
              totalCount: refreshingState.existingTransactions.length,
              currentPage: 1,
              pageSize: event.pageSize,
              hasNextPage: false,
              filter: refreshingState.filter,
            ));
          } else {
            emit(TransactionError(failure: failure));
          }
        },
        (transactionList) {
          dev.log(
              '✅ TRANSACTION_BLOC: Successfully loaded ${transactionList.transactions.length} transactions');

          if (transactionList.transactions.isEmpty && event.page == 1) {
            emit(const TransactionEmpty(message: 'No transactions found'));
          } else {
            emit(TransactionLoaded(
              transactions: transactionList.transactions,
              totalCount: transactionList.totalCount,
              currentPage: transactionList.currentPage,
              pageSize: transactionList.pageSize,
              hasNextPage: transactionList.hasNextPage,
              filter: event.filter,
            ));
          }
        },
      );
    } catch (e) {
      dev.log('❌ TRANSACTION_BLOC: Unexpected error loading transactions - $e');
      emit(const TransactionError(
          failure: UnknownFailure('An unexpected error occurred')));
    }
  }

  Future<void> _onTransactionLoadMoreRequested(
    TransactionLoadMoreRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    if (!currentState.hasNextPage) return;

    try {
      dev.log(
          '🔄 TRANSACTION_BLOC: Loading more transactions - page: ${currentState.currentPage + 1}');

      emit(TransactionLoadingMore(
        existingTransactions: currentState.transactions,
        currentPage: currentState.currentPage,
      ));

      final result = await _getTransactionsUseCase(GetTransactionsParams(
        filter: _currentFilter,
        page: currentState.currentPage + 1,
        pageSize: currentState.pageSize,
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ TRANSACTION_BLOC: Failed to load more transactions - ${failure.message}');
          // Return to previous loaded state
          emit(currentState);
        },
        (transactionList) {
          dev.log(
              '✅ TRANSACTION_BLOC: Successfully loaded ${transactionList.transactions.length} more transactions');

          final allTransactions = [
            ...currentState.transactions,
            ...transactionList.transactions,
          ];

          emit(TransactionLoaded(
            transactions: allTransactions,
            totalCount: transactionList.totalCount,
            currentPage: transactionList.currentPage,
            pageSize: transactionList.pageSize,
            hasNextPage: transactionList.hasNextPage,
            filter: currentState.filter,
            stats: currentState.stats,
          ));
        },
      );
    } catch (e) {
      dev.log(
          '❌ TRANSACTION_BLOC: Unexpected error loading more transactions - $e');
      emit(currentState); // Return to previous state
    }
  }

  Future<void> _onTransactionRefreshRequested(
    TransactionRefreshRequested event,
    Emitter<TransactionState> emit,
  ) async {
    // Get current filter from state
    TransactionFilterEntity? currentFilter;
    if (state is TransactionLoaded) {
      currentFilter = (state as TransactionLoaded).filter;
    }

    // Trigger a refresh load
    add(TransactionLoadRequested(
      filter: currentFilter,
      page: 1,
      pageSize: 20,
      isRefresh: true,
    ));
  }

  Future<void> _onTransactionDetailsRequested(
    TransactionDetailsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      dev.log(
          '🔄 TRANSACTION_BLOC: Loading transaction details - ${event.transactionId}');

      emit(TransactionDetailsLoading(event.transactionId));

      final result =
          await _getTransactionDetailsUseCase(GetTransactionDetailsParams(
        transactionId: event.transactionId,
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ TRANSACTION_BLOC: Failed to load transaction details - ${failure.message}');
          emit(TransactionError(failure: failure));
        },
        (transaction) {
          dev.log(
              '✅ TRANSACTION_BLOC: Successfully loaded transaction details - ${transaction.id}');
          emit(TransactionDetailsLoaded(transaction));
        },
      );
    } catch (e) {
      dev.log(
          '❌ TRANSACTION_BLOC: Unexpected error loading transaction details - $e');
      emit(const TransactionError(
          failure: UnknownFailure('An unexpected error occurred')));
    }
  }

  Future<void> _onTransactionSearchRequested(
    TransactionSearchRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      dev.log(
          '🔄 TRANSACTION_BLOC: Searching transactions - query: ${event.query}');

      // Store current search query for load more functionality
      _currentSearchQuery = event.query;
      _currentFilter = null; // Clear filter when searching

      emit(TransactionSearchLoading(query: event.query));

      final result = await _searchTransactionsUseCase(SearchTransactionsParams(
        query: event.query,
        page: event.page,
        pageSize: event.pageSize,
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ TRANSACTION_BLOC: Failed to search transactions - ${failure.message}');
          emit(TransactionError(failure: failure));
        },
        (transactionList) {
          dev.log(
              '✅ TRANSACTION_BLOC: Successfully searched ${transactionList.transactions.length} transactions');

          if (transactionList.transactions.isEmpty) {
            emit(TransactionSearchEmpty(query: event.query));
          } else {
            emit(TransactionSearchLoaded(
              query: event.query,
              transactions: transactionList.transactions,
              totalCount: transactionList.totalCount,
              currentPage: transactionList.currentPage,
              pageSize: transactionList.pageSize,
              hasNextPage: transactionList.hasNextPage,
            ));
          }
        },
      );
    } catch (e) {
      dev.log('❌ TRANSACTION_BLOC: Unexpected error searching transactions - $e');
      emit(const TransactionError(
          failure: UnknownFailure('An unexpected error occurred')));
    }
  }

  Future<void> _onTransactionSearchMoreRequested(
    TransactionSearchMoreRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionSearchLoaded) return;
    if (_currentSearchQuery == null) return;

    final currentState = state as TransactionSearchLoaded;
    if (!currentState.hasNextPage) return;

    try {
      dev.log(
          '🔄 TRANSACTION_BLOC: Loading more search results - page: ${currentState.currentPage + 1}');

      emit(TransactionSearchLoadingMore(
        query: currentState.query,
        existingTransactions: currentState.transactions,
        currentPage: currentState.currentPage,
      ));

      final result = await _searchTransactionsUseCase(SearchTransactionsParams(
        query: _currentSearchQuery!,
        page: currentState.currentPage + 1,
        pageSize: currentState.pageSize,
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ TRANSACTION_BLOC: Failed to load more search results - ${failure.message}');
          // Return to previous state
          emit(currentState);
        },
        (transactionList) {
          dev.log(
              '✅ TRANSACTION_BLOC: Successfully loaded ${transactionList.transactions.length} more search results');

          final allTransactions = [
            ...currentState.transactions,
            ...transactionList.transactions,
          ];

          emit(TransactionSearchLoaded(
            query: currentState.query,
            transactions: allTransactions,
            totalCount: transactionList.totalCount,
            currentPage: transactionList.currentPage,
            pageSize: transactionList.pageSize,
            hasNextPage: transactionList.hasNextPage,
          ));
        },
      );
    } catch (e) {
      dev.log(
          '❌ TRANSACTION_BLOC: Unexpected error loading more search results - $e');
      emit(currentState); // Return to previous state
    }
  }

  Future<void> _onTransactionSearchCleared(
    TransactionSearchCleared event,
    Emitter<TransactionState> emit,
  ) async {
    dev.log('🔄 TRANSACTION_BLOC: Clearing search and loading transactions');

    _currentSearchQuery = null;

    // Load regular transactions
    add(const TransactionLoadRequested(page: 1, pageSize: 20));
  }

  Future<void> _onTransactionFilterApplied(
    TransactionFilterApplied event,
    Emitter<TransactionState> emit,
  ) async {
    dev.log(
        '🔄 TRANSACTION_BLOC: Applying filter - ${event.filter.toQueryParameters()}');

    // Load transactions with the new filter
    add(TransactionLoadRequested(
      filter: event.filter,
      page: 1,
      pageSize: 20,
    ));
  }

  Future<void> _onTransactionFilterCleared(
    TransactionFilterCleared event,
    Emitter<TransactionState> emit,
  ) async {
    dev.log('🔄 TRANSACTION_BLOC: Clearing filter and loading transactions');

    _currentFilter = null;

    // Load transactions without filter
    add(const TransactionLoadRequested(page: 1, pageSize: 20));
  }

  Future<void> _onTransactionRetryRequested(
    TransactionRetryRequested event,
    Emitter<TransactionState> emit,
  ) async {
    dev.log('🔄 TRANSACTION_BLOC: Retrying last operation');

    if (_currentSearchQuery != null) {
      // Retry search
      add(TransactionSearchRequested(query: _currentSearchQuery!));
    } else {
      // Retry regular load
      add(TransactionLoadRequested(filter: _currentFilter));
    }
  }
}
