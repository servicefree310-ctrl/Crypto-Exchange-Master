import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/p2p_user_entity.dart';

part 'p2p_user_model.freezed.dart';
part 'p2p_user_model.g.dart';

@freezed
class P2PUserModel with _$P2PUserModel {
  const factory P2PUserModel({
    required String id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    Map<String, dynamic>? profile,
    bool? emailVerified,
    // P2P related fields
    List<Map<String, dynamic>>? p2pTrades,
    List<Map<String, dynamic>>? receivedReviews,
  }) = _P2PUserModel;

  factory P2PUserModel.fromJson(Map<String, dynamic> json) =>
      _$P2PUserModelFromJson(json);
}

extension P2PUserModelX on P2PUserModel {
  P2PUserEntity toEntity() {
    final fullName = [firstName, lastName]
        .where((name) => name != null && name.isNotEmpty)
        .join(' ')
        .trim();

    return P2PUserEntity(
      id: id,
      name: fullName.isNotEmpty ? fullName : 'Unknown User',
      email: email,
      avatar: avatar,
      verificationLevel: emailVerified == true ? 'verified' : null,
      // Calculate stats from p2pTrades
      totalTrades: p2pTrades?.length ?? 0,
      completedTrades:
          p2pTrades?.where((t) => t['status'] == 'COMPLETED').length ?? 0,
      reputation: _calculateAverageRating(receivedReviews),
      joinedDate: DateTime.now(), // Will be updated from user profile
      lastActive: DateTime.now(), // Will be updated from user profile
    );
  }

  double _calculateAverageRating(List<Map<String, dynamic>>? reviews) {
    if (reviews == null || reviews.isEmpty) return 0.0;

    double totalRating = 0.0;
    int count = 0;

    for (final review in reviews) {
      double reviewAvg = 0.0;
      int ratingCount = 0;

      final commRating = (review['communicationRating'] as num?)?.toDouble();
      final speedRating = (review['speedRating'] as num?)?.toDouble();
      final trustRating = (review['trustRating'] as num?)?.toDouble();

      if (commRating != null) {
        reviewAvg += commRating;
        ratingCount++;
      }
      if (speedRating != null) {
        reviewAvg += speedRating;
        ratingCount++;
      }
      if (trustRating != null) {
        reviewAvg += trustRating;
        ratingCount++;
      }

      if (ratingCount > 0) {
        totalRating += reviewAvg / ratingCount;
        count++;
      }
    }

    return count > 0 ? totalRating / count : 0.0;
  }
}
