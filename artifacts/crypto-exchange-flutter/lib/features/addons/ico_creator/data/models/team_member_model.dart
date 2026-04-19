import '../../domain/entities/team_member_entity.dart';

class TeamMemberModel {
  TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
  });

  final String id;
  final String name;
  final String role;
  final String? avatar;

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'avatar': avatar,
      };

  TeamMemberEntity toEntity() => TeamMemberEntity(
        id: id,
        name: name,
        role: role,
        avatar: avatar,
      );
}
