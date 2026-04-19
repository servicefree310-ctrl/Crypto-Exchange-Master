// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_trade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$P2PTradeModelImpl _$$P2PTradeModelImplFromJson(Map<String, dynamic> json) =>
    _$P2PTradeModelImpl(
      id: json['id'] as String,
      offerId: json['offerId'] as String,
      buyerUserId: json['buyerUserId'] as String,
      sellerUserId: json['sellerUserId'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      tradeType: json['tradeType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      lastResponseAt: json['lastResponseAt'] == null
          ? null
          : DateTime.parse(json['lastResponseAt'] as String),
      referenceNumber: json['referenceNumber'] as String?,
      chatRoomId: json['chatRoomId'] as String?,
      escrowId: json['escrowId'] as String?,
      disputeId: json['disputeId'] as String?,
      paymentProof: json['paymentProof'] as String?,
      buyerNote: json['buyerNote'] as String?,
      sellerNote: json['sellerNote'] as String?,
      adminNote: json['adminNote'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      offer: json['offer'] == null
          ? null
          : P2POfferModel.fromJson(json['offer'] as Map<String, dynamic>),
      buyer: json['buyer'] == null
          ? null
          : P2PUserModel.fromJson(json['buyer'] as Map<String, dynamic>),
      seller: json['seller'] == null
          ? null
          : P2PUserModel.fromJson(json['seller'] as Map<String, dynamic>),
      paymentMethod: json['paymentMethod'] == null
          ? null
          : P2PPaymentMethodModel.fromJson(
              json['paymentMethod'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => P2PTradeMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: (json['timeline'] as List<dynamic>?)
          ?.map(
              (e) => P2PTradeTimelineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$P2PTradeModelImplToJson(_$P2PTradeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offerId': instance.offerId,
      'buyerUserId': instance.buyerUserId,
      'sellerUserId': instance.sellerUserId,
      'currency': instance.currency,
      'amount': instance.amount,
      'price': instance.price,
      'total': instance.total,
      'status': instance.status,
      'tradeType': instance.tradeType,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'lastResponseAt': instance.lastResponseAt?.toIso8601String(),
      'referenceNumber': instance.referenceNumber,
      'chatRoomId': instance.chatRoomId,
      'escrowId': instance.escrowId,
      'disputeId': instance.disputeId,
      'paymentProof': instance.paymentProof,
      'buyerNote': instance.buyerNote,
      'sellerNote': instance.sellerNote,
      'adminNote': instance.adminNote,
      'metadata': instance.metadata,
      'offer': instance.offer,
      'buyer': instance.buyer,
      'seller': instance.seller,
      'paymentMethod': instance.paymentMethod,
      'messages': instance.messages,
      'timeline': instance.timeline,
    };

_$P2PTradeMessageModelImpl _$$P2PTradeMessageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PTradeMessageModelImpl(
      id: json['id'] as String,
      tradeId: json['tradeId'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileType: json['fileType'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      isSystemMessage: json['isSystemMessage'] as bool?,
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$P2PTradeMessageModelImplToJson(
        _$P2PTradeMessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tradeId': instance.tradeId,
      'userId': instance.userId,
      'message': instance.message,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'isSystemMessage': instance.isSystemMessage,
      'isRead': instance.isRead,
      'metadata': instance.metadata,
    };

_$P2PTradeTimelineModelImpl _$$P2PTradeTimelineModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PTradeTimelineModelImpl(
      id: json['id'] as String,
      tradeId: json['tradeId'] as String,
      action: json['action'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      note: json['note'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$P2PTradeTimelineModelImplToJson(
        _$P2PTradeTimelineModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tradeId': instance.tradeId,
      'action': instance.action,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'note': instance.note,
      'metadata': instance.metadata,
    };
