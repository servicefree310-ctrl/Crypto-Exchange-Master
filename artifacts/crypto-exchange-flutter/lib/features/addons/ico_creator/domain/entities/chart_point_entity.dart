import 'package:equatable/equatable.dart';

class ChartPointEntity extends Equatable {
  const ChartPointEntity({required this.date, required this.amount});

  final DateTime date;
  final double amount;

  @override
  List<Object?> get props => [date, amount];
}
