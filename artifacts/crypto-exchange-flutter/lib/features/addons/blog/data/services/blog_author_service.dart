import 'dart:async';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';
import '../../../../auth/domain/entities/author_entity.dart';
import '../datasources/blog_remote_datasource.dart';

@injectable
class BlogAuthorService {
  final BlogRemoteDataSource _blogDataSource;

  BlogAuthorService(this._blogDataSource);

  /// Get current user's author status from blog API
  Future<AuthorEntity?> getCurrentUserAuthor() async {
    try {
      dev.log('🔵 BLOG_AUTHOR_SERVICE: Fetching current user author status');

      final authorData = await _blogDataSource.getCurrentUserAuthor();

      if (authorData == null) {
        dev.log('🔵 BLOG_AUTHOR_SERVICE: User is not an author');
        return null;
      }

      dev.log('🟢 BLOG_AUTHOR_SERVICE: Author data received: $authorData');

      return AuthorEntity(
        id: authorData['id'] as String,
        status: _parseAuthorStatus(authorData['status'] as String),
        bio: authorData['bio'] as String?,
        postCount: (authorData['posts'] as List?)?.length ?? 0,
      );
    } catch (e) {
      dev.log('🔴 BLOG_AUTHOR_SERVICE: Error fetching author status: $e');
      return null;
    }
  }

  /// Apply to become an author
  Future<void> applyForAuthor(String userId) async {
    dev.log(
        '🔵 BLOG_AUTHOR_SERVICE: Applying for author status for user: $userId');
    await _blogDataSource.applyForAuthor(userId);
    dev.log('🟢 BLOG_AUTHOR_SERVICE: Author application submitted');
  }

  /// Parse author status from string
  AuthorStatus _parseAuthorStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AuthorStatus.pending;
      case 'APPROVED':
        return AuthorStatus.approved;
      case 'REJECTED':
        return AuthorStatus.rejected;
      default:
        return AuthorStatus.pending;
    }
  }
}
