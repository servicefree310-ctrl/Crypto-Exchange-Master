import 'package:equatable/equatable.dart';

class EscrowDetails extends Equatable {
  const EscrowDetails({
    required this.id,
    required this.status,
    required this.amount,
    this.fee,
    this.releaseAt,
    this.releasedAt,
    this.disputeId,
  });

  final String id;
  final String status;
  final double amount;
  final double? fee;
  final DateTime? releaseAt;
  final DateTime? releasedAt;
  final String? disputeId;

  @override
  List<Object?> get props => [
        id,
        status,
        amount,
        fee,
        releaseAt,
        releasedAt,
        disputeId,
      ];

  EscrowDetails copyWith({
    String? id,
    String? status,
    double? amount,
    double? fee,
    DateTime? releaseAt,
    DateTime? releasedAt,
    String? disputeId,
  }) {
    return EscrowDetails(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      releaseAt: releaseAt ?? this.releaseAt,
      releasedAt: releasedAt ?? this.releasedAt,
      disputeId: disputeId ?? this.disputeId,
    );
  }
}
