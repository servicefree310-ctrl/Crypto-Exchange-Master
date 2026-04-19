import 'package:equatable/equatable.dart';
import '../../domain/entities/ico_offering_entity.dart';

abstract class IcoEvent extends Equatable {
  const IcoEvent();

  @override
  List<Object?> get props => [];
}

class IcoLoadDashboardDataRequested extends IcoEvent {
  const IcoLoadDashboardDataRequested();
}

class IcoLoadOfferingsRequested extends IcoEvent {
  const IcoLoadOfferingsRequested({
    this.status,
    this.tokenType,
    this.blockchain,
    this.search,
    this.limit,
    this.offset,
  });

  final IcoOfferingStatus? status;
  final IcoTokenType? tokenType;
  final String? blockchain;
  final String? search;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props =>
      [status, tokenType, blockchain, search, limit, offset];
}

class IcoLoadOfferingDetailRequested extends IcoEvent {
  const IcoLoadOfferingDetailRequested(this.offeringId);

  final String offeringId;

  @override
  List<Object?> get props => [offeringId];
}

class IcoLoadFeaturedOfferingsRequested extends IcoEvent {
  const IcoLoadFeaturedOfferingsRequested();
}

class IcoLoadPortfolioRequested extends IcoEvent {
  const IcoLoadPortfolioRequested();
}

class IcoLoadTransactionsRequested extends IcoEvent {
  const IcoLoadTransactionsRequested({
    this.limit,
    this.offset,
  });

  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [limit, offset];
}

class IcoCreateInvestmentRequested extends IcoEvent {
  const IcoCreateInvestmentRequested({
    required this.offeringId,
    required this.amount,
    required this.walletAddress,
  });

  final String offeringId;
  final double amount;
  final String walletAddress;

  @override
  List<Object?> get props => [offeringId, amount, walletAddress];
}

class IcoLoadStatsRequested extends IcoEvent {
  const IcoLoadStatsRequested();
}

class IcoRefreshRequested extends IcoEvent {
  const IcoRefreshRequested();
}
