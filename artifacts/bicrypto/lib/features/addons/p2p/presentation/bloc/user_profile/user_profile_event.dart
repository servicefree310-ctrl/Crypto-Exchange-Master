import 'package:equatable/equatable.dart';

abstract class P2PUserProfileEvent extends Equatable {
  const P2PUserProfileEvent();
  @override
  List<Object?> get props => [];
}

class P2PUserProfileRequested extends P2PUserProfileEvent {
  const P2PUserProfileRequested(this.userId, {this.refresh = false});
  final String userId;
  final bool refresh;
  @override
  List<Object?> get props => [userId, refresh];
}

class P2PUserProfileRetryRequested extends P2PUserProfileEvent {
  const P2PUserProfileRetryRequested();
}
