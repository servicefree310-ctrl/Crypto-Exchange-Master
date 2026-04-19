import 'package:equatable/equatable.dart';

// Enums for P2P Offer
enum P2PTradeType { buy, sell }

enum P2PPriceModel { fixed, margin }

enum P2POfferVisibility { public, private }

enum P2POfferStatus {
  draft,
  pendingApproval,
  active,
  paused,
  completed,
  cancelled,
  rejected,
  expired
}

enum P2PWalletType { fiat, spot, eco }

// Value Objects
class PriceConfiguration extends Equatable {
  const PriceConfiguration({
    required this.model,
    required this.value,
    this.marketPrice,
    required this.finalPrice,
  });

  final P2PPriceModel model;
  final double value;
  final double? marketPrice;
  final double finalPrice;

  @override
  List<Object?> get props => [model, value, marketPrice, finalPrice];

  PriceConfiguration copyWith({
    P2PPriceModel? model,
    double? value,
    double? marketPrice,
    double? finalPrice,
  }) {
    return PriceConfiguration(
      model: model ?? this.model,
      value: value ?? this.value,
      marketPrice: marketPrice ?? this.marketPrice,
      finalPrice: finalPrice ?? this.finalPrice,
    );
  }
}

class TradeSettings extends Equatable {
  const TradeSettings({
    required this.autoCancel,
    required this.kycRequired,
    required this.visibility,
    this.termsOfTrade,
    this.additionalNotes,
  });

  final int autoCancel; // Minutes
  final bool kycRequired;
  final P2POfferVisibility visibility;
  final String? termsOfTrade;
  final String? additionalNotes;

  @override
  List<Object?> get props => [
        autoCancel,
        kycRequired,
        visibility,
        termsOfTrade,
        additionalNotes,
      ];

  TradeSettings copyWith({
    int? autoCancel,
    bool? kycRequired,
    P2POfferVisibility? visibility,
    String? termsOfTrade,
    String? additionalNotes,
  }) {
    return TradeSettings(
      autoCancel: autoCancel ?? this.autoCancel,
      kycRequired: kycRequired ?? this.kycRequired,
      visibility: visibility ?? this.visibility,
      termsOfTrade: termsOfTrade ?? this.termsOfTrade,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }
}

class AmountConfiguration extends Equatable {
  const AmountConfiguration({
    required this.total,
    this.min,
    this.max,
    this.availableBalance,
  });

  final double total;
  final double? min;
  final double? max;
  final double? availableBalance;

  @override
  List<Object?> get props => [total, min, max, availableBalance];

  AmountConfiguration copyWith({
    double? total,
    double? min,
    double? max,
    double? availableBalance,
  }) {
    return AmountConfiguration(
      total: total ?? this.total,
      min: min ?? this.min,
      max: max ?? this.max,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }
}

class LocationSettings extends Equatable {
  const LocationSettings({
    this.country,
    this.region,
    this.city,
    this.restrictions,
  });

  final String? country;
  final String? region;
  final String? city;
  final List<String>? restrictions;

  @override
  List<Object?> get props => [country, region, city, restrictions];

  LocationSettings copyWith({
    String? country,
    String? region,
    String? city,
    List<String>? restrictions,
  }) {
    return LocationSettings(
      country: country ?? this.country,
      region: region ?? this.region,
      city: city ?? this.city,
      restrictions: restrictions ?? this.restrictions,
    );
  }
}

class UserRequirements extends Equatable {
  const UserRequirements({
    this.minCompletedTrades,
    this.minSuccessRate,
    this.minAccountAge,
    this.trustedOnly,
  });

  final int? minCompletedTrades;
  final double? minSuccessRate;
  final int? minAccountAge; // Days
  final bool? trustedOnly;

  @override
  List<Object?> get props => [
        minCompletedTrades,
        minSuccessRate,
        minAccountAge,
        trustedOnly,
      ];

  UserRequirements copyWith({
    int? minCompletedTrades,
    double? minSuccessRate,
    int? minAccountAge,
    bool? trustedOnly,
  }) {
    return UserRequirements(
      minCompletedTrades: minCompletedTrades ?? this.minCompletedTrades,
      minSuccessRate: minSuccessRate ?? this.minSuccessRate,
      minAccountAge: minAccountAge ?? this.minAccountAge,
      trustedOnly: trustedOnly ?? this.trustedOnly,
    );
  }
}

// Main P2P Offer Entity
class P2POfferEntity extends Equatable {
  const P2POfferEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.currency,
    required this.walletType,
    required this.amountConfig,
    required this.priceConfig,
    required this.tradeSettings,
    this.locationSettings,
    this.userRequirements,
    required this.status,
    required this.views,
    this.systemTags,
    this.adminNotes,
    this.paymentMethods,
    this.user,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String userId;
  final P2PTradeType type;
  final String currency;
  final P2PWalletType walletType;
  final AmountConfiguration amountConfig;
  final PriceConfiguration priceConfig;
  final TradeSettings tradeSettings;
  final LocationSettings? locationSettings;
  final UserRequirements? userRequirements;
  final P2POfferStatus status;
  final int views;
  final List<String>? systemTags;
  final String? adminNotes;
  final List<String>? paymentMethods; // Payment method IDs
  final Map<String, dynamic>? user; // User info from backend
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        currency,
        walletType,
        amountConfig,
        priceConfig,
        tradeSettings,
        locationSettings,
        userRequirements,
        status,
        views,
        systemTags,
        adminNotes,
        paymentMethods,
        user,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  P2POfferEntity copyWith({
    String? id,
    String? userId,
    P2PTradeType? type,
    String? currency,
    P2PWalletType? walletType,
    AmountConfiguration? amountConfig,
    PriceConfiguration? priceConfig,
    TradeSettings? tradeSettings,
    LocationSettings? locationSettings,
    UserRequirements? userRequirements,
    P2POfferStatus? status,
    int? views,
    List<String>? systemTags,
    String? adminNotes,
    List<String>? paymentMethods,
    Map<String, dynamic>? user,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return P2POfferEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      walletType: walletType ?? this.walletType,
      amountConfig: amountConfig ?? this.amountConfig,
      priceConfig: priceConfig ?? this.priceConfig,
      tradeSettings: tradeSettings ?? this.tradeSettings,
      locationSettings: locationSettings ?? this.locationSettings,
      userRequirements: userRequirements ?? this.userRequirements,
      status: status ?? this.status,
      views: views ?? this.views,
      systemTags: systemTags ?? this.systemTags,
      adminNotes: adminNotes ?? this.adminNotes,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Helper methods
  bool get isActive => status == P2POfferStatus.active;
  bool get isBuyOffer => type == P2PTradeType.buy;
  bool get isSellOffer => type == P2PTradeType.sell;
  bool get isPublic => tradeSettings.visibility == P2POfferVisibility.public;

  String get displayAmount {
    if (amountConfig.min != null && amountConfig.max != null) {
      return '${amountConfig.min!.toStringAsFixed(2)} - ${amountConfig.max!.toStringAsFixed(2)}';
    }
    return amountConfig.total.toStringAsFixed(2);
  }

  String get displayPrice => priceConfig.finalPrice.toStringAsFixed(2);

  double get marginPercentage {
    if (priceConfig.model == P2PPriceModel.margin &&
        priceConfig.marketPrice != null) {
      return ((priceConfig.finalPrice - priceConfig.marketPrice!) /
              priceConfig.marketPrice!) *
          100;
    }
    return 0.0;
  }
}
