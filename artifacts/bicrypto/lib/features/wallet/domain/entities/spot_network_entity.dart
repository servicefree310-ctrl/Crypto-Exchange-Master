import 'package:equatable/equatable.dart';
import 'spot_limits_entity.dart';

class SpotNetworkEntity extends Equatable {
  const SpotNetworkEntity({
    required this.id,
    required this.chain,
    required this.fee,
    required this.precision,
    required this.limits,
  });

  final String id;
  final String chain;
  final double fee;
  final double precision;
  final SpotLimitsEntity limits;

  @override
  List<Object?> get props => [id, chain, fee, precision, limits];

  SpotNetworkEntity copyWith({
    String? id,
    String? chain,
    double? fee,
    double? precision,
    SpotLimitsEntity? limits,
  }) {
    return SpotNetworkEntity(
      id: id ?? this.id,
      chain: chain ?? this.chain,
      fee: fee ?? this.fee,
      precision: precision ?? this.precision,
      limits: limits ?? this.limits,
    );
  }
}
