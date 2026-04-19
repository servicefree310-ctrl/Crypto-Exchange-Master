import 'package:equatable/equatable.dart';

class NewsEntity extends Equatable {
  const NewsEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.categories,
    required this.sentiment,
    required this.readTime,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;
  final List<String> categories;
  final String sentiment; // positive, negative, neutral
  final int readTime; // in minutes

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        content,
        url,
        imageUrl,
        source,
        publishedAt,
        categories,
        sentiment,
        readTime,
      ];

  NewsEntity copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? url,
    String? imageUrl,
    String? source,
    DateTime? publishedAt,
    List<String>? categories,
    String? sentiment,
    int? readTime,
  }) {
    return NewsEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      categories: categories ?? this.categories,
      sentiment: sentiment ?? this.sentiment,
      readTime: readTime ?? this.readTime,
    );
  }
}

class NewsCategoryEntity extends Equatable {
  const NewsCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
  });

  final String id;
  final String name;
  final String icon;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, icon, isActive];

  NewsCategoryEntity copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isActive,
  }) {
    return NewsCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}
