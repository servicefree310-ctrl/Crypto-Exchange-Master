import 'package:equatable/equatable.dart';

class MlmUserEntity extends Equatable {
  const MlmUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.phone,
    required this.status,
    required this.joinDate,
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
  final DateTime joinDate;
  final String? location;
  final String? referralCode;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        avatar,
        phone,
        status,
        joinDate,
        location,
        referralCode,
      ];

  MlmUserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    String? phone,
    String? status,
    DateTime? joinDate,
    String? location,
    String? referralCode,
  }) {
    return MlmUserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      location: location ?? this.location,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}
