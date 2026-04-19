import 'package:equatable/equatable.dart';

enum P2PDisputeStatus { pending, inProgress, resolved, closed, escalated }

enum P2PDisputePriority { low, medium, high, urgent }

class P2PDisputeEntity extends Equatable {
  const P2PDisputeEntity({
    required this.id,
    required this.tradeId,
    required this.reportedById,
    required this.againstId,
    required this.reason,
    this.details,
    required this.status,
    required this.priority,
    this.resolution,
    this.resolvedById,
    this.resolvedAt,
    this.adminNotes,
    this.evidence,
    this.messages,
    required this.filedAt,
    required this.updatedAt,
  });

  final String id;
  final String tradeId;
  final String reportedById;
  final String againstId;
  final String reason;
  final String? details;
  final P2PDisputeStatus status;
  final P2PDisputePriority priority;
  final P2PDisputeResolutionEntity? resolution;
  final String? resolvedById;
  final DateTime? resolvedAt;
  final String? adminNotes;
  final List<P2PDisputeEvidenceEntity>? evidence;
  final List<P2PDisputeMessageEntity>? messages;
  final DateTime filedAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        tradeId,
        reportedById,
        againstId,
        reason,
        details,
        status,
        priority,
        resolution,
        resolvedById,
        resolvedAt,
        adminNotes,
        evidence,
        messages,
        filedAt,
        updatedAt,
      ];

  P2PDisputeEntity copyWith({
    String? id,
    String? tradeId,
    String? reportedById,
    String? againstId,
    String? reason,
    String? details,
    P2PDisputeStatus? status,
    P2PDisputePriority? priority,
    P2PDisputeResolutionEntity? resolution,
    String? resolvedById,
    DateTime? resolvedAt,
    String? adminNotes,
    List<P2PDisputeEvidenceEntity>? evidence,
    List<P2PDisputeMessageEntity>? messages,
    DateTime? filedAt,
    DateTime? updatedAt,
  }) {
    return P2PDisputeEntity(
      id: id ?? this.id,
      tradeId: tradeId ?? this.tradeId,
      reportedById: reportedById ?? this.reportedById,
      againstId: againstId ?? this.againstId,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      resolution: resolution ?? this.resolution,
      resolvedById: resolvedById ?? this.resolvedById,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      evidence: evidence ?? this.evidence,
      messages: messages ?? this.messages,
      filedAt: filedAt ?? this.filedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isResolved => status == P2PDisputeStatus.resolved;
  bool get isPending => status == P2PDisputeStatus.pending;
  bool get isInProgress => status == P2PDisputeStatus.inProgress;
  bool get isClosed => status == P2PDisputeStatus.closed;
  bool get isEscalated => status == P2PDisputeStatus.escalated;

  bool get isHighPriority =>
      priority == P2PDisputePriority.high ||
      priority == P2PDisputePriority.urgent;

  Duration? get resolutionTime {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(filedAt);
  }

  String get displayStatus {
    switch (status) {
      case P2PDisputeStatus.pending:
        return 'Pending';
      case P2PDisputeStatus.inProgress:
        return 'In Progress';
      case P2PDisputeStatus.resolved:
        return 'Resolved';
      case P2PDisputeStatus.closed:
        return 'Closed';
      case P2PDisputeStatus.escalated:
        return 'Escalated';
    }
  }

  String get displayPriority {
    switch (priority) {
      case P2PDisputePriority.low:
        return 'Low';
      case P2PDisputePriority.medium:
        return 'Medium';
      case P2PDisputePriority.high:
        return 'High';
      case P2PDisputePriority.urgent:
        return 'Urgent';
    }
  }
}

class P2PDisputeResolutionEntity extends Equatable {
  const P2PDisputeResolutionEntity({
    required this.outcome,
    required this.notes,
    this.compensationAmount,
    this.penalizedUserId,
    required this.resolvedOn,
  });

  final String outcome;
  final String notes;
  final double? compensationAmount;
  final String? penalizedUserId;
  final DateTime resolvedOn;

  @override
  List<Object?> get props => [
        outcome,
        notes,
        compensationAmount,
        penalizedUserId,
        resolvedOn,
      ];

  P2PDisputeResolutionEntity copyWith({
    String? outcome,
    String? notes,
    double? compensationAmount,
    String? penalizedUserId,
    DateTime? resolvedOn,
  }) {
    return P2PDisputeResolutionEntity(
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
      compensationAmount: compensationAmount ?? this.compensationAmount,
      penalizedUserId: penalizedUserId ?? this.penalizedUserId,
      resolvedOn: resolvedOn ?? this.resolvedOn,
    );
  }
}

class P2PDisputeEvidenceEntity extends Equatable {
  const P2PDisputeEvidenceEntity({
    required this.id,
    required this.disputeId,
    required this.type,
    required this.title,
    required this.submittedBy,
    required this.url,
    this.description,
    required this.submittedAt,
  });

  final String id;
  final String disputeId;
  final String type; // image, document, screenshot, etc.
  final String title;
  final String submittedBy;
  final String url;
  final String? description;
  final DateTime submittedAt;

  @override
  List<Object?> get props => [
        id,
        disputeId,
        type,
        title,
        submittedBy,
        url,
        description,
        submittedAt,
      ];

  P2PDisputeEvidenceEntity copyWith({
    String? id,
    String? disputeId,
    String? type,
    String? title,
    String? submittedBy,
    String? url,
    String? description,
    DateTime? submittedAt,
  }) {
    return P2PDisputeEvidenceEntity(
      id: id ?? this.id,
      disputeId: disputeId ?? this.disputeId,
      type: type ?? this.type,
      title: title ?? this.title,
      submittedBy: submittedBy ?? this.submittedBy,
      url: url ?? this.url,
      description: description ?? this.description,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  bool get isImage =>
      type.toLowerCase().contains('image') ||
      type.toLowerCase().contains('screenshot');
  bool get isDocument =>
      type.toLowerCase().contains('document') ||
      type.toLowerCase().contains('pdf');
}

class P2PDisputeMessageEntity extends Equatable {
  const P2PDisputeMessageEntity({
    required this.id,
    required this.disputeId,
    required this.senderId,
    required this.senderType,
    required this.content,
    this.attachments,
    required this.timestamp,
  });

  final String id;
  final String disputeId;
  final String senderId;
  final String senderType; // user, admin, system
  final String content;
  final List<String>? attachments;
  final DateTime timestamp;

  @override
  List<Object?> get props => [
        id,
        disputeId,
        senderId,
        senderType,
        content,
        attachments,
        timestamp,
      ];

  P2PDisputeMessageEntity copyWith({
    String? id,
    String? disputeId,
    String? senderId,
    String? senderType,
    String? content,
    List<String>? attachments,
    DateTime? timestamp,
  }) {
    return P2PDisputeMessageEntity(
      id: id ?? this.id,
      disputeId: disputeId ?? this.disputeId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool get isFromAdmin => senderType == 'admin';
  bool get isFromUser => senderType == 'user';
  bool get isSystemMessage => senderType == 'system';
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
}
