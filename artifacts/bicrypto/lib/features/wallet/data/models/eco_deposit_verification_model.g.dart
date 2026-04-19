// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eco_deposit_verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoDepositVerificationModelImpl _$$EcoDepositVerificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EcoDepositVerificationModelImpl(
      status: json['status'] as String,
      message: json['message'] as String,
      transaction: json['transaction'] == null
          ? null
          : EcoTransactionModel.fromJson(
              json['transaction'] as Map<String, dynamic>),
      wallet: json['wallet'] == null
          ? null
          : EcoWalletModel.fromJson(json['wallet'] as Map<String, dynamic>),
      trx: json['trx'] as Map<String, dynamic>?,
      balance: (json['balance'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      chain: json['chain'] as String?,
      method: json['method'] as String?,
    );

Map<String, dynamic> _$$EcoDepositVerificationModelImplToJson(
        _$EcoDepositVerificationModelImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'transaction': instance.transaction,
      'wallet': instance.wallet,
      'trx': instance.trx,
      'balance': instance.balance,
      'currency': instance.currency,
      'chain': instance.chain,
      'method': instance.method,
    };
