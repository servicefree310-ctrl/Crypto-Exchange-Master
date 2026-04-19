import 'package:equatable/equatable.dart';

abstract class GuidedMatchingEvent extends Equatable {
  const GuidedMatchingEvent();
  @override
  List<Object?> get props => [];
}

/// User updates a single field in the matching form (e.g. amount, payment method)
class GuidedMatchingFieldUpdated extends GuidedMatchingEvent {
  const GuidedMatchingFieldUpdated({required this.field, required this.value});
  final String field;
  final dynamic value;
  @override
  List<Object?> get props => [field, value];
}

/// User submits criteria to find matches
class GuidedMatchingRequested extends GuidedMatchingEvent {
  const GuidedMatchingRequested();
}

/// Retry after failure
class GuidedMatchingRetryRequested extends GuidedMatchingEvent {
  const GuidedMatchingRetryRequested();
}
