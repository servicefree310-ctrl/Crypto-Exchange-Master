import 'package:equatable/equatable.dart';

class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
  });

  final String id;
  final String name;
  final String role;
  final String? avatar;

  @override
  List<Object?> get props => [id, name, role, avatar];
}
