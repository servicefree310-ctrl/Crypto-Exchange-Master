import '../../domain/entities/creator_token_entity.dart';

class CreatorTokenModel {
  const CreatorTokenModel({
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
    required this.tokenPrice,
  });

  final String id;
  final String name;
  final String symbol;
  final String icon;
  final String status;
  final String blockchain;
  final String tokenType;
  final double totalSupply;
  final double tokensForSale;
  final DateTime startDate;
  final DateTime endDate;
  final double raisedAmount;
  final double targetAmount;
  final double tokenPrice;

  factory CreatorTokenModel.fromJson(Map<String, dynamic> json) {
    return CreatorTokenModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      blockchain: json['blockchain'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? '',
      totalSupply: (json['totalSupply'] as num?)?.toDouble() ?? 0,
      tokensForSale: (json['tokensForSale'] as num?)?.toDouble() ?? 0,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      // v5 returns currentRaised, not raisedAmount
      raisedAmount: (json['currentRaised'] as num?)?.toDouble() ??
          (json['raisedAmount'] as num?)?.toDouble() ??
          0,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      tokenPrice: (json['tokenPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

extension CreatorTokenModelX on CreatorTokenModel {
  CreatorTokenEntity toEntity() {
    return CreatorTokenEntity(
      id: id,
      name: name,
      symbol: symbol,
      icon: icon,
      status: _statusFromString(status),
      blockchain: blockchain,
      tokenType: tokenType,
      totalSupply: totalSupply,
      tokensForSale: tokensForSale,
      startDate: startDate,
      endDate: endDate,
      raisedAmount: raisedAmount,
      targetAmount: targetAmount,
    );
  }

  CreatorTokenStatus _statusFromString(String s) {
    switch (s.toUpperCase()) {
      case 'DRAFT':
        return CreatorTokenStatus.draft;
      case 'PENDING':
        return CreatorTokenStatus.pending;
      case 'ACTIVE':
        return CreatorTokenStatus.active;
      case 'COMPLETED':
      case 'SUCCESS': // v5 uses SUCCESS instead of COMPLETED
        return CreatorTokenStatus.completed;
      case 'REJECTED':
        return CreatorTokenStatus.rejected;
      default:
        return CreatorTokenStatus.draft;
    }
  }
}
