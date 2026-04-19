import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/creator_investor_entity.dart';

part 'creator_investor_model.freezed.dart';
part 'creator_investor_model.g.dart';

@freezed
class CreatorInvestorModel with _$CreatorInvestorModel {
  const factory CreatorInvestorModel({
    required String userId,
    required String offeringId,
    required double totalCost,
    required double rejectedCost,
    required double totalTokens,
    required DateTime lastTransactionDate,
    required InvestorUserModel user,
    required InvestorOfferingModel offering,
  }) = _CreatorInvestorModel;

  factory CreatorInvestorModel.fromJson(Map<String, dynamic> json) =>
      _$CreatorInvestorModelFromJson(json);
}

@freezed
class InvestorUserModel with _$InvestorUserModel {
  const factory InvestorUserModel({
    required String firstName,
    required String lastName,
    String? avatar,
  }) = _InvestorUserModel;

  factory InvestorUserModel.fromJson(Map<String, dynamic> json) =>
      _$InvestorUserModelFromJson(json);
}

@freezed
class InvestorOfferingModel with _$InvestorOfferingModel {
  const factory InvestorOfferingModel({
    required String name,
    required String symbol,
    String? icon,
  }) = _InvestorOfferingModel;

  factory InvestorOfferingModel.fromJson(Map<String, dynamic> json) =>
      _$InvestorOfferingModelFromJson(json);
}

// Extension to convert models to entities
extension CreatorInvestorModelX on CreatorInvestorModel {
  CreatorInvestorEntity toEntity() {
    return CreatorInvestorEntity(
      userId: userId,
      offeringId: offeringId,
      totalCost: totalCost,
      rejectedCost: rejectedCost,
      totalTokens: totalTokens,
      lastTransactionDate: lastTransactionDate,
      user: user.toEntity(),
      offering: offering.toEntity(),
    );
  }
}

extension InvestorUserModelX on InvestorUserModel {
  InvestorUserEntity toEntity() {
    return InvestorUserEntity(
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
    );
  }
}

extension InvestorOfferingModelX on InvestorOfferingModel {
  InvestorOfferingEntity toEntity() {
    return InvestorOfferingEntity(
      name: name,
      symbol: symbol,
      icon: icon,
    );
  }
}
