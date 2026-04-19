import '../../domain/entities/investor_entity.dart';

class InvestorModel {
  InvestorModel({
    required this.userId,
    required this.offeringId,
    required this.firstName,
    required this.lastName,
    required this.avatar,
    required this.offeringName,
    required this.offeringSymbol,
    required this.offeringIcon,
    required this.totalCost,
    required this.rejectedCost,
    required this.totalTokens,
    required this.lastTransactionDate,
  });

  final String userId;
  final String offeringId;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String offeringName;
  final String offeringSymbol;
  final String? offeringIcon;
  final double totalCost;
  final double rejectedCost;
  final double totalTokens;
  final DateTime lastTransactionDate;

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final offering = json['offering'] as Map<String, dynamic>? ?? {};
    return InvestorModel(
      userId: json['userId'].toString(),
      offeringId: json['offeringId'].toString(),
      firstName: user['firstName'] ?? '',
      lastName: user['lastName'] ?? '',
      avatar: user['avatar'] as String?,
      offeringName: offering['name'] ?? '',
      offeringSymbol: offering['symbol'] ?? '',
      offeringIcon: offering['icon'] as String?,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      rejectedCost: (json['rejectedCost'] as num?)?.toDouble() ?? 0,
      totalTokens: (json['totalTokens'] as num?)?.toDouble() ?? 0,
      lastTransactionDate:
          DateTime.tryParse(json['lastTransactionDate'] ?? '') ??
              DateTime.now(),
    );
  }

  InvestorEntity toEntity() => InvestorEntity(
        userId: userId,
        offeringId: offeringId,
        firstName: firstName,
        lastName: lastName,
        avatar: avatar,
        offeringName: offeringName,
        offeringSymbol: offeringSymbol,
        offeringIcon: offeringIcon,
        totalCost: totalCost,
        rejectedCost: rejectedCost,
        totalTokens: totalTokens,
        lastTransactionDate: lastTransactionDate,
      );
}
