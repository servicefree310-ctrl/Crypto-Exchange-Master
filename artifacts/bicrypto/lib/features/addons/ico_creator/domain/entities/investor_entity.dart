import 'package:equatable/equatable.dart';

class InvestorEntity extends Equatable {
  const InvestorEntity({
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

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        userId,
        offeringId,
        firstName,
        lastName,
        avatar,
        offeringName,
        offeringSymbol,
        offeringIcon,
        totalCost,
        rejectedCost,
        totalTokens,
        lastTransactionDate,
      ];
}
