import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();

  @override
  List<Object> get props => [];
}

class TransactionLoading extends TransactionState {
  const TransactionLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class TransactionLoaded extends TransactionState {
  const TransactionLoaded({
    required this.transactions,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    this.filter,
    this.stats,
  });

  final List<TransactionEntity> transactions;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final TransactionFilterEntity? filter;
  final Map<String, dynamic>? stats;

  bool get hasTransactions => transactions.isNotEmpty;
  bool get isEmpty => transactions.isEmpty;
  bool get isFirstPage => currentPage == 1;

  @override
  List<Object?> get props => [
        transactions,
        totalCount,
        currentPage,
        pageSize,
        hasNextPage,
        filter,
        stats,
      ];

  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
    TransactionFilterEntity? filter,
    Map<String, dynamic>? stats,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      filter: filter ?? this.filter,
      stats: stats ?? this.stats,
    );
  }
}

class TransactionLoadingMore extends TransactionState {
  const TransactionLoadingMore({
    required this.existingTransactions,
    required this.currentPage,
  });

  final List<TransactionEntity> existingTransactions;
  final int currentPage;

  @override
  List<Object> get props => [existingTransactions, currentPage];
}

class TransactionEmpty extends TransactionState {
  const TransactionEmpty({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  const TransactionError({required this.failure});

  final Failure failure;

  String get message => failure.message;

  @override
  List<Object> get props => [failure];
}

class TransactionDetailsLoading extends TransactionState {
  const TransactionDetailsLoading(this.transactionId);

  final String transactionId;

  @override
  List<Object> get props => [transactionId];
}

class TransactionDetailsLoaded extends TransactionState {
  const TransactionDetailsLoaded(this.transaction);

  final TransactionEntity transaction;

  @override
  List<Object> get props => [transaction];
}

class TransactionSearchLoading extends TransactionState {
  const TransactionSearchLoading({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class TransactionSearchLoaded extends TransactionState {
  const TransactionSearchLoaded({
    required this.query,
    required this.transactions,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
  });

  final String query;
  final List<TransactionEntity> transactions;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;

  bool get hasResults => transactions.isNotEmpty;
  bool get isEmpty => transactions.isEmpty;

  @override
  List<Object> get props => [
        query,
        transactions,
        totalCount,
        currentPage,
        pageSize,
        hasNextPage,
      ];

  TransactionSearchLoaded copyWith({
    String? query,
    List<TransactionEntity>? transactions,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
  }) {
    return TransactionSearchLoaded(
      query: query ?? this.query,
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class TransactionSearchLoadingMore extends TransactionState {
  const TransactionSearchLoadingMore({
    required this.query,
    required this.existingTransactions,
    required this.currentPage,
  });

  final String query;
  final List<TransactionEntity> existingTransactions;
  final int currentPage;

  @override
  List<Object> get props => [query, existingTransactions, currentPage];
}

class TransactionSearchEmpty extends TransactionState {
  const TransactionSearchEmpty({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class TransactionRefreshing extends TransactionState {
  const TransactionRefreshing({
    required this.existingTransactions,
    this.filter,
  });

  final List<TransactionEntity> existingTransactions;
  final TransactionFilterEntity? filter;

  @override
  List<Object?> get props => [existingTransactions, filter];
}
