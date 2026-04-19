import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/eco_token_entity.dart';

part 'eco_token_model.freezed.dart';
part 'eco_token_model.g.dart';

@freezed
class EcoTokenModel with _$EcoTokenModel {
  const factory EcoTokenModel({
    required String name,
    required String currency,
    required String chain,
    required String icon,
    EcoLimitsModel? limits,
    EcoFeeModel? fee,
    required String contractType, // PERMIT | NO_PERMIT | NATIVE
    String? contract,
    int? decimals,
    String? network,
    String? type,
    int? precision,
    @Default(true) bool status,
  }) = _EcoTokenModel;

  factory EcoTokenModel.fromJson(Map<String, dynamic> json) =>
      _$EcoTokenModelFromJson(json);
}

@freezed
class EcoLimitsModel with _$EcoLimitsModel {
  const factory EcoLimitsModel({
    required EcoDepositLimitsModel deposit,
    EcoWithdrawLimitsModel? withdraw,
  }) = _EcoLimitsModel;

  factory EcoLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$EcoLimitsModelFromJson(json);
}

@freezed
class EcoDepositLimitsModel with _$EcoDepositLimitsModel {
  const factory EcoDepositLimitsModel({
    required double min,
    required double max,
  }) = _EcoDepositLimitsModel;

  factory EcoDepositLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$EcoDepositLimitsModelFromJson(json);
}

@freezed
class EcoWithdrawLimitsModel with _$EcoWithdrawLimitsModel {
  const factory EcoWithdrawLimitsModel({
    required double min,
    required double max,
  }) = _EcoWithdrawLimitsModel;

  factory EcoWithdrawLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$EcoWithdrawLimitsModelFromJson(json);
}

@freezed
class EcoFeeModel with _$EcoFeeModel {
  const factory EcoFeeModel({
    required double min,
    required double percentage,
  }) = _EcoFeeModel;

  factory EcoFeeModel.fromJson(Map<String, dynamic> json) =>
      _$EcoFeeModelFromJson(json);
}

extension EcoTokenModelX on EcoTokenModel {
  EcoTokenEntity toEntity() {
    return EcoTokenEntity(
      name: name,
      currency: currency,
      chain: chain,
      icon: icon,
      limits: limits?.toEntity() ??
          const EcoLimitsEntity(
            deposit: EcoDepositLimitsEntity(min: 0.0, max: 1000000.0),
          ),
      fee: fee?.toEntity() ?? const EcoFeeEntity(min: 0.0, percentage: 0.0),
      contractType: contractType,
      contract: contract,
      decimals: decimals,
      network: network,
      type: type,
      precision: precision,
      status: status,
    );
  }
}

extension EcoLimitsModelX on EcoLimitsModel {
  EcoLimitsEntity toEntity() {
    return EcoLimitsEntity(
      deposit: deposit.toEntity(),
      withdraw: withdraw?.toEntity(),
    );
  }
}

extension EcoDepositLimitsModelX on EcoDepositLimitsModel {
  EcoDepositLimitsEntity toEntity() {
    return EcoDepositLimitsEntity(
      min: min,
      max: max,
    );
  }
}

extension EcoWithdrawLimitsModelX on EcoWithdrawLimitsModel {
  EcoWithdrawLimitsEntity toEntity() {
    return EcoWithdrawLimitsEntity(
      min: min,
      max: max,
    );
  }
}

extension EcoFeeModelX on EcoFeeModel {
  EcoFeeEntity toEntity() {
    return EcoFeeEntity(
      min: min,
      percentage: percentage,
    );
  }
}
