import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested({
    this.filter,
    this.page = 1,
    this.pageSize = 20,
    this.isRefresh = false,
  });

  final TransactionFilterEntity? filter;
  final int page;
  final int pageSize;
  final bool isRefresh;

  @override
  List<Object?> get props => [filter, page, pageSize, isRefresh];
}

class TransactionLoadMoreRequested extends TransactionEvent {
  const TransactionLoadMoreRequested();

  @override
  List<Object> get props => [];
}

class TransactionRefreshRequested extends TransactionEvent {
  const TransactionRefreshRequested();

  @override
  List<Object> get props => [];
}

class TransactionDetailsRequested extends TransactionEvent {
  const TransactionDetailsRequested(this.transactionId);

  final String transactionId;

  @override
  List<Object> get props => [transactionId];
}

class TransactionSearchRequested extends TransactionEvent {
  const TransactionSearchRequested({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  final String query;
  final int page;
  final int pageSize;

  @override
  List<Object> get props => [query, page, pageSize];
}

class TransactionSearchMoreRequested extends TransactionEvent {
  const TransactionSearchMoreRequested();

  @override
  List<Object> get props => [];
}

class TransactionSearchCleared extends TransactionEvent {
  const TransactionSearchCleared();

  @override
  List<Object> get props => [];
}

class TransactionFilterApplied extends TransactionEvent {
  const TransactionFilterApplied(this.filter);

  final TransactionFilterEntity filter;

  @override
  List<Object> get props => [filter];
}

class TransactionFilterCleared extends TransactionEvent {
  const TransactionFilterCleared();

  @override
  List<Object> get props => [];
}

class TransactionStatsRequested extends TransactionEvent {
  const TransactionStatsRequested();

  @override
  List<Object> get props => [];
}

class TransactionRetryRequested extends TransactionEvent {
  const TransactionRetryRequested();

  @override
  List<Object> get props => [];
}
