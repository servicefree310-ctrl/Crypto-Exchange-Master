import '../../domain/entities/futures_market_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class FuturesMarketModel {
  FuturesMarketModel({
    required this.id,
    required this.symbol,
    required this.currency,
    required this.pair,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.baseVolume,
    this.metadata,
    this.isTrending = false,
    this.isHot = false,
    this.status = true,
  });

  final String id;
  final String symbol;
  final String currency;
  final String pair;
  final double price;
  final double change;
  final double changePercent;
  final double baseVolume;
  final Map<String, dynamic>? metadata;
  final bool isTrending;
  final bool isHot;
  final bool status;

  factory FuturesMarketModel.fromJson(Map<String, dynamic> json) {
    // The API returns the symbol already formatted as "ETH/USDT"
    final symbol = json['symbol'] as String? ??
        '${(json['currency'] ?? '').toString().toUpperCase()}/${(json['pair'] ?? '').toString().toUpperCase()}';

    return FuturesMarketModel(
      id: json['id']?.toString() ?? '',
      symbol: symbol,
      currency: json['currency']?.toString() ?? '',
      pair: json['pair']?.toString() ?? '',
      // Initial price is 0, will be updated by websocket
      price: _toDouble(json['price']),
      change: _toDouble(json['change']),
      changePercent: _toDouble(json['changePercent']),
      baseVolume: _toDouble(json['baseVolume']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isTrending: json['isTrending'] as bool? ?? false,
      isHot: json['isHot'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
    );
  }

  FuturesMarketEntity toEntity() {
    FuturesMarketMetadataEntity? metadataEntity;

    if (metadata != null) {
      metadataEntity = FuturesMarketMetadataEntity(
        precision: metadata!['precision'] as Map<String, dynamic>?,
        limits: metadata!['limits'] as Map<String, dynamic>?,
        taker: (metadata!['taker'] as num?)?.toDouble(),
        maker: (metadata!['maker'] as num?)?.toDouble(),
        fundingRate: (metadata!['fundingRate'] as num?)?.toDouble() ??
            0.0001, // Default 0.01%
      );
    }

    return FuturesMarketEntity(
      id: id,
      symbol: symbol,
      currency: currency,
      pair: pair,
      price: price,
      change: change,
      changePercent: changePercent,
      baseVolume: baseVolume,
      metadata: metadataEntity,
      isTrending: isTrending,
      isHot: isHot,
      status: status,
    );
  }
}
