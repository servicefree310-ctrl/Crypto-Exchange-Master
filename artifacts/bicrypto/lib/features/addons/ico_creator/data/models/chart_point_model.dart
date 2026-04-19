import '../../domain/entities/chart_point_entity.dart';

class ChartPointModel {
  ChartPointModel({required this.date, required this.amount});

  final DateTime date;
  final double amount;

  factory ChartPointModel.fromJson(Map<String, dynamic> json) =>
      ChartPointModel(
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
      );

  ChartPointEntity toEntity() => ChartPointEntity(date: date, amount: amount);
}
