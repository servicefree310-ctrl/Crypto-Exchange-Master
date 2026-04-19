import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, productId, userId, rating, comment, createdAt];

  ReviewEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
