import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ico_launch_plan_entity.dart';

part 'ico_launch_plan_model.freezed.dart';
part 'ico_launch_plan_model.g.dart';

@freezed
class IcoLaunchPlanModel with _$IcoLaunchPlanModel {
  const IcoLaunchPlanModel._();

  const factory IcoLaunchPlanModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required int duration,
    required List<String> features,
    @Default(true) bool isActive,
    @Default(false) bool isPopular,
    double? discount,
    int? maxOfferings,
  }) = _IcoLaunchPlanModel;

  factory IcoLaunchPlanModel.fromJson(Map<String, dynamic> json) =>
      _$IcoLaunchPlanModelFromJson(json);

  IcoLaunchPlanEntity toEntity() {
    return IcoLaunchPlanEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      duration: duration,
      features: features,
      isActive: isActive,
      isPopular: isPopular,
      discount: discount,
      maxOfferings: maxOfferings,
    );
  }
}
