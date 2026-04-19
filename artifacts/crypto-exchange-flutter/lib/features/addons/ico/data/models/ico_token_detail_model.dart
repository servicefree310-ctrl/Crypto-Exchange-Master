class IcoTokenDetailModel {
  const IcoTokenDetailModel({
    required this.id,
    required this.offeringId,
    required this.tokenType,
    required this.totalSupply,
    required this.tokensForSale,
    required this.salePercentage,
    required this.blockchain,
    required this.description,
    this.useOfFunds = const {},
    this.links = const {},
  });

  final String id;
  final String offeringId;
  final String tokenType;
  final double totalSupply;
  final double tokensForSale;
  final double salePercentage;
  final String blockchain;
  final String description;
  final Map<String, dynamic> useOfFunds;
  final Map<String, dynamic> links;

  factory IcoTokenDetailModel.fromJson(Map<String, dynamic> json) {
    return IcoTokenDetailModel(
      id: json['id']?.toString() ?? '',
      offeringId: json['offeringId']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Utility',
      totalSupply: (json['totalSupply'] as num?)?.toDouble() ?? 0.0,
      tokensForSale: (json['tokensForSale'] as num?)?.toDouble() ?? 0.0,
      salePercentage: (json['salePercentage'] as num?)?.toDouble() ?? 0.0,
      blockchain: json['blockchain']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      useOfFunds: json['useOfFunds'] is Map<String, dynamic> ? json['useOfFunds'] as Map<String, dynamic> : const {},
      links: json['links'] is Map<String, dynamic> ? json['links'] as Map<String, dynamic> : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeringId': offeringId,
      'tokenType': tokenType,
      'totalSupply': totalSupply,
      'tokensForSale': tokensForSale,
      'salePercentage': salePercentage,
      'blockchain': blockchain,
      'description': description,
      'useOfFunds': useOfFunds,
      'links': links,
    };
  }
}
