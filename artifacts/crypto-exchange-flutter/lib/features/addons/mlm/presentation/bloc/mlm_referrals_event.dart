import 'package:equatable/equatable.dart';

abstract class MlmReferralsEvent extends Equatable {
  const MlmReferralsEvent();

  @override
  List<Object?> get props => [];
}

class MlmReferralsLoadRequested extends MlmReferralsEvent {
  const MlmReferralsLoadRequested({
    this.page = 1,
    this.perPage = 10,
    this.forceRefresh = false,
  });

  final int page;
  final int perPage;
  final bool forceRefresh;

  @override
  List<Object?> get props => [page, perPage, forceRefresh];
}

class MlmReferralsRefreshRequested extends MlmReferralsEvent {
  const MlmReferralsRefreshRequested({
    this.perPage = 10,
  });

  final int perPage;

  @override
  List<Object?> get props => [perPage];
}

class MlmReferralsLoadMoreRequested extends MlmReferralsEvent {
  const MlmReferralsLoadMoreRequested({
    required this.nextPage,
    this.perPage = 10,
  });

  final int nextPage;
  final int perPage;

  @override
  List<Object?> get props => [nextPage, perPage];
}

class MlmReferralDetailRequested extends MlmReferralsEvent {
  const MlmReferralDetailRequested({
    required this.referralId,
  });

  final String referralId;

  @override
  List<Object?> get props => [referralId];
}

class MlmReferralAnalysisRequested extends MlmReferralsEvent {
  const MlmReferralAnalysisRequested({
    required this.referralId,
    required this.analysisData,
  });

  final String referralId;
  final Map<String, dynamic> analysisData;

  @override
  List<Object?> get props => [referralId, analysisData];
}

class MlmReferralsRetryRequested extends MlmReferralsEvent {
  const MlmReferralsRetryRequested({
    this.page = 1,
    this.perPage = 10,
  });

  final int page;
  final int perPage;

  @override
  List<Object?> get props => [page, perPage];
}
