import 'package:equatable/equatable.dart';

class IcoPortfolioEntity extends Equatable {
  const IcoPortfolioEntity({
    required this.totalInvested,
    required this.pendingInvested,
    required this.verificationInvested,
    required this.releasedValue,
    required this.totalProfitLoss,
    required this.profitLossPercentage,
    required this.totalTransactions,
    required this.activeInvestments,
    required this.completedInvestments,
    required this.investments,
  });

  final double totalInvested;
  final double pendingInvested;
  final double verificationInvested;
  final double releasedValue;
  final double totalProfitLoss;
  final double profitLossPercentage;
  final int totalTransactions;
  final int activeInvestments;
  final int completedInvestments;
  final List<IcoInvestmentEntity> investments;

  bool get hasInvestments => investments.isNotEmpty;
  bool get isProfitable => totalProfitLoss > 0;

  @override
  List<Object?> get props => [
        totalInvested,
        pendingInvested,
        verificationInvested,
        releasedValue,
        totalProfitLoss,
        profitLossPercentage,
        totalTransactions,
        activeInvestments,
        completedInvestments,
        investments,
      ];

  IcoPortfolioEntity copyWith({
    double? totalInvested,
    double? pendingInvested,
    double? verificationInvested,
    double? releasedValue,
    double? totalProfitLoss,
    double? profitLossPercentage,
    int? totalTransactions,
    int? activeInvestments,
    int? completedInvestments,
    List<IcoInvestmentEntity>? investments,
  }) {
    return IcoPortfolioEntity(
      totalInvested: totalInvested ?? this.totalInvested,
      pendingInvested: pendingInvested ?? this.pendingInvested,
      verificationInvested: verificationInvested ?? this.verificationInvested,
      releasedValue: releasedValue ?? this.releasedValue,
      totalProfitLoss: totalProfitLoss ?? this.totalProfitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      activeInvestments: activeInvestments ?? this.activeInvestments,
      completedInvestments: completedInvestments ?? this.completedInvestments,
      investments: investments ?? this.investments,
    );
  }
}

class IcoInvestmentEntity extends Equatable {
  const IcoInvestmentEntity({
    required this.id,
    this.offeringId,
    required this.offeringName,
    required this.offeringSymbol,
    required this.offeringIcon,
    required this.investedAmount,
    required this.tokenAmount,
    required this.pricePerToken,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.investmentDate,
    required this.status,
  });

  final String id;
  final String? offeringId;
  final String offeringName;
  final String offeringSymbol;
  final String offeringIcon;
  final double investedAmount;
  final double tokenAmount;
  final double pricePerToken;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercentage;
  final DateTime investmentDate;
  final IcoTransactionStatus status;

  bool get isProfitable => profitLoss > 0;
  bool get isReleased => status == IcoTransactionStatus.released;

  @override
  List<Object?> get props => [
        id,
        offeringId,
        offeringName,
        offeringSymbol,
        offeringIcon,
        investedAmount,
        tokenAmount,
        pricePerToken,
        currentValue,
        profitLoss,
        profitLossPercentage,
        investmentDate,
        status,
      ];

  IcoInvestmentEntity copyWith({
    String? id,
    String? offeringId,
    String? offeringName,
    String? offeringSymbol,
    String? offeringIcon,
    double? investedAmount,
    double? tokenAmount,
    double? pricePerToken,
    double? currentValue,
    double? profitLoss,
    double? profitLossPercentage,
    DateTime? investmentDate,
    IcoTransactionStatus? status,
  }) {
    return IcoInvestmentEntity(
      id: id ?? this.id,
      offeringId: offeringId ?? this.offeringId,
      offeringName: offeringName ?? this.offeringName,
      offeringSymbol: offeringSymbol ?? this.offeringSymbol,
      offeringIcon: offeringIcon ?? this.offeringIcon,
      investedAmount: investedAmount ?? this.investedAmount,
      tokenAmount: tokenAmount ?? this.tokenAmount,
      pricePerToken: pricePerToken ?? this.pricePerToken,
      currentValue: currentValue ?? this.currentValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      investmentDate: investmentDate ?? this.investmentDate,
      status: status ?? this.status,
    );
  }
}

enum IcoTransactionStatus {
  pending,
  verification,
  released,
  rejected,
}

class IcoTransactionEntity extends Equatable {
  const IcoTransactionEntity({
    required this.id,
    required this.offeringId,
    required this.offeringName,
    required this.offeringSymbol,
    required this.offeringIcon,
    required this.amount,
    required this.price,
    required this.totalCost,
    required this.status,
    required this.createdAt,
    this.walletAddress,
    this.releaseUrl,
    this.notes,
  });

  final String id;
  final String offeringId;
  final String offeringName;
  final String offeringSymbol;
  final String offeringIcon;
  final double amount; // Token amount
  final double price; // Price per token
  final double totalCost; // Total investment amount
  final IcoTransactionStatus status;
  final DateTime createdAt;
  final String? walletAddress;
  final String? releaseUrl;
  final String? notes;

  String get statusText {
    switch (status) {
      case IcoTransactionStatus.pending:
        return 'Pending';
      case IcoTransactionStatus.verification:
        return 'Verification';
      case IcoTransactionStatus.released:
        return 'Released';
      case IcoTransactionStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isCompleted => status == IcoTransactionStatus.released;
  bool get isPending => status == IcoTransactionStatus.pending;
  bool get isInVerification => status == IcoTransactionStatus.verification;
  bool get isRejected => status == IcoTransactionStatus.rejected;

  @override
  List<Object?> get props => [
        id,
        offeringId,
        offeringName,
        offeringSymbol,
        offeringIcon,
        amount,
        price,
        totalCost,
        status,
        createdAt,
        walletAddress,
        releaseUrl,
        notes,
      ];

  IcoTransactionEntity copyWith({
    String? id,
    String? offeringId,
    String? offeringName,
    String? offeringSymbol,
    String? offeringIcon,
    double? amount,
    double? price,
    double? totalCost,
    IcoTransactionStatus? status,
    DateTime? createdAt,
    String? walletAddress,
    String? releaseUrl,
    String? notes,
  }) {
    return IcoTransactionEntity(
      id: id ?? this.id,
      offeringId: offeringId ?? this.offeringId,
      offeringName: offeringName ?? this.offeringName,
      offeringSymbol: offeringSymbol ?? this.offeringSymbol,
      offeringIcon: offeringIcon ?? this.offeringIcon,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      walletAddress: walletAddress ?? this.walletAddress,
      releaseUrl: releaseUrl ?? this.releaseUrl,
      notes: notes ?? this.notes,
    );
  }
}
