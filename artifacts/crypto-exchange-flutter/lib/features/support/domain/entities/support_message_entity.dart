import 'package:equatable/equatable.dart';

class SupportMessageEntity extends Equatable {
  const SupportMessageEntity({
    required this.type,
    required this.text,
    required this.time,
    required this.userId,
    this.id,
  });

  final String? id; // Optional for temp messages
  final String type; // "client" or "agent"
  final String text; // Message content
  final String time; // ISO timestamp
  final String userId; // User ID who sent the message

  // Computed properties
  bool get isFromAgent => type == 'agent';

  DateTime get timestamp {
    try {
      return DateTime.parse(time);
    } catch (e) {
      return DateTime.now(); // Fallback to current time if parsing fails
    }
  }

  @override
  List<Object?> get props => [id, type, text, time, userId];

  SupportMessageEntity copyWith({
    String? id,
    String? type,
    String? text,
    String? time,
    String? userId,
  }) {
    return SupportMessageEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      time: time ?? this.time,
      userId: userId ?? this.userId,
    );
  }

  // Helper getters for UI
  bool get isFromUser => type == 'client';
}
