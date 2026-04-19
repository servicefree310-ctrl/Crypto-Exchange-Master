import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/p2p_payment_method_entity.dart';

part 'p2p_payment_method_model.freezed.dart';
part 'p2p_payment_method_model.g.dart';

@freezed
class P2PPaymentMethodModel with _$P2PPaymentMethodModel {
  const factory P2PPaymentMethodModel({
    required String id,
    required String name,
    required String type,
    required String currency,
    required bool isEnabled,
    Map<String, dynamic>? config,
    List<String>? supportedCountries,
    Map<String, dynamic>? limits,
  }) = _P2PPaymentMethodModel;

  factory P2PPaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$P2PPaymentMethodModelFromJson(json);
}

extension P2PPaymentMethodModelX on P2PPaymentMethodModel {
  P2PPaymentMethodEntity toEntity() {
    return P2PPaymentMethodEntity(
      id: id,
      name: name,
      type: type,
      currency: currency,
      isEnabled: isEnabled,
      config: config,
      supportedCountries: supportedCountries,
      limits: limits,
    );
  }
}
