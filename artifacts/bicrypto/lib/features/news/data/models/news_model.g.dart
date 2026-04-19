// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsModelImpl _$$NewsModelImplFromJson(Map<String, dynamic> json) =>
    _$NewsModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String,
      source: json['source'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sentiment: json['sentiment'] as String,
      readTime: (json['read_time'] as num).toInt(),
    );

Map<String, dynamic> _$$NewsModelImplToJson(_$NewsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'content': instance.content,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
      'source': instance.source,
      'published_at': instance.publishedAt.toIso8601String(),
      'categories': instance.categories,
      'sentiment': instance.sentiment,
      'read_time': instance.readTime,
    };
