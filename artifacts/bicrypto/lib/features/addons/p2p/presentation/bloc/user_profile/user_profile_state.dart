import 'package:equatable/equatable.dart';
import '../../../domain/usecases/reviews/get_user_reviews_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class P2PUserProfileState extends Equatable {
  const P2PUserProfileState();
  @override
  List<Object?> get props => [];
}

class P2PUserProfileInitial extends P2PUserProfileState {
  const P2PUserProfileInitial();
}

class P2PUserProfileLoading extends P2PUserProfileState {
  const P2PUserProfileLoading({this.isRefresh = false});
  final bool isRefresh;
  @override
  List<Object?> get props => [isRefresh];
}

class P2PUserProfileLoaded extends P2PUserProfileState {
  const P2PUserProfileLoaded(this.response);
  final UserReviewsResponse response;
  @override
  List<Object?> get props => [response];
}

class P2PUserProfileError extends P2PUserProfileState {
  const P2PUserProfileError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
