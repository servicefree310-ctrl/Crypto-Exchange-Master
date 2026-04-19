import 'package:equatable/equatable.dart';

class P2PUserEntity extends Equatable {
  const P2PUserEntity({
    required this.id,
    required this.name,
    this.avatar,
    this.initials,
    this.email,
    this.reputation,
    this.verificationLevel,
    this.completedTrades,
    this.successfulTrades,
    this.completionRate,
    this.totalTrades,
    this.previousDisputes,
    this.accountStatus,
    this.joinedDate,
    this.lastActive,
    this.trustScore,
    this.badges,
    this.preferredCurrencies,
    this.preferredPaymentMethods,
    this.avgResponseTime,
    this.avgCompletionTime,
    this.reviews,
  });

  final String id;
  final String name;
  final String? avatar;
  final String? initials;
  final String? email;
  final double? reputation;
  final String? verificationLevel;
  final int? completedTrades;
  final int? successfulTrades;
  final double? completionRate;
  final int? totalTrades;
  final int? previousDisputes;
  final String? accountStatus;
  final DateTime? joinedDate;
  final DateTime? lastActive;
  final double? trustScore;
  final List<String>? badges;
  final List<String>? preferredCurrencies;
  final List<String>? preferredPaymentMethods;
  final String? avgResponseTime;
  final String? avgCompletionTime;
  final List<P2PUserReviewEntity>? reviews;

  @override
  List<Object?> get props => [
        id,
        name,
        avatar,
        initials,
        email,
        reputation,
        verificationLevel,
        completedTrades,
        successfulTrades,
        completionRate,
        totalTrades,
        previousDisputes,
        accountStatus,
        joinedDate,
        lastActive,
        trustScore,
        badges,
        preferredCurrencies,
        preferredPaymentMethods,
        avgResponseTime,
        avgCompletionTime,
        reviews,
      ];

  P2PUserEntity copyWith({
    String? id,
    String? name,
    String? avatar,
    String? initials,
    String? email,
    double? reputation,
    String? verificationLevel,
    int? completedTrades,
    int? successfulTrades,
    double? completionRate,
    int? totalTrades,
    int? previousDisputes,
    String? accountStatus,
    DateTime? joinedDate,
    DateTime? lastActive,
    double? trustScore,
    List<String>? badges,
    List<String>? preferredCurrencies,
    List<String>? preferredPaymentMethods,
    String? avgResponseTime,
    String? avgCompletionTime,
    List<P2PUserReviewEntity>? reviews,
  }) {
    return P2PUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      reputation: reputation ?? this.reputation,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      completedTrades: completedTrades ?? this.completedTrades,
      successfulTrades: successfulTrades ?? this.successfulTrades,
      completionRate: completionRate ?? this.completionRate,
      totalTrades: totalTrades ?? this.totalTrades,
      previousDisputes: previousDisputes ?? this.previousDisputes,
      accountStatus: accountStatus ?? this.accountStatus,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActive: lastActive ?? this.lastActive,
      trustScore: trustScore ?? this.trustScore,
      badges: badges ?? this.badges,
      preferredCurrencies: preferredCurrencies ?? this.preferredCurrencies,
      preferredPaymentMethods:
          preferredPaymentMethods ?? this.preferredPaymentMethods,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      avgCompletionTime: avgCompletionTime ?? this.avgCompletionTime,
      reviews: reviews ?? this.reviews,
    );
  }

  // Helper methods
  bool get isVerified =>
      verificationLevel != null && verificationLevel!.isNotEmpty;
  bool get isOnline =>
      lastActive != null &&
      DateTime.now().difference(lastActive!).inMinutes < 15;
  bool get isReliableTrader =>
      completionRate != null && completionRate! >= 95.0;
  bool get hasHighReputation => reputation != null && reputation! >= 4.0;
  bool get isNewTrader => completedTrades == null || completedTrades! < 5;

  String get displayName => name;
  String get displayInitials =>
      initials ?? (name.isNotEmpty ? name[0].toUpperCase() : 'U');
  String get displayCompletionRate =>
      completionRate != null ? '${completionRate!.toStringAsFixed(1)}%' : 'N/A';
  String get displayReputation =>
      reputation != null ? reputation!.toStringAsFixed(1) : 'N/A';
  String get displayCompletedTrades => completedTrades?.toString() ?? '0';

  int get disputeCount => previousDisputes ?? 0;
  double get disputeRate {
    final total = totalTrades ?? 0;
    final disputes = disputeCount;
    if (total == 0) return 0.0;
    return (disputes / total) * 100;
  }

  String get reliabilityBadge {
    if (isNewTrader) return 'New';
    if (disputeRate > 10) return 'Caution';
    if (isReliableTrader && hasHighReputation) return 'Trusted';
    if (isReliableTrader) return 'Reliable';
    return 'Standard';
  }

  String get onlineStatus {
    if (lastActive == null) return 'Unknown';
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 5) return 'Online';
    if (diff.inMinutes < 30) return 'Recently active';
    if (diff.inHours < 24) return 'Active today';
    if (diff.inDays < 7) return 'Active this week';
    return 'Inactive';
  }
}

class P2PUserReviewEntity extends Equatable {
  const P2PUserReviewEntity({
    required this.id,
    required this.reviewerId,
    required this.revieweeId,
    required this.tradeId,
    required this.rating,
    this.comment,
    this.communicationRating,
    this.speedRating,
    this.trustRating,
    required this.createdAt,
  });

  final String id;
  final String reviewerId;
  final String revieweeId;
  final String tradeId;
  final double rating;
  final String? comment;
  final double? communicationRating;
  final double? speedRating;
  final double? trustRating;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        reviewerId,
        revieweeId,
        tradeId,
        rating,
        comment,
        communicationRating,
        speedRating,
        trustRating,
        createdAt,
      ];

  P2PUserReviewEntity copyWith({
    String? id,
    String? reviewerId,
    String? revieweeId,
    String? tradeId,
    double? rating,
    String? comment,
    double? communicationRating,
    double? speedRating,
    double? trustRating,
    DateTime? createdAt,
  }) {
    return P2PUserReviewEntity(
      id: id ?? this.id,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      tradeId: tradeId ?? this.tradeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      communicationRating: communicationRating ?? this.communicationRating,
      speedRating: speedRating ?? this.speedRating,
      trustRating: trustRating ?? this.trustRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPositive => rating >= 4.0;
  bool get isNegative => rating <= 2.0;
  String get displayRating => rating.toStringAsFixed(1);
}
