import 'package:equatable/equatable.dart';
import '../../../domain/entities/p2p_offer_entity.dart';
import '../../../../../../../core/errors/failures.dart';

/// Base class for all offers states
abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is first created
class OffersInitial extends OffersState {
  const OffersInitial();
}

/// State when offers are being loaded
class OffersLoading extends OffersState {
  const OffersLoading({
    this.isRefresh = false,
    this.isLoadMore = false,
    this.existingOffers = const [],
  });

  final bool isRefresh; // True for pull-to-refresh
  final bool isLoadMore; // True for pagination
  final List<P2POfferEntity> existingOffers; // Existing offers during load more

  @override
  List<Object?> get props => [isRefresh, isLoadMore, existingOffers];
}

/// State when offers are successfully loaded
class OffersLoaded extends OffersState {
  const OffersLoaded({
    required this.offers,
    this.hasMore = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.appliedFilters,
    this.searchQuery,
    this.isRefreshing = false,
  });

  final List<P2POfferEntity> offers;
  final bool hasMore; // Whether more pages are available
  final int currentPage;
  final int totalCount;
  final OffersFilters? appliedFilters;
  final String? searchQuery;
  final bool isRefreshing; // True during refresh

  @override
  List<Object?> get props => [
        offers,
        hasMore,
        currentPage,
        totalCount,
        appliedFilters,
        searchQuery,
        isRefreshing,
      ];

  OffersLoaded copyWith({
    List<P2POfferEntity>? offers,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    OffersFilters? appliedFilters,
    String? searchQuery,
    bool? isRefreshing,
  }) {
    return OffersLoaded(
      offers: offers ?? this.offers,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// State when no offers are found
class OffersEmpty extends OffersState {
  const OffersEmpty({
    this.message = 'No offers found',
    this.appliedFilters,
    this.searchQuery,
  });

  final String message;
  final OffersFilters? appliedFilters;
  final String? searchQuery;

  @override
  List<Object?> get props => [message, appliedFilters, searchQuery];
}

/// State when an error occurs
class OffersError extends OffersState {
  const OffersError({
    required this.failure,
    this.existingOffers = const [],
    this.canRetry = true,
  });

  final Failure failure;
  final List<P2POfferEntity> existingOffers; // Preserve existing data on error
  final bool canRetry;

  @override
  List<Object?> get props => [failure, existingOffers, canRetry];
}

/// State when a single offer is being loaded
class OfferByIdLoading extends OffersState {
  const OfferByIdLoading(this.offerId);

  final String offerId;

  @override
  List<Object?> get props => [offerId];
}

/// State when a single offer is loaded
class OfferByIdLoaded extends OffersState {
  const OfferByIdLoaded(this.offer);

  final P2POfferEntity offer;

  @override
  List<Object?> get props => [offer];
}

/// State when single offer loading fails
class OfferByIdError extends OffersState {
  const OfferByIdError({
    required this.failure,
    required this.offerId,
  });

  final Failure failure;
  final String offerId;

  @override
  List<Object?> get props => [failure, offerId];
}

/// State when popular offers are loading
class PopularOffersLoading extends OffersState {
  const PopularOffersLoading();
}

/// State when popular offers are loaded
class PopularOffersLoaded extends OffersState {
  const PopularOffersLoaded(this.offers);

  final List<P2POfferEntity> offers;

  @override
  List<Object?> get props => [offers];
}

/// State when popular offers loading fails
class PopularOffersError extends OffersState {
  const PopularOffersError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// State when creating an offer
class CreateOfferLoading extends OffersState {
  const CreateOfferLoading();
}

/// State when offer creation succeeds
class CreateOfferSuccess extends OffersState {
  const CreateOfferSuccess(this.offer);

  final P2POfferEntity offer;

  @override
  List<Object?> get props => [offer];
}

/// State when offer creation fails
class CreateOfferError extends OffersState {
  const CreateOfferError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// State when loading offer details
class OfferDetailsLoading extends OffersState {
  const OfferDetailsLoading();
}

/// State when offer details are loaded
class OfferDetailsLoaded extends OffersState {
  const OfferDetailsLoaded(this.offer);

  final P2POfferEntity offer;

  @override
  List<Object?> get props => [offer];
}

/// State when offer details loading fails
class OfferDetailsError extends OffersState {
  const OfferDetailsError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Filters data class
class OffersFilters extends Equatable {
  const OffersFilters({
    this.type,
    this.currency,
    this.paymentMethods,
    this.minAmount,
    this.maxAmount,
    this.location,
    this.sortBy = 'newest',
  });

  final String? type; // 'buy' or 'sell'
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

  OffersFilters copyWith({
    String? type,
    String? currency,
    List<String>? paymentMethods,
    double? minAmount,
    double? maxAmount,
    String? location,
    String? sortBy,
  }) {
    return OffersFilters(
      type: type ?? this.type,
      currency: currency ?? this.currency,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      location: location ?? this.location,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return type != null ||
        currency != null ||
        (paymentMethods?.isNotEmpty ?? false) ||
        minAmount != null ||
        maxAmount != null ||
        location != null ||
        sortBy != 'newest';
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (type != null) map['type'] = type;
    if (currency != null) map['currency'] = currency;
    if (paymentMethods?.isNotEmpty ?? false) {
      map['paymentMethods'] = paymentMethods;
    }
    if (minAmount != null) map['minAmount'] = minAmount;
    if (maxAmount != null) map['maxAmount'] = maxAmount;
    if (location != null) map['location'] = location;
    if (sortBy != 'newest') map['sortBy'] = sortBy;
    return map;
  }
}
