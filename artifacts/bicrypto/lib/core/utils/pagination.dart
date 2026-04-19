import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.data,
    required this.pagination,
  });

  final List<T> data;
  final PaginationMeta pagination;

  bool get hasNextPage => pagination.hasNextPage;
  bool get hasPreviousPage => pagination.hasPreviousPage;

  @override
  List<Object?> get props => [data, pagination];

  PaginatedResult<T> copyWith({
    List<T>? data,
    PaginationMeta? pagination,
  }) {
    return PaginatedResult<T>(
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }
}

class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });

  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  @override
  List<Object?> get props => [
        currentPage,
        perPage,
        totalItems,
        totalPages,
      ];

  PaginationMeta copyWith({
    int? currentPage,
    int? perPage,
    int? totalItems,
    int? totalPages,
  }) {
    return PaginationMeta(
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
