import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/news_entity.dart';

part 'news_category_model.freezed.dart';
part 'news_category_model.g.dart';

@freezed
class NewsCategoryModel with _$NewsCategoryModel {
  const factory NewsCategoryModel({
    required String id,
    required String name,
    required String icon,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _NewsCategoryModel;

  factory NewsCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$NewsCategoryModelFromJson(json);
}

extension NewsCategoryModelX on NewsCategoryModel {
  NewsCategoryEntity toEntity() {
    return NewsCategoryEntity(
      id: id,
      name: name,
      icon: icon,
      isActive: isActive,
    );
  }
}
