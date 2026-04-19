import 'p2p_offer_entity.dart';

class P2POffersResponse {
  final List<P2POfferEntity> offers;
  final P2PPagination pagination;
  final P2PFiltersApplied? filtersApplied;

  const P2POffersResponse({
    required this.offers,
    required this.pagination,
    this.filtersApplied,
  });
}

class P2PPagination {
  final int totalItems;
  final int currentPage;
  final int perPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const P2PPagination({
    required this.totalItems,
    required this.currentPage,
    required this.perPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory P2PPagination.fromMap(Map<String, dynamic> map) {
    final totalItems = map['totalItems'] ?? 0;
    final currentPage = map['currentPage'] ?? 1;
    final perPage = map['perPage'] ?? 10;
    final totalPages = map['totalPages'] ?? 1;

    return P2PPagination(
      totalItems: totalItems,
      currentPage: currentPage,
      perPage: perPage,
      totalPages: totalPages,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    );
  }
}

class P2PFiltersApplied {
  final int activeFiltersCount;
  final List<String> appliedFilters;
  final Map<String, dynamic> filterValues;

  const P2PFiltersApplied({
    required this.activeFiltersCount,
    required this.appliedFilters,
    required this.filterValues,
  });
}
