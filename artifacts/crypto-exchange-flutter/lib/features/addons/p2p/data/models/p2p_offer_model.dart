import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/p2p_offer_entity.dart';
import 'p2p_user_model.dart';
import 'p2p_payment_method_model.dart';
import 'p2p_trade_model.dart';

part 'p2p_offer_model.freezed.dart';
part 'p2p_offer_model.g.dart';

@freezed
class P2POfferModel with _$P2POfferModel {
  const factory P2POfferModel({
    required String id,
    required String userId,
    required String type,
    required String currency,
    required String walletType,
    required Map<String, dynamic> amountConfig,
    required Map<String, dynamic> priceConfig,
    required Map<String, dynamic> tradeSettings,
    Map<String, dynamic>? locationSettings,
    Map<String, dynamic>? userRequirements,
    required String status,
    required int views,
    List<String>? systemTags,
    String? adminNotes,
    required String createdAt,
    required String updatedAt,
    String? deletedAt,
    // Associated models
    P2PUserModel? user,
    List<P2PPaymentMethodModel>? paymentMethods,
    P2POfferFlagModel? flag,
    List<P2PTradeModel>? trades,
  }) = _P2POfferModel;

  factory P2POfferModel.fromJson(Map<String, dynamic> json) =>
      _$P2POfferModelFromJson(json);
}

@freezed
class P2POfferFlagModel with _$P2POfferFlagModel {
  const factory P2POfferFlagModel({
    required String id,
    required String offerId,
    required String userId,
    String? reason,
    String? description,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) = _P2POfferFlagModel;

  factory P2POfferFlagModel.fromJson(Map<String, dynamic> json) =>
      _$P2POfferFlagModelFromJson(json);
}

// Extensions to convert models to entities
extension P2POfferModelX on P2POfferModel {
  P2POfferEntity toEntity() {
    final normalizedType = _normalizeEnumToken(type);
    final normalizedWalletType = _normalizeEnumToken(walletType);
    final normalizedPriceModel = _normalizeEnumToken(priceConfig['model']);
    final normalizedVisibility =
        _normalizeEnumToken(tradeSettings['visibility']);
    final normalizedStatus = _normalizeEnumToken(status);

    return P2POfferEntity(
      id: id,
      userId: userId,
      type: P2PTradeType.values.firstWhere(
        (e) =>
            _normalizeEnumToken(e.toString().split('.').last) == normalizedType,
        orElse: () => P2PTradeType.buy,
      ),
      currency: currency,
      walletType: P2PWalletType.values.firstWhere(
        (e) =>
            _normalizeEnumToken(e.toString().split('.').last) ==
            normalizedWalletType,
        orElse: () => P2PWalletType.spot,
      ),
      amountConfig: AmountConfiguration(
        total: (amountConfig['total'] as num?)?.toDouble() ?? 0.0,
        min: (amountConfig['min'] as num?)?.toDouble(),
        max: (amountConfig['max'] as num?)?.toDouble(),
        availableBalance:
            (amountConfig['availableBalance'] as num?)?.toDouble(),
      ),
      priceConfig: PriceConfiguration(
        model: P2PPriceModel.values.firstWhere(
          (e) =>
              _normalizeEnumToken(e.toString().split('.').last) ==
              normalizedPriceModel,
          orElse: () => P2PPriceModel.fixed,
        ),
        value: (priceConfig['value'] as num?)?.toDouble() ?? 0.0,
        marketPrice: (priceConfig['marketPrice'] as num?)?.toDouble(),
        finalPrice: (priceConfig['finalPrice'] as num?)?.toDouble() ?? 0.0,
      ),
      tradeSettings: TradeSettings(
        autoCancel: (tradeSettings['autoCancel'] as num?)?.toInt() ?? 30,
        kycRequired: tradeSettings['kycRequired'] as bool? ?? false,
        visibility: P2POfferVisibility.values.firstWhere(
          (e) =>
              _normalizeEnumToken(e.toString().split('.').last) ==
              normalizedVisibility,
          orElse: () => P2POfferVisibility.public,
        ),
        termsOfTrade: tradeSettings['termsOfTrade'] as String?,
        additionalNotes: tradeSettings['additionalNotes'] as String?,
      ),
      locationSettings: locationSettings != null
          ? LocationSettings(
              country: locationSettings!['country'] as String?,
              region: locationSettings!['region'] as String?,
              city: locationSettings!['city'] as String?,
              restrictions: (locationSettings!['restrictions'] as List?)
                  ?.map((e) => e.toString())
                  .toList(),
            )
          : null,
      userRequirements: userRequirements != null
          ? UserRequirements(
              minCompletedTrades:
                  (userRequirements!['minCompletedTrades'] as num?)?.toInt(),
              minSuccessRate:
                  (userRequirements!['minSuccessRate'] as num?)?.toDouble(),
              minAccountAge:
                  (userRequirements!['minAccountAge'] as num?)?.toInt(),
              trustedOnly: userRequirements!['trustedOnly'] as bool? ?? false,
            )
          : null,
      status: P2POfferStatus.values.firstWhere(
        (e) =>
            _normalizeEnumToken(e.toString().split('.').last) ==
            normalizedStatus,
        orElse: () => P2POfferStatus.draft,
      ),
      views: views,
      systemTags: systemTags ?? [],
      adminNotes: adminNotes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      deletedAt: deletedAt != null ? DateTime.parse(deletedAt!) : null,
      // Associated entities - simplified for core entity
      user: user?.toJson(),
      paymentMethods: paymentMethods?.map((pm) => pm.id).toList() ?? [],
    );
  }
}

String _normalizeEnumToken(dynamic value) {
  return (value ?? '')
      .toString()
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
      .toLowerCase();
}

extension P2POfferFlagModelX on P2POfferFlagModel {
  P2POfferFlagEntity toEntity() {
    return P2POfferFlagEntity(
      id: id,
      offerId: offerId,
      userId: userId,
      reason: reason ?? '',
      description: description ?? '',
      status: status ?? 'PENDING',
      createdAt: DateTime.parse(createdAt ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(updatedAt ?? DateTime.now().toIso8601String()),
    );
  }
}

// Additional helper entity that's not in the main entities
class P2POfferFlagEntity extends Equatable {
  final String id;
  final String offerId;
  final String userId;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const P2POfferFlagEntity({
    required this.id,
    required this.offerId,
    required this.userId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        offerId,
        userId,
        reason,
        description,
        status,
        createdAt,
        updatedAt,
      ];
}
