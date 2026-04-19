import 'package:equatable/equatable.dart';

class IcoTokenTypeEntity extends Equatable {
  const IcoTokenTypeEntity({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String description;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, description, isActive];
}
