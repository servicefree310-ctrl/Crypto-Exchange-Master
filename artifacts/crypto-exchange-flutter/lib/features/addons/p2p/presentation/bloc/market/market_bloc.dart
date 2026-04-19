import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import 'market_event.dart';
import 'market_state.dart';
import '../../../domain/usecases/market/get_p2p_market_stats_usecase.dart';
import '../../../domain/usecases/market/get_p2p_market_highlights_usecase.dart';
import '../../../domain/usecases/market/get_p2p_top_cryptos_usecase.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/p2p_market_stats_entity.dart';

@injectable
class P2PMarketBloc extends Bloc<P2PMarketEvent, P2PMarketState> {
  P2PMarketBloc(
    this._getStats,
    this._getHighlights,
    this._getTopCryptos,
  ) : super(const P2PMarketInitial()) {
    on<P2PMarketRequested>(_onRequested);
    on<P2PMarketRetryRequested>(_onRetry);
  }

  final GetP2PMarketStatsUseCase _getStats;
  final GetP2PMarketHighlightsUseCase _getHighlights;
  final GetP2PTopCryptosUseCase _getTopCryptos;

  Future<void> _onRequested(
    P2PMarketRequested event,
    Emitter<P2PMarketState> emit,
  ) async {
    if (event.refresh && state is P2PMarketLoaded) {
      emit(const P2PMarketLoading(isRefresh: true));
    } else {
      emit(const P2PMarketLoading());
    }

    // Parallel requests
    final statsFuture = _getStats(const NoParams());
    final highlightsFuture = _getHighlights(const NoParams());
    final topFuture = _getTopCryptos(const NoParams());

    final results = await Future.wait([
      statsFuture,
      highlightsFuture,
      topFuture,
    ]);

    final Either<Failure, P2PMarketStatsEntity> statsResult =
        results[0] as Either<Failure, P2PMarketStatsEntity>;
    final Either<Failure, List<P2PMarketHighlightEntity>> highlightsResult =
        results[1] as Either<Failure, List<P2PMarketHighlightEntity>>;
    final Either<Failure, List<P2PTopCryptoEntity>> topResult =
        results[2] as Either<Failure, List<P2PTopCryptoEntity>>;

    // Collect first failure if any
    Failure? failure;
    P2PMarketStatsEntity? stats;
    List<P2PMarketHighlightEntity>? highlights;
    List<P2PTopCryptoEntity>? topCryptos;

    statsResult.fold((f) => failure ??= f, (s) => stats = s);
    highlightsResult.fold((f) => failure ??= f, (h) => highlights = h);
    topResult.fold((f) => failure ??= f, (t) => topCryptos = t);

    if (failure != null) {
      emit(P2PMarketError(failure!));
    } else {
      emit(P2PMarketLoaded(
        stats: stats!,
        highlights: highlights!,
        topCryptos: topCryptos!,
      ));
    }
  }

  Future<void> _onRetry(
    P2PMarketRetryRequested event,
    Emitter<P2PMarketState> emit,
  ) async {
    add(const P2PMarketRequested());
  }
}
