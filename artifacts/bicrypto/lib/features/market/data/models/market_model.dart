import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/market_entity.dart';

part 'market_model.freezed.dart';
part 'market_model.g.dart';

@freezed
class MarketModel with _$MarketModel {
  const factory MarketModel({
    required String id,
    required String currency,
    required String pair,
    required bool isTrending,
    required bool isHot,
    required bool status,
    required bool isEco,
    MarketMetadataModel? metadata,
    String? icon, // For ecosystem tokens
  }) = _MarketModel;

  factory MarketModel.fromJson(Map<String, dynamic> json) =>
      _$MarketModelFromJson(json);
}

@freezed
class MarketMetadataModel with _$MarketMetadataModel {
  const factory MarketMetadataModel({
    double? taker,
    double? maker,
    required MarketPrecisionModel precision,
    required MarketLimitsModel limits,
  }) = _MarketMetadataModel;

  factory MarketMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$MarketMetadataModelFromJson(json);
}

@freezed
class MarketPrecisionModel with _$MarketPrecisionModel {
  const factory MarketPrecisionModel({
    required int price,
    required int amount,
  }) = _MarketPrecisionModel;

  factory MarketPrecisionModel.fromJson(Map<String, dynamic> json) =>
      _$MarketPrecisionModelFromJson(json);
}

@freezed
class MarketLimitsModel with _$MarketLimitsModel {
  const factory MarketLimitsModel({
    @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
    MarketLimitModel? amount,
    @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
    MarketLimitModel? price,
    @JsonKey(fromJson: _limitFromJson, toJson: _limitToJson)
    MarketLimitModel? cost,
    @JsonKey(fromJson: _leverageFromJson, toJson: _leverageToJson)
    Map<String, dynamic>? leverage,
  }) = _MarketLimitsModel;

  factory MarketLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$MarketLimitsModelFromJson(json);
}

// Helper functions for leverage field
Map<String, dynamic>? _leverageFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map) {
    return Map<String, dynamic>.from(json);
  }
  return null;
}

dynamic _leverageToJson(Map<String, dynamic>? leverage) {
  return leverage;
}

// Helper functions for limit fields (amount, price, cost)
MarketLimitModel? _limitFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map && json.isEmpty) return null; // Handle empty objects {}
  if (json is Map<String, dynamic>) {
    try {
      return MarketLimitModel.fromJson(json);
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }
  return null;
}

dynamic _limitToJson(MarketLimitModel? limit) {
  return limit?.toJson();
}

@freezed
class MarketLimitModel with _$MarketLimitModel {
  const factory MarketLimitModel({
    required double min,
    double? max,
  }) = _MarketLimitModel;

  factory MarketLimitModel.fromJson(Map<String, dynamic> json) =>
      _$MarketLimitModelFromJson(json);
}

extension MarketModelX on MarketModel {
  MarketEntity toEntity() {
    return MarketEntity(
      id: id,
      symbol: '$currency/$pair',
      currency: currency,
      pair: pair,
      isTrending: isTrending,
      isHot: isHot,
      status: status,
      isEco: isEco,
      icon: icon,
      precision: metadata?.precision != null
          ? MarketPrecisionEntity(
              price: metadata!.precision.price,
              amount: metadata!.precision.amount,
            )
          : null,
      limits: metadata?.limits != null
          ? MarketLimitsEntity(
              minAmount: metadata!.limits.amount?.min,
              maxAmount: metadata!.limits.amount?.max,
              minPrice: metadata!.limits.price?.min,
              maxPrice: metadata!.limits.price?.max,
              minCost: metadata!.limits.cost?.min,
              maxCost: metadata!.limits.cost?.max,
            )
          : null,
      taker: metadata?.taker,
      maker: metadata?.maker,
    );
  }
}
