import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/support_message_entity.dart';

part 'support_message_model.freezed.dart';
part 'support_message_model.g.dart';

@freezed
class SupportMessageModel with _$SupportMessageModel {
  const factory SupportMessageModel({
    String? id,
    required String type, // "client" or "agent"
    required String text, // Message content
    required String time, // ISO timestamp string
    required String userId, // User ID who sent the message
  }) = _SupportMessageModel;

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) =>
      _$SupportMessageModelFromJson(json);
}

extension SupportMessageModelX on SupportMessageModel {
  SupportMessageEntity toEntity() {
    return SupportMessageEntity(
      id: id,
      type: type,
      text: text,
      time: time,
      userId: userId,
    );
  }
}

extension SupportMessageEntityX on SupportMessageEntity {
  SupportMessageModel toModel() {
    return SupportMessageModel(
      id: id,
      type: type,
      text: text,
      time: time,
      userId: userId,
    );
  }
}
