import 'package:equatable/equatable.dart';

class CreatorInvestorEntity extends Equatable {
  const CreatorInvestorEntity({
    required this.userId,
    required this.offeringId,
    required this.totalCost,
    required this.rejectedCost,
    required this.totalTokens,
    required this.lastTransactionDate,
    required this.user,
    required this.offering,
  });

  final String userId;
  final String offeringId;
  final double totalCost;
  final double rejectedCost;
  final double totalTokens;
  final DateTime lastTransactionDate;
  final InvestorUserEntity user;
  final InvestorOfferingEntity offering;

  @override
  List<Object?> get props => [
        userId,
        offeringId,
        totalCost,
        rejectedCost,
        totalTokens,
        lastTransactionDate,
        user,
        offering,
      ];
}

class InvestorUserEntity extends Equatable {
  const InvestorUserEntity({
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  final String firstName;
  final String lastName;
  final String? avatar;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [firstName, lastName, avatar];
}

class InvestorOfferingEntity extends Equatable {
  const InvestorOfferingEntity({
    required this.name,
    required this.symbol,
    this.icon,
  });

  final String name;
  final String symbol;
  final String? icon;

  @override
  List<Object?> get props => [name, symbol, icon];
}
