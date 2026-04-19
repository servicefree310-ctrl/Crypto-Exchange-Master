// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$P2POfferModelImpl _$$P2POfferModelImplFromJson(Map<String, dynamic> json) =>
    _$P2POfferModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      currency: json['currency'] as String,
      walletType: json['walletType'] as String,
      amountConfig: json['amountConfig'] as Map<String, dynamic>,
      priceConfig: json['priceConfig'] as Map<String, dynamic>,
      tradeSettings: json['tradeSettings'] as Map<String, dynamic>,
      locationSettings: json['locationSettings'] as Map<String, dynamic>?,
      userRequirements: json['userRequirements'] as Map<String, dynamic>?,
      status: json['status'] as String,
      views: (json['views'] as num).toInt(),
      systemTags: (json['systemTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      adminNotes: json['adminNotes'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      deletedAt: json['deletedAt'] as String?,
      user: json['user'] == null
          ? null
          : P2PUserModel.fromJson(json['user'] as Map<String, dynamic>),
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map(
              (e) => P2PPaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      flag: json['flag'] == null
          ? null
          : P2POfferFlagModel.fromJson(json['flag'] as Map<String, dynamic>),
      trades: (json['trades'] as List<dynamic>?)
          ?.map((e) => P2PTradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$P2POfferModelImplToJson(_$P2POfferModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'currency': instance.currency,
      'walletType': instance.walletType,
      'amountConfig': instance.amountConfig,
      'priceConfig': instance.priceConfig,
      'tradeSettings': instance.tradeSettings,
      'locationSettings': instance.locationSettings,
      'userRequirements': instance.userRequirements,
      'status': instance.status,
      'views': instance.views,
      'systemTags': instance.systemTags,
      'adminNotes': instance.adminNotes,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
      'user': instance.user,
      'paymentMethods': instance.paymentMethods,
      'flag': instance.flag,
      'trades': instance.trades,
    };

_$P2POfferFlagModelImpl _$$P2POfferFlagModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2POfferFlagModelImpl(
      id: json['id'] as String,
      offerId: json['offerId'] as String,
      userId: json['userId'] as String,
      reason: json['reason'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$P2POfferFlagModelImplToJson(
        _$P2POfferFlagModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offerId': instance.offerId,
      'userId': instance.userId,
      'reason': instance.reason,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
