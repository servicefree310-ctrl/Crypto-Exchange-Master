import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/p2p_trade_entity.dart';
import 'p2p_offer_model.dart';
import 'p2p_user_model.dart';
import 'p2p_payment_method_model.dart';

part 'p2p_trade_model.freezed.dart';
part 'p2p_trade_model.g.dart';

@freezed
class P2PTradeModel with _$P2PTradeModel {
  const factory P2PTradeModel({
    required String id,
    required String offerId,
    required String buyerUserId,
    required String sellerUserId,
    required String currency,
    required double amount,
    required double price,
    required double total,
    required String status,
    required String tradeType,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    DateTime? lastResponseAt,
    String? referenceNumber,
    String? chatRoomId,
    String? escrowId,
    String? disputeId,
    String? paymentProof,
    String? buyerNote,
    String? sellerNote,
    String? adminNote,
    Map<String, dynamic>? metadata,
    P2POfferModel? offer,
    P2PUserModel? buyer,
    P2PUserModel? seller,
    P2PPaymentMethodModel? paymentMethod,
    List<P2PTradeMessageModel>? messages,
    List<P2PTradeTimelineModel>? timeline,
  }) = _P2PTradeModel;

  factory P2PTradeModel.fromJson(Map<String, dynamic> json) =>
      _$P2PTradeModelFromJson(json);
}

@freezed
class P2PTradeMessageModel with _$P2PTradeMessageModel {
  const factory P2PTradeMessageModel({
    required String id,
    required String tradeId,
    required String userId,
    required String message,
    required String type,
    required DateTime createdAt,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    bool? isSystemMessage,
    @Default(false) bool isRead,
    Map<String, dynamic>? metadata,
  }) = _P2PTradeMessageModel;

  factory P2PTradeMessageModel.fromJson(Map<String, dynamic> json) =>
      _$P2PTradeMessageModelFromJson(json);
}

@freezed
class P2PTradeTimelineModel with _$P2PTradeTimelineModel {
  const factory P2PTradeTimelineModel({
    required String id,
    required String tradeId,
    required String action,
    required String status,
    required DateTime timestamp,
    String? userId,
    String? note,
    Map<String, dynamic>? metadata,
  }) = _P2PTradeTimelineModel;

  factory P2PTradeTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$P2PTradeTimelineModelFromJson(json);
}

extension P2PTradeModelX on P2PTradeModel {
  P2PTradeEntity toEntity() {
    return P2PTradeEntity(
      id: id,
      offerId: offerId,
      buyerId: buyerUserId,
      sellerId: sellerUserId,
      type: P2PTradeType.values.firstWhere(
        (t) => t.name.toLowerCase() == tradeType.toLowerCase(),
        orElse: () => P2PTradeType.buy,
      ),
      currency: currency,
      amount: amount,
      price: price,
      fiatAmount: total,
      status: P2PTradeStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == status.toLowerCase(),
        orElse: () => P2PTradeStatus.pending,
      ),
      paymentReference: referenceNumber,
      paymentProof: paymentProof != null ? [paymentProof!] : null,
      completedAt: completedAt,
      expiresAt: expiresAt,
      buyer: buyer?.toJson(),
      seller: seller?.toJson(),
      offer: offer?.toJson(),
      paymentMethod: paymentMethod?.name,
      messages: messages?.map((m) => m.toJson()).toList(),
      timeline: timeline?.map((t) => t.toJson()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension P2PTradeMessageModelX on P2PTradeMessageModel {
  P2PTradeMessageEntity toEntity() {
    return P2PTradeMessageEntity(
      id: id,
      tradeId: tradeId,
      senderId: userId,
      content: message,
      messageType: type,
      createdAt: createdAt,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      isRead: isRead,
    );
  }
}

extension P2PTradeTimelineModelX on P2PTradeTimelineModel {
  P2PTradeTimelineEntity toEntity() {
    return P2PTradeTimelineEntity(
      id: id,
      tradeId: tradeId,
      title: action,
      description: note ?? status,
      status: status,
      metadata: metadata,
      createdAt: timestamp,
    );
  }
}
