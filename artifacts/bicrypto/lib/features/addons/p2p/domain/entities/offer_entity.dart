import 'package:equatable/equatable.dart';

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
    required this.locationSettings,
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
  final String type; // BUY, SELL
  final String currency;
  final String walletType; // FIAT, SPOT, ECO
  final AmountConfigEntity amountConfig;
  final PriceConfigEntity priceConfig;
  final TradeSettingsEntity tradeSettings;
  final LocationSettingsEntity locationSettings;
  final UserRequirementsEntity? userRequirements;
  final String status; // DRAFT, PENDING_APPROVAL, ACTIVE, etc.
  final int views;
  final List<String>? systemTags;
  final String? adminNotes;
  final List<PaymentMethodEntity>? paymentMethods;
  final UserEntity? user;
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
    String? type,
    String? currency,
    String? walletType,
    AmountConfigEntity? amountConfig,
    PriceConfigEntity? priceConfig,
    TradeSettingsEntity? tradeSettings,
    LocationSettingsEntity? locationSettings,
    UserRequirementsEntity? userRequirements,
    String? status,
    int? views,
    List<String>? systemTags,
    String? adminNotes,
    List<PaymentMethodEntity>? paymentMethods,
    UserEntity? user,
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
}

class AmountConfigEntity extends Equatable {
  const AmountConfigEntity({
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

  AmountConfigEntity copyWith({
    double? total,
    double? min,
    double? max,
    double? availableBalance,
  }) {
    return AmountConfigEntity(
      total: total ?? this.total,
      min: min ?? this.min,
      max: max ?? this.max,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }
}

class PriceConfigEntity extends Equatable {
  const PriceConfigEntity({
    required this.model,
    required this.value,
    this.marketPrice,
    required this.finalPrice,
  });

  final String model; // FIXED, MARGIN
  final double value;
  final double? marketPrice;
  final double finalPrice;

  @override
  List<Object?> get props => [model, value, marketPrice, finalPrice];

  PriceConfigEntity copyWith({
    String? model,
    double? value,
    double? marketPrice,
    double? finalPrice,
  }) {
    return PriceConfigEntity(
      model: model ?? this.model,
      value: value ?? this.value,
      marketPrice: marketPrice ?? this.marketPrice,
      finalPrice: finalPrice ?? this.finalPrice,
    );
  }
}

class TradeSettingsEntity extends Equatable {
  const TradeSettingsEntity({
    required this.autoCancel,
    required this.kycRequired,
    required this.visibility,
    required this.termsOfTrade,
    this.additionalNotes,
  });

  final int autoCancel; // minutes
  final bool kycRequired;
  final String visibility; // PUBLIC, PRIVATE
  final String termsOfTrade;
  final String? additionalNotes;

  @override
  List<Object?> get props => [
        autoCancel,
        kycRequired,
        visibility,
        termsOfTrade,
        additionalNotes,
      ];

  TradeSettingsEntity copyWith({
    int? autoCancel,
    bool? kycRequired,
    String? visibility,
    String? termsOfTrade,
    String? additionalNotes,
  }) {
    return TradeSettingsEntity(
      autoCancel: autoCancel ?? this.autoCancel,
      kycRequired: kycRequired ?? this.kycRequired,
      visibility: visibility ?? this.visibility,
      termsOfTrade: termsOfTrade ?? this.termsOfTrade,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }
}

class LocationSettingsEntity extends Equatable {
  const LocationSettingsEntity({
    required this.country,
    this.region,
    this.city,
    this.restrictions,
  });

  final String country;
  final String? region;
  final String? city;
  final List<String>? restrictions;

  @override
  List<Object?> get props => [country, region, city, restrictions];

  LocationSettingsEntity copyWith({
    String? country,
    String? region,
    String? city,
    List<String>? restrictions,
  }) {
    return LocationSettingsEntity(
      country: country ?? this.country,
      region: region ?? this.region,
      city: city ?? this.city,
      restrictions: restrictions ?? this.restrictions,
    );
  }
}

class UserRequirementsEntity extends Equatable {
  const UserRequirementsEntity({
    this.minCompletedTrades,
    this.minSuccessRate,
    this.minAccountAge,
    this.trustedOnly,
  });

  final int? minCompletedTrades;
  final double? minSuccessRate;
  final int? minAccountAge; // days
  final bool? trustedOnly;

  @override
  List<Object?> get props => [
        minCompletedTrades,
        minSuccessRate,
        minAccountAge,
        trustedOnly,
      ];

  UserRequirementsEntity copyWith({
    int? minCompletedTrades,
    double? minSuccessRate,
    int? minAccountAge,
    bool? trustedOnly,
  }) {
    return UserRequirementsEntity(
      minCompletedTrades: minCompletedTrades ?? this.minCompletedTrades,
      minSuccessRate: minSuccessRate ?? this.minSuccessRate,
      minAccountAge: minAccountAge ?? this.minAccountAge,
      trustedOnly: trustedOnly ?? this.trustedOnly,
    );
  }
}

class PaymentMethodEntity extends Equatable {
  const PaymentMethodEntity({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.isActive,
  });

  final String id;
  final String name;
  final String? icon;
  final String? description;
  final bool? isActive;

  @override
  List<Object?> get props => [id, name, icon, description, isActive];

  PaymentMethodEntity copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    bool? isActive,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.avatar,
    this.profile,
    this.emailVerified,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatar;
  final dynamic profile;
  final bool? emailVerified;

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        avatar,
        profile,
        emailVerified,
      ];

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    dynamic profile,
    bool? emailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      profile: profile ?? this.profile,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
