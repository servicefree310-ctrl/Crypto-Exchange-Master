// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ico_blockchain_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IcoBlockchainModelImpl _$$IcoBlockchainModelImplFromJson(
        Map<String, dynamic> json) =>
    _$IcoBlockchainModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      chainId: json['chainId'] as String,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      explorerUrl: json['explorerUrl'] as String?,
      rpcUrl: json['rpcUrl'] as String?,
    );

Map<String, dynamic> _$$IcoBlockchainModelImplToJson(
        _$IcoBlockchainModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'symbol': instance.symbol,
      'chainId': instance.chainId,
      'icon': instance.icon,
      'isActive': instance.isActive,
      'explorerUrl': instance.explorerUrl,
      'rpcUrl': instance.rpcUrl,
    };
