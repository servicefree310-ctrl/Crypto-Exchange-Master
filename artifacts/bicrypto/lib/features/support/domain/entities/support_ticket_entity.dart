import 'package:equatable/equatable.dart';
import 'support_message_entity.dart';

enum TicketStatus { pending, open, replied, closed }

enum TicketImportance { low, medium, high }

enum TicketType { live, ticket }

class SupportTicketEntity extends Equatable {
  const SupportTicketEntity({
    required this.id,
    required this.userId,
    this.agentId,
    this.agentName,
    required this.subject,
    required this.importance,
    required this.status,
    required this.type,
    this.messages = const [],
    this.tags = const [],
    this.responseTime,
    this.satisfaction,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.user,
    this.agent,
  });

  final String id;
  final String userId;
  final String? agentId;
  final String? agentName;
  final String subject;
  final TicketImportance importance;
  final TicketStatus status;
  final TicketType type;
  final List<SupportMessageEntity> messages;
  final List<String> tags;
  final int? responseTime;
  final double? satisfaction;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final UserEntity? user;
  final UserEntity? agent;

  @override
  List<Object?> get props => [
        id,
        userId,
        agentId,
        agentName,
        subject,
        importance,
        status,
        type,
        messages,
        tags,
        responseTime,
        satisfaction,
        createdAt,
        updatedAt,
        deletedAt,
        user,
        agent,
      ];

  SupportTicketEntity copyWith({
    String? id,
    String? userId,
    String? agentId,
    String? agentName,
    String? subject,
    TicketImportance? importance,
    TicketStatus? status,
    TicketType? type,
    List<SupportMessageEntity>? messages,
    List<String>? tags,
    int? responseTime,
    double? satisfaction,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    UserEntity? user,
    UserEntity? agent,
  }) {
    return SupportTicketEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      subject: subject ?? this.subject,
      importance: importance ?? this.importance,
      status: status ?? this.status,
      type: type ?? this.type,
      messages: messages ?? this.messages,
      tags: tags ?? this.tags,
      responseTime: responseTime ?? this.responseTime,
      satisfaction: satisfaction ?? this.satisfaction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      user: user ?? this.user,
      agent: agent ?? this.agent,
    );
  }
}

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  @override
  List<Object?> get props => [id, firstName, lastName, email, avatar];
}
