import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/spot_network_entity.dart';
import '../../domain/entities/spot_limits_entity.dart';

part 'spot_network_model.freezed.dart';
part 'spot_network_model.g.dart';

@freezed
class SpotNetworkModel with _$SpotNetworkModel {
  const factory SpotNetworkModel({
    required String id,
    required String chain,
    double? fee, // Made nullable to handle null from API
    double? precision, // Made nullable to handle null from API
    required SpotLimitsModel limits,
  }) = _SpotNetworkModel;

  factory SpotNetworkModel.fromJson(Map<String, dynamic> json) =>
      _$SpotNetworkModelFromJson(json);
}

@freezed
class SpotLimitsModel with _$SpotLimitsModel {
  const factory SpotLimitsModel({
    required SpotDepositLimitsModel withdraw, // Added withdraw limits
    required SpotDepositLimitsModel deposit,
  }) = _SpotLimitsModel;

  factory SpotLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$SpotLimitsModelFromJson(json);
}

@freezed
class SpotDepositLimitsModel with _$SpotDepositLimitsModel {
  const factory SpotDepositLimitsModel({
    required double min,
    double? max, // Made optional since deposit limits don't have max
  }) = _SpotDepositLimitsModel;

  factory SpotDepositLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$SpotDepositLimitsModelFromJson(json);
}

extension SpotNetworkModelX on SpotNetworkModel {
  SpotNetworkEntity toEntity() {
    return SpotNetworkEntity(
      id: id,
      chain: chain,
      fee: fee ?? 0.0, // Provide default value if null
      precision: precision ?? 8.0, // Provide default value if null
      limits: limits.toEntity(),
    );
  }
}

extension SpotLimitsModelX on SpotLimitsModel {
  SpotLimitsEntity toEntity() {
    return SpotLimitsEntity(
      withdraw: withdraw.toEntity(),
      deposit: deposit.toEntity(),
    );
  }
}

extension SpotDepositLimitsModelX on SpotDepositLimitsModel {
  SpotDepositLimitsEntity toEntity() {
    return SpotDepositLimitsEntity(
      min: min,
      max: max,
    );
  }
}
