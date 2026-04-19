import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/creator_investor_entity.dart';

abstract class CreatorInvestorsState extends Equatable {
  const CreatorInvestorsState();

  @override
  List<Object?> get props => [];
}

class CreatorInvestorsInitial extends CreatorInvestorsState {
  const CreatorInvestorsInitial();
}

class CreatorInvestorsLoading extends CreatorInvestorsState {
  const CreatorInvestorsLoading();
}

class CreatorInvestorsLoaded extends CreatorInvestorsState {
  const CreatorInvestorsLoaded({
    required this.investors,
    required this.hasMore,
    required this.currentPage,
    this.searchQuery,
  });

  final List<CreatorInvestorEntity> investors;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;

  @override
  List<Object?> get props => [investors, hasMore, currentPage, searchQuery];

  CreatorInvestorsLoaded copyWith({
    List<CreatorInvestorEntity>? investors,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    return CreatorInvestorsLoaded(
      investors: investors ?? this.investors,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CreatorInvestorsError extends CreatorInvestorsState {
  const CreatorInvestorsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class CreatorInvestorsEmpty extends CreatorInvestorsState {
  const CreatorInvestorsEmpty({this.searchQuery});

  final String? searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}
