import 'package:k_chart_plus/entity/k_line_entity.dart';

class KLineDataModel {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  late int time;
  late double amount;

  KLineDataModel({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.vol,
    required this.time,
    required this.amount,
  });

  factory KLineDataModel.fromJson(Map<String, dynamic> json) {
    return KLineDataModel(
      open: double.parse(json['open'].toString()),
      high: double.parse(json['high'].toString()),
      low: double.parse(json['low'].toString()),
      close: double.parse(json['close'].toString()),
      vol: double.parse(json['vol'].toString()),
      time: int.parse(json['time'].toString()),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'vol': vol,
      'time': time,
      'amount': amount,
    };
  }

  // Convert to KLineEntity for k_chart_plus
  static KLineEntity createKLineEntity({
    required double open,
    required double high,
    required double low,
    required double close,
    required double vol,
    required int time,
    required double amount,
  }) {
    // Create KLineEntity using fromJson method
    final Map<String, dynamic> data = {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'vol': vol,
      'count': time, // Use 'count' as time field
      'amount': amount,
    };

    return KLineEntity.fromJson(data);
  }

  KLineEntity toKLineEntity() {
    return createKLineEntity(
      open: open,
      high: high,
      low: low,
      close: close,
      vol: vol,
      time: time,
      amount: amount,
    );
  }

  static List<KLineDataModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => KLineDataModel.fromJson(json)).toList();
  }

  // Convert list to KLineEntity list for k_chart_plus
  static List<KLineEntity> toKLineEntityList(List<KLineDataModel> models) {
    return models.map((model) => model.toKLineEntity()).toList();
  }

  // Sample data for testing
  static List<KLineDataModel> getSampleData() {
    final now = DateTime.now();
    final List<KLineDataModel> data = [];

    double basePrice = 65000.0;

    for (int i = 0; i < 100; i++) {
      final time = now.subtract(Duration(minutes: 100 - i));
      final random = (i * 37) % 100; // Simple pseudo-random

      final priceChange = (random - 50) * 10; // -500 to +500
      final open = basePrice + priceChange;
      final volatility = 50 + (random % 100); // 50-150 volatility

      final high = open + (random % volatility.toInt()).toDouble();
      final low = open - (random % volatility.toInt()).toDouble();
      final close = low + ((high - low) * (random % 100) / 100);

      final vol = 1000000.0 + (random * 10000); // 1M-2M volume

      data.add(KLineDataModel(
        open: open,
        high: high,
        low: low,
        close: close,
        vol: vol,
        time: time.millisecondsSinceEpoch,
        amount: close * vol,
      ));

      basePrice = close; // Next candle starts from previous close
    }

    return data;
  }
}
