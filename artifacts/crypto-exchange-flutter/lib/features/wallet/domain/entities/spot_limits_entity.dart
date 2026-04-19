import 'package:equatable/equatable.dart';

class SpotLimitsEntity extends Equatable {
  const SpotLimitsEntity({
    required this.withdraw,
    required this.deposit,
  });

  final SpotDepositLimitsEntity withdraw;
  final SpotDepositLimitsEntity deposit;

  @override
  List<Object?> get props => [withdraw, deposit];

  SpotLimitsEntity copyWith({
    SpotDepositLimitsEntity? withdraw,
    SpotDepositLimitsEntity? deposit,
  }) {
    return SpotLimitsEntity(
      withdraw: withdraw ?? this.withdraw,
      deposit: deposit ?? this.deposit,
    );
  }
}

class SpotDepositLimitsEntity extends Equatable {
  const SpotDepositLimitsEntity({
    required this.min,
    this.max, // Made optional since deposit limits don't have max
  });

  final double min;
  final double? max; // Made optional

  @override
  List<Object?> get props => [min, max];

  SpotDepositLimitsEntity copyWith({
    double? min,
    double? max,
  }) {
    return SpotDepositLimitsEntity(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}
