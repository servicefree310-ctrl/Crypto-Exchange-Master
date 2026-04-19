import 'package:equatable/equatable.dart';

/// P2P Review Entity
///
/// Represents a review submitted after a P2P trade completion
/// Based on v5 backend review structure with multi-dimensional ratings
class P2PReviewEntity extends Equatable {
  const P2PReviewEntity({
    required this.id,
    required this.tradeId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.communicationRating,
    this.speedRating,
    this.trustRating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.reviewerInfo,
    this.revieweeInfo,
  });

  /// Unique identifier
  final String id;

  /// Trade ID this review is for
  final String tradeId;

  /// User ID who submitted the review
  final String reviewerId;

  /// User ID who received the review
  final String revieweeId;

  /// Overall rating (1-5)
  final double rating;

  /// Communication rating (1-5)
  final double? communicationRating;

  /// Speed/responsiveness rating (1-5)
  final double? speedRating;

  /// Trustworthiness rating (1-5)
  final double? trustRating;

  /// Review comment/feedback
  final String? comment;

  /// Review creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Reviewer information (optional)
  final ReviewerInfo? reviewerInfo;

  /// Reviewee information (optional)
  final ReviewerInfo? revieweeInfo;

  /// Calculate average detailed rating
  double get averageDetailedRating {
    final ratings = [
      communicationRating,
      speedRating,
      trustRating,
    ].where((r) => r != null).cast<double>();

    if (ratings.isEmpty) return rating;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  /// Whether this review has detailed ratings
  bool get hasDetailedRatings {
    return communicationRating != null ||
        speedRating != null ||
        trustRating != null;
  }

  @override
  List<Object?> get props => [
        id,
        tradeId,
        reviewerId,
        revieweeId,
        rating,
        communicationRating,
        speedRating,
        trustRating,
        comment,
        createdAt,
        updatedAt,
        reviewerInfo,
        revieweeInfo,
      ];

  P2PReviewEntity copyWith({
    String? id,
    String? tradeId,
    String? reviewerId,
    String? revieweeId,
    double? rating,
    double? communicationRating,
    double? speedRating,
    double? trustRating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReviewerInfo? reviewerInfo,
    ReviewerInfo? revieweeInfo,
  }) {
    return P2PReviewEntity(
      id: id ?? this.id,
      tradeId: tradeId ?? this.tradeId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      communicationRating: communicationRating ?? this.communicationRating,
      speedRating: speedRating ?? this.speedRating,
      trustRating: trustRating ?? this.trustRating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewerInfo: reviewerInfo ?? this.reviewerInfo,
      revieweeInfo: revieweeInfo ?? this.revieweeInfo,
    );
  }
}

/// Reviewer/Reviewee information
class ReviewerInfo extends Equatable {
  const ReviewerInfo({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;

  String get displayName {
    if (lastName?.isNotEmpty == true) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  @override
  List<Object?> get props => [id, firstName, lastName, avatar];
}
