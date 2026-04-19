import '../../domain/entities/mlm_user_entity.dart';

class MlmUserModel {
  const MlmUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.phone,
    required this.status,
    required this.createdAt,
    this.location,
    this.referralCode,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final String? phone;
  final String status;
  final String createdAt;
  final String? location;
  final String? referralCode;

  factory MlmUserModel.fromJson(Map<String, dynamic> json) {
    return MlmUserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      phone: json['phone'],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      location: json['location'],
      referralCode: json['referralCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatar': avatar,
      'phone': phone,
      'status': status,
      'createdAt': createdAt,
      'location': location,
      'referralCode': referralCode,
    };
  }
}

extension MlmUserModelX on MlmUserModel {
  MlmUserEntity toEntity() {
    return MlmUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatar: avatar,
      phone: phone,
      status: status,
      joinDate: DateTime.parse(createdAt),
      location: location,
      referralCode: referralCode,
    );
  }
}

extension MlmUserEntityX on MlmUserEntity {
  MlmUserModel toModel() {
    return MlmUserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatar: avatar,
      phone: phone,
      status: status,
      createdAt: joinDate.toIso8601String(),
      location: location,
      referralCode: referralCode,
    );
  }
}
