import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/transfer_option_entity.dart';

part 'transfer_option_model.freezed.dart';
part 'transfer_option_model.g.dart';

@freezed
class TransferOptionModel with _$TransferOptionModel {
  const factory TransferOptionModel({
    required String id,
    required String name,
  }) = _TransferOptionModel;

  factory TransferOptionModel.fromJson(Map<String, dynamic> json) =>
      _$TransferOptionModelFromJson(json);
}

extension TransferOptionModelX on TransferOptionModel {
  TransferOptionEntity toEntity() {
    return TransferOptionEntity(
      id: id,
      name: name,
    );
  }
}
