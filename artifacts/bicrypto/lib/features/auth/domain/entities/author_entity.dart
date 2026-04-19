import 'package:equatable/equatable.dart';

enum AuthorStatus { pending, approved, rejected }

class AuthorEntity extends Equatable {
  final String id;
  final AuthorStatus status;
  final String? bio;
  final int postCount;

  const AuthorEntity({
    required this.id,
    required this.status,
    this.bio,
    this.postCount = 0,
  });

  @override
  List<Object?> get props => [id, status, bio, postCount];

  AuthorEntity copyWith({
    String? id,
    AuthorStatus? status,
    String? bio,
    int? postCount,
  }) {
    return AuthorEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      postCount: postCount ?? this.postCount,
    );
  }
}
