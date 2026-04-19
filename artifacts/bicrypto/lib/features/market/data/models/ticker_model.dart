import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ticker_entity.dart';

part 'ticker_model.freezed.dart';
part 'ticker_model.g.dart';

@freezed
class TickerModel with _$TickerModel {
  const factory TickerModel({
    required String symbol,
    double? last,
    double? baseVolume,
    double? quoteVolume,
    double? change,
    double? bid,
    double? ask,
    double? high,
    double? low,
    double? open,
    double? close,
  }) = _TickerModel;

  factory TickerModel.fromJson(Map<String, dynamic> json) =>
      _$TickerModelFromJson(json);
}

extension TickerModelX on TickerModel {
  TickerEntity toEntity() {
    return TickerEntity(
      symbol: symbol,
      last: last ?? 0.0,
      baseVolume: baseVolume ?? 0.0,
      quoteVolume: quoteVolume ?? 0.0,
      change: change != null ? (change! / 100) : 0.0,
      bid: bid,
      ask: ask,
      high: high,
      low: low,
      open: open,
      close: close,
    );
  }
}
