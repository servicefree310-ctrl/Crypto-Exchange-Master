import 'package:equatable/equatable.dart';

class EcoTokenEntity extends Equatable {
  final String name;
  final String currency;
  final String chain;
  final String icon;
  final EcoLimitsEntity limits;
  final EcoFeeEntity fee;
  final String contractType; // PERMIT | NO_PERMIT | NATIVE
  final String? contract;
  final int? decimals;
  final String? network;
  final String? type;
  final int? precision;
  final bool status;

  const EcoTokenEntity({
    required this.name,
    required this.currency,
    required this.chain,
    required this.icon,
    required this.limits,
    required this.fee,
    required this.contractType,
    this.contract,
    this.decimals,
    this.network,
    this.type,
    this.precision,
    required this.status,
  });

  bool get isPermitToken => contractType == 'PERMIT';
  bool get isNoPermitToken => contractType == 'NO_PERMIT';
  bool get isNativeToken => contractType == 'NATIVE';

  String get displayIcon =>
      icon.isNotEmpty ? icon : '/img/crypto/${currency.toLowerCase()}.webp';

  @override
  List<Object?> get props => [
        name,
        currency,
        chain,
        icon,
        limits,
        fee,
        contractType,
        contract,
        decimals,
        network,
        type,
        precision,
        status,
      ];

  EcoTokenEntity copyWith({
    String? name,
    String? currency,
    String? chain,
    String? icon,
    EcoLimitsEntity? limits,
    EcoFeeEntity? fee,
    String? contractType,
    String? contract,
    int? decimals,
    String? network,
    String? type,
    int? precision,
    bool? status,
  }) {
    return EcoTokenEntity(
      name: name ?? this.name,
      currency: currency ?? this.currency,
      chain: chain ?? this.chain,
      icon: icon ?? this.icon,
      limits: limits ?? this.limits,
      fee: fee ?? this.fee,
      contractType: contractType ?? this.contractType,
      contract: contract ?? this.contract,
      decimals: decimals ?? this.decimals,
      network: network ?? this.network,
      type: type ?? this.type,
      precision: precision ?? this.precision,
      status: status ?? this.status,
    );
  }
}

class EcoLimitsEntity extends Equatable {
  final EcoDepositLimitsEntity deposit;
  final EcoWithdrawLimitsEntity? withdraw;

  const EcoLimitsEntity({
    required this.deposit,
    this.withdraw,
  });

  @override
  List<Object?> get props => [deposit, withdraw];
}

class EcoDepositLimitsEntity extends Equatable {
  final double min;
  final double max;

  const EcoDepositLimitsEntity({
    required this.min,
    required this.max,
  });

  bool isValidAmount(double amount) {
    return amount >= min && amount <= max;
  }

  @override
  List<Object?> get props => [min, max];
}

class EcoWithdrawLimitsEntity extends Equatable {
  final double min;
  final double max;

  const EcoWithdrawLimitsEntity({
    required this.min,
    required this.max,
  });

  bool isValidAmount(double amount) {
    return amount >= min && amount <= max;
  }

  @override
  List<Object?> get props => [min, max];
}

class EcoFeeEntity extends Equatable {
  final double min;
  final double percentage;

  const EcoFeeEntity({
    required this.min,
    required this.percentage,
  });

  double calculateFee(double amount) {
    final percentageFee = amount * (percentage / 100);
    return percentageFee > min ? percentageFee : min;
  }

  @override
  List<Object?> get props => [min, percentage];
}
