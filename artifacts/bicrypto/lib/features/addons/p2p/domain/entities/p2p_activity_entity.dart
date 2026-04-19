import 'package:equatable/equatable.dart';

/// P2P Activity Entity
///
/// Represents a trading activity log entry
/// Based on v5 backend activity log structure
class P2PActivityEntity extends Equatable {
  const P2PActivityEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.tradeId,
    this.offerId,
    this.details,
    required this.createdAt,
  });

  /// Unique identifier
  final String id;

  /// User ID who performed the activity
  final String userId;

  /// Activity type
  final P2PActivityType type;

  /// Activity message/description
  final String message;

  /// Related trade ID (if applicable)
  final String? tradeId;

  /// Related offer ID (if applicable)
  final String? offerId;

  /// Additional activity details
  final Map<String, dynamic>? details;

  /// Activity timestamp
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        message,
        tradeId,
        offerId,
        details,
        createdAt,
      ];

  P2PActivityEntity copyWith({
    String? id,
    String? userId,
    P2PActivityType? type,
    String? message,
    String? tradeId,
    String? offerId,
    Map<String, dynamic>? details,
    DateTime? createdAt,
  }) {
    return P2PActivityEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      message: message ?? this.message,
      tradeId: tradeId ?? this.tradeId,
      offerId: offerId ?? this.offerId,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// P2P Activity Types
enum P2PActivityType {
  /// Offer-related activities
  offerCreated,
  offerUpdated,
  offerActivated,
  offerDeactivated,
  offerDeleted,

  /// Trade-related activities
  tradeInitiated,
  tradeAccepted,
  paymentSent,
  paymentConfirmed,
  escrowReleased,
  tradeCompleted,
  tradeCancelled,
  tradeDisputed,

  /// Review activities
  reviewSubmitted,
  reviewReceived,

  /// Payment method activities
  paymentMethodAdded,
  paymentMethodUpdated,
  paymentMethodRemoved,

  /// System activities
  systemNotification,
  warningIssued,
  accountSuspended,
  accountReinstated,

  /// Other activities
  other,
}

/// Extension for activity type display
extension P2PActivityTypeExtension on P2PActivityType {
  String get displayName {
    switch (this) {
      case P2PActivityType.offerCreated:
        return 'Offer Created';
      case P2PActivityType.offerUpdated:
        return 'Offer Updated';
      case P2PActivityType.offerActivated:
        return 'Offer Activated';
      case P2PActivityType.offerDeactivated:
        return 'Offer Deactivated';
      case P2PActivityType.offerDeleted:
        return 'Offer Deleted';
      case P2PActivityType.tradeInitiated:
        return 'Trade Initiated';
      case P2PActivityType.tradeAccepted:
        return 'Trade Accepted';
      case P2PActivityType.paymentSent:
        return 'Payment Sent';
      case P2PActivityType.paymentConfirmed:
        return 'Payment Confirmed';
      case P2PActivityType.escrowReleased:
        return 'Escrow Released';
      case P2PActivityType.tradeCompleted:
        return 'Trade Completed';
      case P2PActivityType.tradeCancelled:
        return 'Trade Cancelled';
      case P2PActivityType.tradeDisputed:
        return 'Trade Disputed';
      case P2PActivityType.reviewSubmitted:
        return 'Review Submitted';
      case P2PActivityType.reviewReceived:
        return 'Review Received';
      case P2PActivityType.paymentMethodAdded:
        return 'Payment Method Added';
      case P2PActivityType.paymentMethodUpdated:
        return 'Payment Method Updated';
      case P2PActivityType.paymentMethodRemoved:
        return 'Payment Method Removed';
      case P2PActivityType.systemNotification:
        return 'System Notification';
      case P2PActivityType.warningIssued:
        return 'Warning Issued';
      case P2PActivityType.accountSuspended:
        return 'Account Suspended';
      case P2PActivityType.accountReinstated:
        return 'Account Reinstated';
      case P2PActivityType.other:
        return 'Other Activity';
    }
  }

  String get category {
    switch (this) {
      case P2PActivityType.offerCreated:
      case P2PActivityType.offerUpdated:
      case P2PActivityType.offerActivated:
      case P2PActivityType.offerDeactivated:
      case P2PActivityType.offerDeleted:
        return 'Offers';
      case P2PActivityType.tradeInitiated:
      case P2PActivityType.tradeAccepted:
      case P2PActivityType.paymentSent:
      case P2PActivityType.paymentConfirmed:
      case P2PActivityType.escrowReleased:
      case P2PActivityType.tradeCompleted:
      case P2PActivityType.tradeCancelled:
      case P2PActivityType.tradeDisputed:
        return 'Trades';
      case P2PActivityType.reviewSubmitted:
      case P2PActivityType.reviewReceived:
        return 'Reviews';
      case P2PActivityType.paymentMethodAdded:
      case P2PActivityType.paymentMethodUpdated:
      case P2PActivityType.paymentMethodRemoved:
        return 'Payment Methods';
      case P2PActivityType.systemNotification:
      case P2PActivityType.warningIssued:
      case P2PActivityType.accountSuspended:
      case P2PActivityType.accountReinstated:
      case P2PActivityType.other:
        return 'System';
    }
  }
}
