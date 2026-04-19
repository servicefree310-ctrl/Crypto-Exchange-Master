import '../../domain/entities/ico_offering_entity.dart';

class IcoTeamMemberModel {
  const IcoTeamMemberModel({
    required this.id,
    required this.offeringId,
    required this.name,
    required this.role,
    required this.avatar,
    this.bio,
    this.linkedin,
    this.twitter,
  });

  final String id;
  final String offeringId;
  final String name;
  final String role;
  final String avatar;
  final String? bio;
  final String? linkedin;
  final String? twitter;

  factory IcoTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return IcoTeamMemberModel(
      id: json['id'] as String,
      offeringId: json['offeringId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String?,
      linkedin: json['linkedin'] as String?,
      twitter: json['twitter'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeringId': offeringId,
      'name': name,
      'role': role,
      'avatar': avatar,
      'bio': bio,
      'linkedin': linkedin,
      'twitter': twitter,
    };
  }

  IcoTeamMemberEntity toEntity() {
    return IcoTeamMemberEntity(
      id: id,
      name: name,
      role: role,
      avatar: avatar,
      bio: bio,
      linkedin: linkedin,
      twitter: twitter,
    );
  }
}
