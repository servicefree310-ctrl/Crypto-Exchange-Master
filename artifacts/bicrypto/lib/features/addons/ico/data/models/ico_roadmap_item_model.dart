import '../../domain/entities/ico_offering_entity.dart';

class IcoRoadmapItemModel {
  const IcoRoadmapItemModel({
    required this.id,
    required this.offeringId,
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
  });

  final String id;
  final String offeringId;
  final String title;
  final String description;
  final String date;
  final bool completed;

  factory IcoRoadmapItemModel.fromJson(Map<String, dynamic> json) {
    return IcoRoadmapItemModel(
      id: json['id'] as String,
      offeringId: json['offeringId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeringId': offeringId,
      'title': title,
      'description': description,
      'date': date,
      'completed': completed,
    };
  }

  IcoRoadmapItemEntity toEntity() {
    return IcoRoadmapItemEntity(
      id: id,
      title: title,
      description: description,
      date: date,
      completed: completed,
    );
  }
}
