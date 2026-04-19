import '../../domain/entities/ico_portfolio_entity.dart';
import 'ico_transaction_model.dart';

class IcoPortfolioModel {
  const IcoPortfolioModel({
    required this.totalInvested,
    required this.pendingInvested,
    required this.pendingVerificationInvested,
    required this.receivedInvested,
    required this.rejectedInvested,
    required this.currentValue,
    required this.totalProfitLoss,
    required this.roi,
  });

  final double totalInvested;
  final double pendingInvested;
  final double pendingVerificationInvested;
  final double receivedInvested;
  final double rejectedInvested;
  final double currentValue;
  final double totalProfitLoss;
  final double roi;

  factory IcoPortfolioModel.fromJson(Map<String, dynamic> json) {
    return IcoPortfolioModel(
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0.0,
      pendingInvested: (json['pendingInvested'] as num?)?.toDouble() ?? 0.0,
      pendingVerificationInvested:
          (json['pendingVerificationInvested'] as num?)?.toDouble() ?? 0.0,
      receivedInvested: (json['receivedInvested'] as num?)?.toDouble() ?? 0.0,
      rejectedInvested: (json['rejectedInvested'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      roi: (json['roi'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInvested': totalInvested,
      'pendingInvested': pendingInvested,
      'pendingVerificationInvested': pendingVerificationInvested,
      'receivedInvested': receivedInvested,
      'rejectedInvested': rejectedInvested,
      'currentValue': currentValue,
      'totalProfitLoss': totalProfitLoss,
      'roi': roi,
    };
  }

  IcoPortfolioEntity toEntity({List<IcoTransactionModel> transactions = const []}) {
    final investments = transactions.map((tx) {
      final tokenAmount = tx.price > 0 ? tx.amount / tx.price : 0.0;
      return IcoInvestmentEntity(
        id: tx.id,
        offeringId: tx.offeringId,
        offeringName: tx.offering?['name']?.toString() ?? '',
        offeringSymbol: tx.offering?['symbol']?.toString() ?? '',
        offeringIcon: tx.offering?['icon']?.toString() ?? '',
        investedAmount: tx.amount,
        tokenAmount: tokenAmount,
        pricePerToken: tx.price,
        currentValue: tx.amount,
        profitLoss: 0.0,
        profitLossPercentage: 0.0,
        investmentDate: tx.createdAt ?? DateTime.now(),
        status: _mapStatus(tx.status),
      );
    }).toList();

    final activeCount = investments.where((i) =>
        i.status == IcoTransactionStatus.pending ||
        i.status == IcoTransactionStatus.verification).length;
    final completedCount = investments.where((i) =>
        i.status == IcoTransactionStatus.released).length;

    return IcoPortfolioEntity(
      totalInvested: totalInvested,
      pendingInvested: pendingInvested,
      verificationInvested: pendingVerificationInvested,
      releasedValue: receivedInvested,
      totalProfitLoss: totalProfitLoss,
      profitLossPercentage: roi,
      totalTransactions: investments.length,
      activeInvestments: activeCount,
      completedInvestments: completedCount,
      investments: investments,
    );
  }

  static IcoTransactionStatus _mapStatus(String status) {
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
