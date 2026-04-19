import 'package:equatable/equatable.dart';

enum WalletType { FIAT, SPOT, ECO, FUTURES }

class WalletEntity extends Equatable {
  final String id;
  final String userId;
  final WalletType type;
  final String currency;
  final double balance;
  final double inOrder;
  final Map<String, dynamic>? address; // For ECO wallets multi-chain addresses
  final String? icon; // ECO token icon from v5 backend
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.currency,
    required this.balance,
    required this.inOrder,
    this.address,
    this.icon,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  double get availableBalance => balance - inOrder;

  bool get isEcoWallet => type == WalletType.ECO;

  bool get hasMultiChainAddress => isEcoWallet && address != null && address!.isNotEmpty;
  
  bool get hasIcon => icon != null && icon!.isNotEmpty;
  
  String get displayIcon => icon ?? '/img/crypto/${currency.toLowerCase()}.webp';

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        currency,
        balance,
        inOrder,
        address,
        icon,
        status,
        createdAt,
        updatedAt,
      ];

  WalletEntity copyWith({
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
    return WalletEntity(
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

  @override
  String toString() {
    return 'WalletEntity(id: $id, type: $type, currency: $currency, balance: $balance, icon: $icon)';
  }
} 