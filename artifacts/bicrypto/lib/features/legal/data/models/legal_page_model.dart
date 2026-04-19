import '../../domain/entities/legal_page_entity.dart';

class LegalPageModel extends LegalPageEntity {
  const LegalPageModel({
    required super.pageId,
    required super.title,
    required super.content,
    super.meta,
    required super.status,
    required super.pageSource,
  });

  factory LegalPageModel.fromJson(Map<String, dynamic> json) {
    // Parse meta field safely - it could be a Map or a String
    LegalPageMetaModel? metaModel;
    if (json['meta'] != null) {
      final metaField = json['meta'];
      if (metaField is Map<String, dynamic>) {
        metaModel = LegalPageMetaModel.fromJson(metaField);
      } else if (metaField is String) {
        // If meta is a string, skip it or log a warning
        // This shouldn't happen with proper API responses
        metaModel = null;
      }
    }

    return LegalPageModel(
      pageId: json['pageId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      meta: metaModel,
      status: json['status'] as String? ?? 'active',
      pageSource: json['pageSource'] as String? ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'title': title,
      'content': content,
      'meta': meta != null ? (meta as LegalPageMetaModel).toJson() : null,
      'status': status,
      'pageSource': pageSource,
    };
  }
}

class LegalPageMetaModel extends LegalPageMeta {
  const LegalPageMetaModel({
    super.title,
    super.description,
    super.keywords,
  });

  factory LegalPageMetaModel.fromJson(Map<String, dynamic> json) {
    List<String>? keywordsList;
    if (json['keywords'] != null) {
      if (json['keywords'] is List) {
        keywordsList = (json['keywords'] as List).map((e) => e.toString()).toList();
      } else if (json['keywords'] is String) {
        keywordsList = [json['keywords'] as String];
      }
    }

    return LegalPageMetaModel(
      // Backend returns seoTitle and seoDescription, map them to title and description
      title: json['seoTitle'] as String? ?? json['title'] as String?,
      description: json['seoDescription'] as String? ?? json['description'] as String?,
      keywords: keywordsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'keywords': keywords,
    };
  }
}
