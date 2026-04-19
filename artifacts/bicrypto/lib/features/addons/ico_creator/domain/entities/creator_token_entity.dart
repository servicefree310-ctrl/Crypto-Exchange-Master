import 'package:equatable/equatable.dart';

enum CreatorTokenStatus { draft, pending, active, completed, rejected }

class CreatorTokenEntity extends Equatable {
  const CreatorTokenEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.icon,
    required this.status,
    required this.blockchain,
    required this.tokenType,
    required this.totalSupply,
    required this.tokensForSale,
    required this.startDate,
    required this.endDate,
    required this.raisedAmount,
    required this.targetAmount,
  });

  final String id;
  final String name;
  final String symbol;
  final String icon;
  final CreatorTokenStatus status;
  final String blockchain;
  final String tokenType;
  final double totalSupply;
  final double tokensForSale;
  final DateTime startDate;
  final DateTime endDate;
  final double raisedAmount;
  final double targetAmount;

  bool get isActive => status == CreatorTokenStatus.active;
  bool get isDraft => status == CreatorTokenStatus.draft;

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        icon,
        status,
        blockchain,
        tokenType,
        totalSupply,
        tokensForSale,
        startDate,
        endDate,
        raisedAmount,
        targetAmount,
      ];
}
