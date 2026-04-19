import '../../domain/entities/ico_portfolio_entity.dart';

class IcoTransactionModel {
  const IcoTransactionModel({
    required this.id,
    required this.userId,
    required this.offeringId,
    required this.amount,
    required this.price,
    required this.status,
    this.releaseUrl,
    this.walletAddress,
    this.notes,
    this.createdAt,
    this.updatedAt,
    // Related data
    this.offering,
    this.user,
  });

  final String id;
  final String userId;
  final String offeringId;
  final double amount;
  final double price;
  final String status; // PENDING, VERIFICATION, RELEASED, REJECTED
  final String? releaseUrl;
  final String? walletAddress;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related entities
  final Map<String, dynamic>? offering;
  final Map<String, dynamic>? user;

  factory IcoTransactionModel.fromJson(Map<String, dynamic> json) {
    return IcoTransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      offeringId: json['offeringId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      releaseUrl: json['releaseUrl'] as String?,
      walletAddress: json['walletAddress'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      offering: json['offering'] as Map<String, dynamic>?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'offeringId': offeringId,
      'amount': amount,
      'price': price,
      'status': status,
      'releaseUrl': releaseUrl,
      'walletAddress': walletAddress,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'offering': offering,
      'user': user,
    };
  }

  IcoTransactionEntity toEntity() {
    return IcoTransactionEntity(
      id: id,
      offeringId: offeringId,
      offeringName: offering?['name'] as String? ?? '',
      offeringSymbol: offering?['symbol'] as String? ?? '',
      offeringIcon: offering?['icon'] as String? ?? '',
      amount: price > 0 ? amount / price : 0.0, // Token amount
      price: price, // Price per token
      totalCost: amount, // Total investment amount
      status: _mapStatus(status),
      createdAt: createdAt ?? DateTime.now(),
      walletAddress: walletAddress,
      releaseUrl: releaseUrl,
      notes: notes,
    );
  }

  IcoTransactionStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return IcoTransactionStatus.pending;
      case 'VERIFICATION':
        return IcoTransactionStatus.verification;
      case 'RELEASED':
        return IcoTransactionStatus.released;
      case 'REJECTED':
        return IcoTransactionStatus.rejected;
      default:
        return IcoTransactionStatus.pending;
    }
  }
}
