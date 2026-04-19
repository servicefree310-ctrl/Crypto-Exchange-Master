import 'package:equatable/equatable.dart';

abstract class CreatorInvestorsEvent extends Equatable {
  const CreatorInvestorsEvent();

  @override
  List<Object?> get props => [];
}

class CreatorInvestorsLoadRequested extends CreatorInvestorsEvent {
  const CreatorInvestorsLoadRequested({
    this.page = 1,
    this.search,
    this.sortField,
    this.sortDirection,
  });

  final int page;
  final String? search;
  final String? sortField;
  final String? sortDirection;

  @override
  List<Object?> get props => [page, search, sortField, sortDirection];
}

class CreatorInvestorsRefreshRequested extends CreatorInvestorsEvent {
  const CreatorInvestorsRefreshRequested();
}

class CreatorInvestorsSearchChanged extends CreatorInvestorsEvent {
  const CreatorInvestorsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
