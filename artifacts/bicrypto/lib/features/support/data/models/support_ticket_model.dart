import 'dart:convert';
import '../../domain/entities/support_ticket_entity.dart';
import 'support_message_model.dart';
import 'user_model.dart';

class SupportTicketModel extends SupportTicketEntity {
  const SupportTicketModel({
    required super.id,
    required super.userId,
    super.agentId,
    super.agentName,
    required super.subject,
    required super.importance,
    required super.status,
    required super.type,
    super.messages = const [],
    super.tags = const [],
    super.responseTime,
    super.satisfaction,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    super.user,
    super.agent,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    // Handle messages parsing
    List<SupportMessageModel> messagesList = [];
    if (json['messages'] != null) {
      if (json['messages'] is String) {
        // Handle JSON string
        try {
          final messagesJson = jsonDecode(json['messages'] as String);
          if (messagesJson is List) {
            messagesList = messagesJson
                .map((msg) => SupportMessageModel.fromJson(msg))
                .toList();
          }
        } catch (e) {
          messagesList = [];
        }
      } else if (json['messages'] is List) {
        messagesList = (json['messages'] as List)
            .map((msg) => SupportMessageModel.fromJson(msg))
            .toList();
      }
    }

    // Handle tags parsing (can be JSON string or List)
    List<String> tagsList = [];
    if (json['tags'] != null) {
      if (json['tags'] is String) {
        try {
          final parsed = jsonDecode(json['tags'] as String);
          if (parsed is List) {
            tagsList = List<String>.from(parsed);
          }
        } catch (_) {
          tagsList = [];
        }
      } else if (json['tags'] is List) {
        tagsList = List<String>.from(json['tags'] as List);
      }
    }

    return SupportTicketModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      agentId: json['agentId'] as String?,
      agentName: json['agentName'] as String?,
      subject: json['subject'] as String,
      importance: _parseImportance(json['importance'] as String),
      status: _parseStatus(json['status'] as String),
      type: _parseType(json['type'] as String),
      messages: messagesList.map((model) => model.toEntity()).toList(),
      tags: tagsList,
      responseTime: json['responseTime'] as int?,
      satisfaction: json['satisfaction']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      agent: json['agent'] != null
          ? UserModel.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'agentId': agentId,
      'agentName': agentName,
      'subject': subject,
      'importance': importance.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'type': type.name.toUpperCase(),
      'messages':
          messages.map((msg) => (msg as SupportMessageModel).toJson()).toList(),
      'tags': tags,
      'responseTime': responseTime,
      'satisfaction': satisfaction,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'user': user != null ? (user as UserModel).toJson() : null,
      'agent': agent != null ? (agent as UserModel).toJson() : null,
    };
  }

  static TicketImportance _parseImportance(String importance) {
    switch (importance.toLowerCase()) {
      case 'low':
        return TicketImportance.low;
      case 'medium':
        return TicketImportance.medium;
      case 'high':
        return TicketImportance.high;
      default:
        return TicketImportance.low;
    }
  }

  static TicketStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TicketStatus.pending;
      case 'open':
        return TicketStatus.open;
      case 'replied':
        return TicketStatus.replied;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.pending;
    }
  }

  static TicketType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'live':
        return TicketType.live;
      case 'ticket':
        return TicketType.ticket;
      default:
        return TicketType.ticket;
    }
  }
}
