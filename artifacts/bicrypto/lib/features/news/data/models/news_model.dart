import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/news_entity.dart';

part 'news_model.freezed.dart';
part 'news_model.g.dart';

@freezed
class NewsModel with _$NewsModel {
  const factory NewsModel({
    required String id,
    required String title,
    required String summary,
    required String content,
    required String url,
    required String imageUrl,
    required String source,
    @JsonKey(name: 'published_at') required DateTime publishedAt,
    required List<String> categories,
    required String sentiment,
    @JsonKey(name: 'read_time') required int readTime,
  }) = _NewsModel;

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);
}

extension NewsModelX on NewsModel {
  NewsEntity toEntity() {
    return NewsEntity(
      id: id,
      title: title,
      summary: summary,
      content: content,
      url: url,
      imageUrl: imageUrl,
      source: source,
      publishedAt: publishedAt,
      categories: categories,
      sentiment: sentiment,
      readTime: readTime,
    );
  }
}
