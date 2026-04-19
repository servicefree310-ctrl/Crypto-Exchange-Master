import 'package:equatable/equatable.dart';
import '../../domain/entities/ico_offering_entity.dart';
import '../../domain/entities/ico_portfolio_entity.dart';
import '../../domain/entities/portfolio_performance_point_entity.dart';
import '../../domain/entities/ico_stats_entity.dart';

abstract class IcoState extends Equatable {
  const IcoState();

  @override
  List<Object?> get props => [];
}

class IcoInitial extends IcoState {
  const IcoInitial();
}

class IcoLoading extends IcoState {
  const IcoLoading();
}

class IcoError extends IcoState {
  const IcoError({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

// Dashboard State
class IcoDashboardLoaded extends IcoState {
  const IcoDashboardLoaded({
    required this.featuredOfferings,
    required this.portfolio,
    required this.recentTransactions,
    required this.stats,
  });

  final List<IcoOfferingEntity> featuredOfferings;
  final IcoPortfolioEntity portfolio;
  final List<IcoTransactionEntity> recentTransactions;
  final IcoStatsEntity stats;

  @override
  List<Object?> get props =>
      [featuredOfferings, portfolio, recentTransactions, stats];
}

// Offerings States
class IcoOfferingsLoaded extends IcoState {
  const IcoOfferingsLoaded({
    required this.offerings,
    this.hasMore = false,
  });

  final List<IcoOfferingEntity> offerings;
  final bool hasMore;

  @override
  List<Object?> get props => [offerings, hasMore];
}

class IcoOfferingDetailLoaded extends IcoState {
  const IcoOfferingDetailLoaded({
    required this.offering,
  });

  final IcoOfferingEntity offering;

  @override
  List<Object?> get props => [offering];
}

// Portfolio States
class IcoPortfolioLoaded extends IcoState {
  const IcoPortfolioLoaded({
    required this.portfolio,
    this.performance = const [],
  });

  final IcoPortfolioEntity portfolio;
  final List<PortfolioPerformancePointEntity> performance;

  @override
  List<Object?> get props => [portfolio, performance];
}

// Transactions States
class IcoTransactionsLoaded extends IcoState {
  const IcoTransactionsLoaded({
    required this.transactions,
    this.hasMore = false,
  });

  final List<IcoTransactionEntity> transactions;
  final bool hasMore;

  @override
  List<Object?> get props => [transactions, hasMore];
}

// Investment States
class IcoInvestmentCreated extends IcoState {
  const IcoInvestmentCreated({
    required this.transaction,
  });

  final IcoTransactionEntity transaction;

  @override
  List<Object?> get props => [transaction];
}

// Stats States
class IcoStatsLoaded extends IcoState {
  const IcoStatsLoaded({
    required this.stats,
  });

  final IcoStatsEntity stats;

  @override
  List<Object?> get props => [stats];
}

// Loading with data states (for refresh scenarios)
class IcoLoadingWithData extends IcoState {
  const IcoLoadingWithData({
    required this.currentData,
  });

  final IcoState currentData;

  @override
  List<Object?> get props => [currentData];
}
