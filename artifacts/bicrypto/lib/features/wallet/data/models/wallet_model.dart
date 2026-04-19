import '../../domain/entities/wallet_entity.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.currency,
    required super.balance,
    required super.inOrder,
    super.address,
    super.icon,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: _parseWalletType(json['type'] as String),
      currency: json['currency'] as String,
      balance: _parseDouble(json['balance']),
      inOrder: _parseDouble(json['inOrder']),
      address: _parseAddress(json['address']),
      icon: json['icon'] as String?, // ECO wallets have icon from v5
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'currency': currency,
      'balance': balance,
      'inOrder': inOrder,
      'address': address,
      'icon': icon,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      currency: entity.currency,
      balance: entity.balance,
      inOrder: entity.inOrder,
      address: entity.address,
      icon: entity.icon,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  WalletModel copyWith({
    String? id,
    String? userId,
    WalletType? type,
    String? currency,
    double? balance,
    double? inOrder,
    Map<String, dynamic>? address,
    String? icon,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      inOrder: inOrder ?? this.inOrder,
      address: address ?? this.address,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static WalletType _parseWalletType(String typeString) {
    switch (typeString.toUpperCase()) {
      case 'FIAT':
        return WalletType.FIAT;
      case 'SPOT':
        return WalletType.SPOT;
      case 'ECO':
        return WalletType.ECO;
      case 'FUTURES':
        return WalletType.FUTURES;
      default:
        return WalletType.SPOT; // Default fallback
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Map<String, dynamic>? _parseAddress(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is String) {
      try {
        // V5 sometimes returns JSON string for address field
        return Map<String, dynamic>.from(
            const JsonDecoder().convert(value) as Map);
      } catch (e) {
        dev.log('🔴 WALLET_MODEL: Error parsing address JSON: $e');
        return null;
      }
    }

    return null;
  }

  /// Convert to entity (returns self since WalletModel extends WalletEntity)
  WalletEntity toEntity() {
    return WalletEntity(
      id: id,
      userId: userId,
      type: type,
      currency: currency,
      balance: balance,
      inOrder: inOrder,
      address: address,
      icon: icon,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
