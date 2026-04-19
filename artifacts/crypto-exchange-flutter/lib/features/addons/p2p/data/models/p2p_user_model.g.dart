// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$P2PUserModelImpl _$$P2PUserModelImplFromJson(Map<String, dynamic> json) =>
    _$P2PUserModelImpl(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      profile: json['profile'] as Map<String, dynamic>?,
      emailVerified: json['emailVerified'] as bool?,
      p2pTrades: (json['p2pTrades'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      receivedReviews: (json['receivedReviews'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$$P2PUserModelImplToJson(_$P2PUserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'avatar': instance.avatar,
      'profile': instance.profile,
      'emailVerified': instance.emailVerified,
      'p2pTrades': instance.p2pTrades,
      'receivedReviews': instance.receivedReviews,
    };
