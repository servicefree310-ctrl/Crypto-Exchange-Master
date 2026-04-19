import 'package:equatable/equatable.dart';

class PortfolioPerformancePointEntity extends Equatable {
  const PortfolioPerformancePointEntity(
      {required this.date, required this.value});

  final DateTime date;
  final double value;

  @override
  List<Object?> get props => [date, value];
}
