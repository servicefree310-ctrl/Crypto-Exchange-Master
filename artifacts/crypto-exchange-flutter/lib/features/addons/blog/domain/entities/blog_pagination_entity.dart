import 'package:equatable/equatable.dart';

class BlogPaginationEntity<T> extends Equatable {
  const BlogPaginationEntity({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });

  final List<T> data;
  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  @override
  List<Object?> get props => [
        data,
        currentPage,
        perPage,
        totalItems,
        totalPages,
      ];

  BlogPaginationEntity<T> copyWith({
    List<T>? data,
    int? currentPage,
    int? perPage,
    int? totalItems,
    int? totalPages,
  }) {
    return BlogPaginationEntity<T>(
      data: data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
