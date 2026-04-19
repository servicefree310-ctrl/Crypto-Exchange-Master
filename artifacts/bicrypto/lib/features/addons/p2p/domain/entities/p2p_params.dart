// Shared parameter types for P2P operations

class GetOffersParams {
  final String? type; // BUY or SELL
  final String? currency;
  final String? walletType; // FIAT, SPOT, ECO
  final double? amount;
  final double? minAmount;
  final double? maxAmount;
  final double? minPrice;
  final double? maxPrice;
  final String? paymentMethod;
  final String? location;
  final String? country;
  final String? region;
  final bool? kycRequired;
  final String? visibility; // PUBLIC, PRIVATE
  final int? minCompletedTrades;
  final double? minSuccessRate;
  final bool? trustedOnly;
  final bool? verifiedOnly;

  // Pagination
  final int? page;
  final int? perPage;

  // Sorting
  final String? sortField;
  final String? sortOrder; // asc, desc

  // Advanced filters
  final String? status; // ACTIVE, INACTIVE, PENDING_APPROVAL
  final List<String>? paymentMethodIds;
  final bool? onlineOnly;
  final String? search; // Search in terms, notes, etc.

  const GetOffersParams({
    this.type,
    this.currency,
    this.walletType,
    this.amount,
    this.minAmount,
    this.maxAmount,
    this.minPrice,
    this.maxPrice,
    this.paymentMethod,
    this.location,
    this.country,
    this.region,
    this.kycRequired,
    this.visibility,
    this.minCompletedTrades,
    this.minSuccessRate,
    this.trustedOnly,
    this.verifiedOnly,
    this.page = 1,
    this.perPage = 10,
    this.sortField = 'createdAt',
    this.sortOrder = 'desc',
    this.status,
    this.paymentMethodIds,
    this.onlineOnly,
    this.search,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (type != null) map['type'] = type;
    if (currency != null) map['currency'] = currency;
    if (walletType != null) map['walletType'] = walletType;
    if (amount != null) map['amount'] = amount;
    if (minAmount != null) map['minAmount'] = minAmount;
    if (maxAmount != null) map['maxAmount'] = maxAmount;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (paymentMethod != null) map['paymentMethod'] = paymentMethod;
    if (location != null) map['location'] = location;
    if (country != null) map['country'] = country;
    if (region != null) map['region'] = region;
    if (kycRequired != null) map['kycRequired'] = kycRequired;
    if (visibility != null) map['visibility'] = visibility;
    if (minCompletedTrades != null) {
      map['minCompletedTrades'] = minCompletedTrades;
    }
    if (minSuccessRate != null) map['minSuccessRate'] = minSuccessRate;
    if (trustedOnly != null) map['trustedOnly'] = trustedOnly;
    if (verifiedOnly != null) map['verifiedOnly'] = verifiedOnly;
    if (page != null) map['page'] = page;
    if (perPage != null) map['perPage'] = perPage;
    if (sortField != null) map['sortField'] = sortField;
    if (sortOrder != null) map['sortOrder'] = sortOrder;
    if (status != null) map['status'] = status;
    if (paymentMethodIds != null) map['paymentMethodIds'] = paymentMethodIds;
    if (onlineOnly != null) map['onlineOnly'] = onlineOnly;
    if (search != null) map['search'] = search;

    return map;
  }
}

class CreateOfferParams {
  final String type;
  final String currency;
  final String walletType;
  final Map<String, dynamic> amountConfig;
  final Map<String, dynamic> priceConfig;
  final Map<String, dynamic> tradeSettings;
  final Map<String, dynamic>? locationSettings;
  final Map<String, dynamic>? userRequirements;
  final List<String>? paymentMethodIds;

  const CreateOfferParams({
    required this.type,
    required this.currency,
    required this.walletType,
    required this.amountConfig,
    required this.priceConfig,
    required this.tradeSettings,
    this.locationSettings,
    this.userRequirements,
    this.paymentMethodIds,
  });
}

// Additional parameter classes for use cases

class GetOfferByIdParams {
  final String offerId;
  final bool includeSellerStats;
  final bool includeFlagDetails;

  const GetOfferByIdParams({
    required this.offerId,
    this.includeSellerStats = true,
    this.includeFlagDetails = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': offerId,
      'includeSellerStats': includeSellerStats,
      'includeFlagDetails': includeFlagDetails,
    };
  }
}

class GetPopularOffersParams {
  final int limit;
  final String? currency;
  final String? type; // BUY or SELL
  final double? minPopularityScore;

  const GetPopularOffersParams({
    this.limit = 10,
    this.currency,
    this.type,
    this.minPopularityScore,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'limit': limit,
    };

    if (currency != null) map['currency'] = currency;
    if (type != null) map['type'] = type;
    if (minPopularityScore != null) {
      map['minPopularityScore'] = minPopularityScore;
    }

    return map;
  }
}

class UpdateOfferParams {
  final String offerId;
  final CreateOfferParams updateData;
  final bool validateOwnership;
  final String? reason;

  const UpdateOfferParams({
    required this.offerId,
    required this.updateData,
    this.validateOwnership = true,
    this.reason,
  });
}

class DeleteOfferParams {
  final String offerId;
  final String? reason;

  const DeleteOfferParams({
    required this.offerId,
    this.reason,
  });
}
