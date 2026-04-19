part of 'trading_pair_selector_bloc.dart';

abstract class TradingPairSelectorState extends Equatable {
  const TradingPairSelectorState();

  @override
  List<Object?> get props => [];
}

class TradingPairSelectorInitial extends TradingPairSelectorState {
  const TradingPairSelectorInitial();
}

class TradingPairSelectorLoading extends TradingPairSelectorState {
  const TradingPairSelectorLoading();
}

class TradingPairSelectorLoaded extends TradingPairSelectorState {
  const TradingPairSelectorLoaded({
    required this.allPairs,
    required this.filteredPairs,
    required this.availableCategories,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.isRealtime = false,
  });

  final List<TradingPairEntity> allPairs;
  final List<TradingPairEntity> filteredPairs;
  final List<String> availableCategories;
  final String searchQuery;
  final String selectedCategory;
  final bool isRealtime;

  @override
  List<Object?> get props => [
        allPairs,
        filteredPairs,
        availableCategories,
        searchQuery,
        selectedCategory,
        isRealtime,
      ];

  TradingPairSelectorLoaded copyWith({
    List<TradingPairEntity>? allPairs,
    List<TradingPairEntity>? filteredPairs,
    List<String>? availableCategories,
    String? searchQuery,
    String? selectedCategory,
    bool? isRealtime,
  }) {
    return TradingPairSelectorLoaded(
      allPairs: allPairs ?? this.allPairs,
      filteredPairs: filteredPairs ?? this.filteredPairs,
      availableCategories: availableCategories ?? this.availableCategories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRealtime: isRealtime ?? this.isRealtime,
    );
  }
}

class TradingPairSelectorError extends TradingPairSelectorState {
  const TradingPairSelectorError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
