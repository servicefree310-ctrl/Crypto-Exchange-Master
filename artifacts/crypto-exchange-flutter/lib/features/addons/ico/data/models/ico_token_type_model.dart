import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ico_token_type_entity.dart';

part 'ico_token_type_model.freezed.dart';
part 'ico_token_type_model.g.dart';

@freezed
class IcoTokenTypeModel with _$IcoTokenTypeModel {
  const IcoTokenTypeModel._();

  const factory IcoTokenTypeModel({
    required String id,
    required String name,
    required String description,
    @Default(true) bool isActive,
  }) = _IcoTokenTypeModel;

  factory IcoTokenTypeModel.fromJson(Map<String, dynamic> json) =>
      _$IcoTokenTypeModelFromJson(json);

  IcoTokenTypeEntity toEntity() {
    return IcoTokenTypeEntity(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
    );
  }
}
