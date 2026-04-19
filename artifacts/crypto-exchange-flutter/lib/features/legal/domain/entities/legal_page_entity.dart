import 'package:equatable/equatable.dart';

/// Entity for legal/content pages (privacy, terms, about, contact)
class LegalPageEntity extends Equatable {
  final String pageId;
  final String title;
  final String content;
  final LegalPageMeta? meta;
  final String status;
  final String pageSource;

  const LegalPageEntity({
    required this.pageId,
    required this.title,
    required this.content,
    this.meta,
    required this.status,
    required this.pageSource,
  });

  @override
  List<Object?> get props => [pageId, title, content, meta, status, pageSource];
}

/// Metadata for legal pages (SEO)
class LegalPageMeta extends Equatable {
  final String? title;
  final String? description;
  final List<String>? keywords;

  const LegalPageMeta({
    this.title,
    this.description,
    this.keywords,
  });

  @override
  List<Object?> get props => [title, description, keywords];
}

/// Enum for legal page types
enum LegalPageType {
  privacy('privacy', 'Privacy Policy'),
  terms('terms', 'Terms of Service'),
  about('about', 'About Us'),
  contact('contact', 'Contact Us');

  final String id;
  final String title;

  const LegalPageType(this.id, this.title);

  static LegalPageType fromId(String id) {
    return LegalPageType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => LegalPageType.privacy,
    );
  }
}
