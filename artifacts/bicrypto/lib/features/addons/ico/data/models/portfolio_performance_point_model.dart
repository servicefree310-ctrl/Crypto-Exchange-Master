import '../../domain/entities/portfolio_performance_point_entity.dart';

class PortfolioPerformancePointModel {
  const PortfolioPerformancePointModel(
      {required this.date, required this.value});

  final DateTime date;
  final double value;

  factory PortfolioPerformancePointModel.fromJson(Map<String, dynamic> json) {
    return PortfolioPerformancePointModel(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'value': value,
      };
}

extension PortfolioPerformancePointModelX on PortfolioPerformancePointModel {
  PortfolioPerformancePointEntity toEntity() =>
      PortfolioPerformancePointEntity(date: date, value: value);
}
