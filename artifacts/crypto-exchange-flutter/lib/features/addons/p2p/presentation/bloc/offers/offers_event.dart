import 'package:equatable/equatable.dart';

/// Base class for all offers-related events
abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load offers list with optional filters
class OffersLoadRequested extends OffersEvent {
  const OffersLoadRequested({
    this.type,
    this.currency,
    this.paymentMethods,
    this.minAmount,
    this.maxAmount,
    this.location,
    this.sortBy = 'newest',
    this.page = 1,
    this.limit = 20,
    this.refresh = false,
  });

  final String? type; // 'buy' or 'sell'
  final String? currency;
  final List<String>? paymentMethods;
  final double? minAmount;
  final double? maxAmount;
  final String? location;
  final String sortBy; // 'newest', 'price-low', 'price-high', 'reputation'
  final int page;
  final int limit;
  final bool refresh; // For pull-to-refresh

  @override
  List<Object?> get props => [
        type,
        currency,
        paymentMethods,
        minAmount,
        maxAmount,
        location,
        sortBy,
        page,
        limit,
        refresh,
      ];
}

/// Event to load more offers (pagination)
class OffersLoadMoreRequested extends OffersEvent {
  const OffersLoadMoreRequested();
}

/// Event to refresh offers list
class OffersRefreshRequested extends OffersEvent {
  const OffersRefreshRequested();
}

/// Event to apply filters to offers
class OffersFiltersApplied extends OffersEvent {
  const OffersFiltersApplied({
    this.type,
    this.currency,
    this.paymentMethods,
    this.minAmount,
    this.maxAmount,
    this.location,
    this.sortBy = 'newest',
  });

  final String? type;
  final String? currency;
  final List<String>? paymentMethods;
  final double? minAmount;
  final double? maxAmount;
  final String? location;
  final String sortBy;

  @override
  List<Object?> get props => [
        type,
        currency,
        paymentMethods,
        minAmount,
        maxAmount,
        location,
        sortBy,
      ];
}

/// Event to clear all filters
class OffersFiltersClearRequested extends OffersEvent {
  const OffersFiltersClearRequested();
}

/// Event to search offers by keyword
class OffersSearchRequested extends OffersEvent {
  const OffersSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to load a specific offer by ID
class OfferLoadByIdRequested extends OffersEvent {
  const OfferLoadByIdRequested(this.offerId);

  final String offerId;

  @override
  List<Object?> get props => [offerId];
}

/// Event to load popular offers
class PopularOffersLoadRequested extends OffersEvent {
  const PopularOffersLoadRequested({
    this.limit = 10,
  });

  final int limit;

  @override
  List<Object?> get props => [limit];
}

/// Event to retry failed operations
class OffersRetryRequested extends OffersEvent {
  const OffersRetryRequested();
}

/// Event to create a new offer
class CreateOfferRequested extends OffersEvent {
  const CreateOfferRequested({required this.offerData});

  final Map<String, dynamic> offerData;

  @override
  List<Object?> get props => [offerData];
}

/// Event to load offer details by ID
class LoadOfferDetailsRequested extends OffersEvent {
  const LoadOfferDetailsRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Event for V5-style guided matching using /api/p2p/guided-matching
class GuidedMatchingRequested extends OffersEvent {
  const GuidedMatchingRequested({required this.criteria});

  final Map<String, dynamic> criteria;

  @override
  List<Object?> get props => [criteria];
}
