import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';

part 'eco_transaction_model.freezed.dart';
part 'eco_transaction_model.g.dart';

@freezed
class EcoTransactionModel with _$EcoTransactionModel {
  const factory EcoTransactionModel({
    required String id,
    required double amount,
    required double fee,
    required String status,
    required String referenceId,
    String? description,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _EcoTransactionModel;

  factory EcoTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$EcoTransactionModelFromJson(json);
}

extension EcoTransactionModelX on EcoTransactionModel {
  EcoTransactionEntity toEntity() {
    return EcoTransactionEntity(
      id: id,
      amount: amount,
      fee: fee,
      status: status,
      referenceId: referenceId,
      description: description,
      metadata: metadata,
      createdAt: createdAt,
    );
  }
}
