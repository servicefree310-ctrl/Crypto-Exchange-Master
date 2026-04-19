import 'package:equatable/equatable.dart';

class RoadmapItemEntity extends Equatable {
  const RoadmapItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
  });

  final String id;
  final String title;
  final String description;
  final DateTime targetDate;

  @override
  List<Object?> get props => [id, title, description, targetDate];
}
