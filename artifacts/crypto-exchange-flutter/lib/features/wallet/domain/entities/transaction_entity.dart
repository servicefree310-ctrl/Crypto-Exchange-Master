import 'package:equatable/equatable.dart';
import 'wallet_entity.dart';

enum TransactionType {
  DEPOSIT,
  WITHDRAW,
  TRANSFER,
  INCOMING_TRANSFER,
  OUTGOING_TRANSFER,
  TRADE,
  BINARY_ORDER,
  EXCHANGE_ORDER,
  FOREX_DEPOSIT,
  FOREX_WITHDRAW,
  ICO_CONTRIBUTION,
  BONUS,
  FEE,
  STAKING_REWARD,
  STAKING_STAKE,
  STAKING_UNSTAKE,
  REFERRAL_REWARD,
  AI_INVESTMENT,
  P2P_TRADE,
  FUTURES_ORDER,
  SPOT_ORDER,
  ECO_TRANSFER,
  OTHER,
}

enum TransactionStatus {
  PENDING,
  COMPLETED,
  CANCELLED,
  FAILED,
  PROCESSING,
  REJECTED,
  EXPIRED,
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String walletId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double fee;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? referenceId;
  final String? trxId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related entities
  final WalletEntity? wallet;
  final Map<String, dynamic>? user;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    this.description,
    this.metadata,
    this.referenceId,
    this.trxId,
    required this.createdAt,
    required this.updatedAt,
    this.wallet,
    this.user,
  });

  // Computed properties
  bool get isPending => status == TransactionStatus.PENDING;
  bool get isCompleted => status == TransactionStatus.COMPLETED;
  bool get isFailed =>
      status == TransactionStatus.FAILED ||
      status == TransactionStatus.REJECTED;
  bool get isProcessing => status == TransactionStatus.PROCESSING;

  bool get isDeposit => type == TransactionType.DEPOSIT;
  bool get isWithdraw => type == TransactionType.WITHDRAW;
  bool get isTransfer =>
      type == TransactionType.TRANSFER ||
      type == TransactionType.INCOMING_TRANSFER ||
      type == TransactionType.OUTGOING_TRANSFER;
  bool get isTrade =>
      type == TransactionType.TRADE ||
      type == TransactionType.EXCHANGE_ORDER ||
      type == TransactionType.SPOT_ORDER ||
      type == TransactionType.FUTURES_ORDER;

  double get netAmount => amount - fee;

  String get walletCurrency => wallet?.currency ?? 'Unknown';
  WalletType? get walletType => wallet?.type;

  String get displayTitle {
    switch (type) {
      case TransactionType.DEPOSIT:
        return 'Deposit';
      case TransactionType.WITHDRAW:
        return 'Withdraw';
      case TransactionType.TRANSFER:
        return 'Transfer';
      case TransactionType.INCOMING_TRANSFER:
        return 'Received';
      case TransactionType.OUTGOING_TRANSFER:
        return 'Sent';
      case TransactionType.TRADE:
      case TransactionType.EXCHANGE_ORDER:
      case TransactionType.SPOT_ORDER:
        return 'Trade';
      case TransactionType.FUTURES_ORDER:
        return 'Futures Trade';
      case TransactionType.STAKING_REWARD:
        return 'Staking Reward';
      case TransactionType.STAKING_STAKE:
        return 'Staking';
      case TransactionType.REFERRAL_REWARD:
        return 'Referral Bonus';
      case TransactionType.BONUS:
        return 'Bonus';
      case TransactionType.FEE:
        return 'Fee';
      case TransactionType.ICO_CONTRIBUTION:
        return 'ICO Investment';
      case TransactionType.AI_INVESTMENT:
        return 'AI Investment';
      case TransactionType.P2P_TRADE:
        return 'P2P Trade';
      default:
        return type.name
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String get statusDisplayText {
    switch (status) {
      case TransactionStatus.PENDING:
        return 'Pending';
      case TransactionStatus.COMPLETED:
        return 'Completed';
      case TransactionStatus.CANCELLED:
        return 'Cancelled';
      case TransactionStatus.FAILED:
        return 'Failed';
      case TransactionStatus.PROCESSING:
        return 'Processing';
      case TransactionStatus.REJECTED:
        return 'Rejected';
      case TransactionStatus.EXPIRED:
        return 'Expired';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        walletId,
        type,
        status,
        amount,
        fee,
        description,
        metadata,
        referenceId,
        trxId,
        createdAt,
        updatedAt,
        wallet,
        user,
      ];

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? walletId,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    double? fee,
    String? description,
    Map<String, dynamic>? metadata,
    String? referenceId,
    String? trxId,
    DateTime? createdAt,
    DateTime? updatedAt,
    WalletEntity? wallet,
    Map<String, dynamic>? user,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      referenceId: referenceId ?? this.referenceId,
      trxId: trxId ?? this.trxId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wallet: wallet ?? this.wallet,
      user: user ?? this.user,
    );
  }
}

class TransactionFilterEntity extends Equatable {
  final String? walletType;
  final String? currency;
  final TransactionType? type;
  final TransactionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  const TransactionFilterEntity({
    this.walletType,
    this.currency,
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.search,
  });

  @override
  List<Object?> get props => [
        walletType,
        currency,
        type,
        status,
        startDate,
        endDate,
        search,
      ];

  TransactionFilterEntity copyWith({
    String? walletType,
    String? currency,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  }) {
    return TransactionFilterEntity(
      walletType: walletType ?? this.walletType,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      search: search ?? this.search,
    );
  }

  TransactionFilterEntity clearFilter({
    bool clearWalletType = false,
    bool clearCurrency = false,
    bool clearType = false,
    bool clearStatus = false,
    bool clearDateRange = false,
    bool clearSearch = false,
  }) {
    return TransactionFilterEntity(
      walletType: clearWalletType ? null : walletType,
      currency: clearCurrency ? null : currency,
      type: clearType ? null : type,
      status: clearStatus ? null : status,
      startDate: clearDateRange ? null : startDate,
      endDate: clearDateRange ? null : endDate,
      search: clearSearch ? null : search,
    );
  }

  bool get hasActiveFilters =>
      walletType != null ||
      currency != null ||
      type != null ||
      status != null ||
      startDate != null ||
      endDate != null ||
      (search != null && search!.isNotEmpty);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (walletType != null) params['walletType'] = walletType;
    if (currency != null) params['currency'] = currency;
    if (type != null) params['type'] = type!.name;
    if (status != null) params['status'] = status!.name;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (search != null && search!.isNotEmpty) params['search'] = search;

    return params;
  }
}
