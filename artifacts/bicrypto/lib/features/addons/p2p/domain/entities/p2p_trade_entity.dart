import 'package:equatable/equatable.dart';

// Enums for P2P Trade
enum P2PTradeStatus {
  pending,
  inProgress,
  paymentSent,
  completed,
  cancelled,
  disputed,
  expired
}

enum P2PTradeType { buy, sell }

// P2P Trade Entity
class P2PTradeEntity extends Equatable {
  const P2PTradeEntity({
    required this.id,
    required this.offerId,
    required this.buyerId,
    required this.sellerId,
    required this.type,
    required this.currency,
    required this.amount,
    required this.price,
    required this.fiatAmount,
    required this.status,
    this.paymentMethod,
    this.paymentDetails,
    this.disputeReason,
    this.disputeDetails,
    this.completedAt,
    this.cancelledAt,
    this.disputedAt,
    this.expiresAt,
    this.buyer,
    this.seller,
    this.offer,
    this.dispute,
    this.messages,
    this.timeline,
    this.escrowAmount,
    this.escrowFee,
    this.paymentReference,
    this.paymentProof,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String offerId;
  final String buyerId;
  final String sellerId;
  final P2PTradeType type;
  final String currency;
  final double amount;
  final double price;
  final double fiatAmount;
  final P2PTradeStatus status;
  final String? paymentMethod;
  final Map<String, dynamic>? paymentDetails;
  final String? disputeReason;
  final String? disputeDetails;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? disputedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? buyer; // User info
  final Map<String, dynamic>? seller; // User info
  final Map<String, dynamic>? offer; // Offer info
  final Map<String, dynamic>? dispute; // Dispute info
  final List<Map<String, dynamic>>? messages; // Trade messages
  final List<Map<String, dynamic>>? timeline; // Trade timeline
  final double? escrowAmount;
  final double? escrowFee;
  final String? paymentReference;
  final List<String>? paymentProof; // URLs to proof images
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        offerId,
        buyerId,
        sellerId,
        type,
        currency,
        amount,
        price,
        fiatAmount,
        status,
        paymentMethod,
        paymentDetails,
        disputeReason,
        disputeDetails,
        completedAt,
        cancelledAt,
        disputedAt,
        expiresAt,
        buyer,
        seller,
        offer,
        dispute,
        messages,
        timeline,
        escrowAmount,
        escrowFee,
        paymentReference,
        paymentProof,
        createdAt,
        updatedAt,
      ];

  P2PTradeEntity copyWith({
    String? id,
    String? offerId,
    String? buyerId,
    String? sellerId,
    P2PTradeType? type,
    String? currency,
    double? amount,
    double? price,
    double? fiatAmount,
    P2PTradeStatus? status,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
    String? disputeReason,
    String? disputeDetails,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? disputedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? buyer,
    Map<String, dynamic>? seller,
    Map<String, dynamic>? offer,
    Map<String, dynamic>? dispute,
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? timeline,
    double? escrowAmount,
    double? escrowFee,
    String? paymentReference,
    List<String>? paymentProof,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return P2PTradeEntity(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      fiatAmount: fiatAmount ?? this.fiatAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      disputeReason: disputeReason ?? this.disputeReason,
      disputeDetails: disputeDetails ?? this.disputeDetails,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      disputedAt: disputedAt ?? this.disputedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      offer: offer ?? this.offer,
      dispute: dispute ?? this.dispute,
      messages: messages ?? this.messages,
      timeline: timeline ?? this.timeline,
      escrowAmount: escrowAmount ?? this.escrowAmount,
      escrowFee: escrowFee ?? this.escrowFee,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentProof: paymentProof ?? this.paymentProof,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isActive => status == P2PTradeStatus.inProgress;
  bool get isCompleted => status == P2PTradeStatus.completed;
  bool get isCancelled => status == P2PTradeStatus.cancelled;
  bool get isDisputed => status == P2PTradeStatus.disputed;
  bool get isPending => status == P2PTradeStatus.pending;
  bool get isPaymentSent => status == P2PTradeStatus.paymentSent;
  bool get isExpired => status == P2PTradeStatus.expired;

  bool get isBuyTrade => type == P2PTradeType.buy;
  bool get isSellTrade => type == P2PTradeType.sell;

  bool get hasExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  String get displayTimeRemaining {
    final remaining = timeRemaining;
    if (remaining == null) return 'No time limit';
    if (remaining == Duration.zero) return 'Expired';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get displayStatus {
    switch (status) {
      case P2PTradeStatus.pending:
        return 'Pending';
      case P2PTradeStatus.inProgress:
        return 'In Progress';
      case P2PTradeStatus.paymentSent:
        return 'Payment Sent';
      case P2PTradeStatus.completed:
        return 'Completed';
      case P2PTradeStatus.cancelled:
        return 'Cancelled';
      case P2PTradeStatus.disputed:
        return 'Disputed';
      case P2PTradeStatus.expired:
        return 'Expired';
    }
  }

  String get displayAmount => '${amount.toStringAsFixed(8)} $currency';
  String get displayFiatAmount => fiatAmount.toStringAsFixed(2);
  String get displayPrice => price.toStringAsFixed(2);

  double get totalWithFees {
    final base = fiatAmount;
    final fees = escrowFee ?? 0.0;
    return base + fees;
  }
}

// Trade Message Entity
class P2PTradeMessageEntity extends Equatable {
  const P2PTradeMessageEntity({
    required this.id,
    required this.tradeId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String tradeId;
  final String senderId;
  final String content;
  final String messageType; // text, image, file, system
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final bool isRead;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        tradeId,
        senderId,
        content,
        messageType,
        fileUrl,
        fileName,
        fileSize,
        isRead,
        createdAt,
      ];

  P2PTradeMessageEntity copyWith({
    String? id,
    String? tradeId,
    String? senderId,
    String? content,
    String? messageType,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return P2PTradeMessageEntity(
      id: id ?? this.id,
      tradeId: tradeId ?? this.tradeId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isSystemMessage => messageType == 'system';
  bool get isFileMessage => messageType == 'file' || messageType == 'image';
  bool get isTextMessage => messageType == 'text';
}

// Trade Timeline Entity
class P2PTradeTimelineEntity extends Equatable {
  const P2PTradeTimelineEntity({
    required this.id,
    required this.tradeId,
    required this.title,
    required this.description,
    required this.status,
    this.metadata,
    required this.createdAt,
  });

  final String id;
  final String tradeId;
  final String title;
  final String description;
  final String status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        tradeId,
        title,
        description,
        status,
        metadata,
        createdAt,
      ];

  P2PTradeTimelineEntity copyWith({
    String? id,
    String? tradeId,
    String? title,
    String? description,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return P2PTradeTimelineEntity(
      id: id ?? this.id,
      tradeId: tradeId ?? this.tradeId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
