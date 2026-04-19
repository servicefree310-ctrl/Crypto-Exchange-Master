import '../../domain/entities/roadmap_item_entity.dart';

class RoadmapItemModel {
  RoadmapItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
  });

  final String id;
  final String title;
  final String description;
  final DateTime targetDate;

  factory RoadmapItemModel.fromJson(Map<String, dynamic> json) {
    return RoadmapItemModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'targetDate': targetDate.toIso8601String(),
      };

  RoadmapItemEntity toEntity() => RoadmapItemEntity(
        id: id,
        title: title,
        description: description,
        targetDate: targetDate,
      );
}
