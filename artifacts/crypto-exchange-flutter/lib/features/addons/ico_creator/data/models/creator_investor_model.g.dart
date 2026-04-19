// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_investor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatorInvestorModelImpl _$$CreatorInvestorModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreatorInvestorModelImpl(
      userId: json['userId'] as String,
      offeringId: json['offeringId'] as String,
      totalCost: (json['totalCost'] as num).toDouble(),
      rejectedCost: (json['rejectedCost'] as num).toDouble(),
      totalTokens: (json['totalTokens'] as num).toDouble(),
      lastTransactionDate:
          DateTime.parse(json['lastTransactionDate'] as String),
      user: InvestorUserModel.fromJson(json['user'] as Map<String, dynamic>),
      offering: InvestorOfferingModel.fromJson(
          json['offering'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CreatorInvestorModelImplToJson(
        _$CreatorInvestorModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'offeringId': instance.offeringId,
      'totalCost': instance.totalCost,
      'rejectedCost': instance.rejectedCost,
      'totalTokens': instance.totalTokens,
      'lastTransactionDate': instance.lastTransactionDate.toIso8601String(),
      'user': instance.user,
      'offering': instance.offering,
    };

_$InvestorUserModelImpl _$$InvestorUserModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InvestorUserModelImpl(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$InvestorUserModelImplToJson(
        _$InvestorUserModelImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'avatar': instance.avatar,
    };

_$InvestorOfferingModelImpl _$$InvestorOfferingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InvestorOfferingModelImpl(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$$InvestorOfferingModelImplToJson(
        _$InvestorOfferingModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'icon': instance.icon,
    };
