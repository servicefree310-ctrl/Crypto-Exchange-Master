import 'package:equatable/equatable.dart';

abstract class TradesEvent extends Equatable {
  const TradesEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load or refresh of trade list and dashboard metrics
class TradesRequested extends TradesEvent {
  const TradesRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => [refresh];
}

/// Load next page of trades for infinite scrolling
class TradesLoadMoreRequested extends TradesEvent {
  const TradesLoadMoreRequested();
}

/// User applies a status filter (active, completed, etc.)
class TradesFilterChanged extends TradesEvent {
  const TradesFilterChanged(this.status);
  final String? status; // null => all statuses
  @override
  List<Object?> get props => [status];
}
