import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/ico_repository.dart';
import '../../domain/entities/ico_offering_entity.dart';
import '../../domain/entities/ico_portfolio_entity.dart';
import '../../domain/entities/portfolio_performance_point_entity.dart';
import '../../domain/entities/ico_stats_entity.dart';
import 'ico_event.dart';
import 'ico_state.dart';
import 'package:dartz/dartz.dart';

@injectable
class IcoBloc extends Bloc<IcoEvent, IcoState> {
  IcoBloc(this._repository) : super(const IcoInitial()) {
    on<IcoLoadDashboardDataRequested>(_onLoadDashboardData);
    on<IcoLoadOfferingsRequested>(_onLoadOfferings);
    on<IcoLoadOfferingDetailRequested>(_onLoadOfferingDetail);
    on<IcoLoadFeaturedOfferingsRequested>(_onLoadFeaturedOfferings);
    on<IcoLoadPortfolioRequested>(_onLoadPortfolio);
    on<IcoLoadTransactionsRequested>(_onLoadTransactions);
    on<IcoCreateInvestmentRequested>(_onCreateInvestment);
    on<IcoLoadStatsRequested>(_onLoadStats);
    on<IcoRefreshRequested>(_onRefresh);
  }

  final IcoRepository _repository;

  Future<void> _onLoadDashboardData(
    IcoLoadDashboardDataRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    try {
      // Load all dashboard data in parallel
      final results = await Future.wait([
        _repository.getFeaturedOfferings(),
        _repository.getPortfolio(),
        _repository.getTransactions(limit: 5),
        _repository.getIcoStats(),
      ]);

      final featuredResult = results[0];
      final portfolioResult = results[1];
      final transactionsResult = results[2];
      final statsResult = results[3];

      // Check if any request failed
      if (featuredResult.isLeft() ||
          portfolioResult.isLeft() ||
          transactionsResult.isLeft() ||
          statsResult.isLeft()) {
        // Get the first error message
        String errorMessage = 'Failed to load dashboard data';

        if (featuredResult.isLeft()) {
          featuredResult.fold(
              (failure) => errorMessage = failure.message, (_) {});
        } else if (portfolioResult.isLeft()) {
          portfolioResult.fold(
              (failure) => errorMessage = failure.message, (_) {});
        } else if (transactionsResult.isLeft()) {
          transactionsResult.fold(
              (failure) => errorMessage = failure.message, (_) {});
        } else if (statsResult.isLeft()) {
          statsResult.fold((failure) => errorMessage = failure.message, (_) {});
        }

        emit(IcoError(message: errorMessage));
        return;
      }

      // Extract successful data
      List<IcoOfferingEntity> featuredOfferings = [];
      IcoPortfolioEntity? portfolio;
      List<IcoTransactionEntity> transactions = [];
      IcoStatsEntity? stats;

      featuredResult.fold(
        (l) => {},
        (r) => featuredOfferings = r as List<IcoOfferingEntity>,
      );

      portfolioResult.fold(
        (l) => {},
        (r) => portfolio = r as IcoPortfolioEntity,
      );

      transactionsResult.fold(
        (l) => {},
        (r) => transactions = r as List<IcoTransactionEntity>,
      );

      statsResult.fold(
        (l) => {},
        (r) => stats = r as IcoStatsEntity,
      );

      emit(IcoDashboardLoaded(
        featuredOfferings: featuredOfferings,
        portfolio: portfolio!,
        recentTransactions: transactions,
        stats: stats!,
      ));
    } catch (e) {
      emit(IcoError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOfferings(
    IcoLoadOfferingsRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final result = await _repository.getOfferings(
      status: event.status,
      tokenType: event.tokenType,
      blockchain: event.blockchain,
      search: event.search,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(IcoError(message: failure.message)),
      (offerings) => emit(IcoOfferingsLoaded(
        offerings: offerings,
        hasMore: offerings.length == (event.limit ?? 20),
      )),
    );
  }

  Future<void> _onLoadOfferingDetail(
    IcoLoadOfferingDetailRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final result = await _repository.getOfferingById(event.offeringId);

    result.fold(
      (failure) => emit(IcoError(message: failure.message)),
      (offering) => emit(IcoOfferingDetailLoaded(offering: offering)),
    );
  }

  Future<void> _onLoadFeaturedOfferings(
    IcoLoadFeaturedOfferingsRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final result = await _repository.getFeaturedOfferings();

    result.fold(
      (failure) => emit(IcoError(message: failure.message)),
      (offerings) => emit(IcoOfferingsLoaded(offerings: offerings)),
    );
  }

  Future<void> _onLoadPortfolio(
    IcoLoadPortfolioRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final portfolioRes = await _repository.getPortfolio();
    final perfRes = await _repository.getPortfolioPerformance(timeframe: '1M');

    if (portfolioRes.isLeft()) {
      portfolioRes.fold(
          (failure) => emit(IcoError(message: failure.message)), (_) {});
      return;
    }
    final IcoPortfolioEntity portfolio = (portfolioRes as Right).value;

    List<PortfolioPerformancePointEntity> points = [];
    perfRes.fold((l) => {}, (r) => points = r);

    emit(IcoPortfolioLoaded(portfolio: portfolio, performance: points));
  }

  Future<void> _onLoadTransactions(
    IcoLoadTransactionsRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final result = await _repository.getTransactions(
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(IcoError(message: failure.message)),
      (transactions) => emit(IcoTransactionsLoaded(
        transactions: transactions,
        hasMore: transactions.length == (event.limit ?? 20),
      )),
    );
  }

  Future<void> _onCreateInvestment(
    IcoCreateInvestmentRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final result = await _repository.createInvestment(
      offeringId: event.offeringId,
      amount: event.amount,
      walletAddress: event.walletAddress,
    );

    result.fold(
      (failure) => emit(IcoError(message: failure.message)),
      (transaction) => emit(IcoInvestmentCreated(transaction: transaction)),
    );
  }

  Future<void> _onLoadStats(
    IcoLoadStatsRequested event,
    Emitter<IcoState> emit,
  ) async {
    emit(const IcoLoading());

    final result = await _repository.getIcoStats();

    result.fold(
      (failure) => emit(IcoError(message: failure.message)),
      (stats) => emit(IcoStatsLoaded(stats: stats)),
    );
  }

  Future<void> _onRefresh(
    IcoRefreshRequested event,
    Emitter<IcoState> emit,
  ) async {
    // For refresh, we reload dashboard data
    add(const IcoLoadDashboardDataRequested());
  }
}
