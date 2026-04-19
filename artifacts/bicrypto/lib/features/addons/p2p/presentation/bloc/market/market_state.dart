import 'package:equatable/equatable.dart';
import '../../../domain/entities/p2p_market_stats_entity.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class P2PMarketState extends Equatable {
  const P2PMarketState();
  @override
  List<Object?> get props => [];
}

class P2PMarketInitial extends P2PMarketState {
  const P2PMarketInitial();
}

class P2PMarketLoading extends P2PMarketState {
  const P2PMarketLoading({this.isRefresh = false});
  final bool isRefresh;
  @override
  List<Object?> get props => [isRefresh];
}

class P2PMarketLoaded extends P2PMarketState {
  const P2PMarketLoaded({
    required this.stats,
    required this.highlights,
    required this.topCryptos,
  });

  final P2PMarketStatsEntity stats;
  final List<P2PMarketHighlightEntity> highlights;
  final List<P2PTopCryptoEntity> topCryptos;

  @override
  List<Object?> get props => [stats, highlights, topCryptos];
}

class P2PMarketError extends P2PMarketState {
  const P2PMarketError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
