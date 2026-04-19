import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/blog_post_model.dart';

abstract class BlogRemoteDataSource {
  Future<BlogPostsResponseModel> getPosts({
    int page = 1,
    int perPage = 10,
    String? category,
    String? tag,
    String? search,
    String? sortField,
    String? sortDirection,
  });

  Future<BlogPostModel> getPost(String slug);

  Future<List<BlogCategoryModel>> getCategories();

  Future<List<BlogTagModel>> getTags();

  Future<List<BlogAuthorModel>> getTopAuthors();

  Future<List<BlogCommentModel>> getPostComments(String postId);

  Future<BlogCommentModel> addComment({
    required String postId,
    required String content,
    required String userId,
  });

  Future<List<BlogAuthorModel>> getAuthors(
      {bool includePosts = false, String? status});

  Future<BlogAuthorModel> getAuthor(String id);

  Future<void> applyForAuthor(String userId);

  /// Get current user's author status
  Future<Map<String, dynamic>?> getCurrentUserAuthor();
}

@Injectable(as: BlogRemoteDataSource)
class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final Dio _dio;

  BlogRemoteDataSourceImpl(this._dio);

  @override
  Future<BlogPostsResponseModel> getPosts({
    int page = 1,
    int perPage = 10,
    String? category,
    String? tag,
    String? search,
    String? sortField,
    String? sortDirection,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };

      if (category != null && category.isNotEmpty) {
        queryParameters['category'] = category;
      }

      if (tag != null && tag.isNotEmpty) {
        queryParameters['tag'] = tag;
      }

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (sortField != null && sortField.isNotEmpty) {
        queryParameters['sortField'] = sortField;
      }

      if (sortDirection != null && sortDirection.isNotEmpty) {
        queryParameters['sortDirection'] = sortDirection;
      }

      final response = await _dio.get(
        ApiConstants.blogPosts,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return BlogPostsResponseModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load blog posts');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to load blog posts',
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<BlogPostModel> getPost(String slug) async {
    try {
      final response = await _dio.get('${ApiConstants.blogPostDetail}/$slug');

      if (response.statusCode == 200) {
        return BlogPostModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load blog post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Blog post not found');
      }
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to load blog post',
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BlogCategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.blogCategories);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => BlogCategoryModel.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => BlogCategoryModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException('Failed to load blog categories');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to load blog categories',
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BlogTagModel>> getTags() async {
    try {
      final response = await _dio.get(ApiConstants.blogTags);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => BlogTagModel.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => BlogTagModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException('Failed to load blog tags');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to load blog tags',
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BlogAuthorModel>> getTopAuthors() async {
    try {
      final response = await _dio.get(ApiConstants.blogTopAuthors);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => BlogAuthorModel.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => BlogAuthorModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException('Failed to load blog authors');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to load blog authors',
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BlogCommentModel>> getPostComments(String postId) async {
    try {
      final response =
          await _dio.get('${ApiConstants.blogPostComments}/$postId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => BlogCommentModel.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => BlogCommentModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException('Failed to load comments');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to load comments',
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<BlogCommentModel> addComment({
    required String postId,
    required String content,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.blogPostComments}/$postId',
        data: {
          'content': content,
          'userId': userId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BlogCommentModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to add comment');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to add comment',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<BlogAuthorModel>> getAuthors(
      {bool includePosts = false, String? status}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (includePosts) queryParameters['posts'] = 'true';
      if (status != null) queryParameters['status'] = status;

      final response = await _dio.get('${ApiConstants.blogAuthors}/all',
          queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => BlogAuthorModel.fromJson(json)).toList();
        }
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => BlogAuthorModel.fromJson(json))
              .toList();
        }
        return [];
      }
      throw ServerException('Failed to load authors');
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['message'] ?? 'Failed to load authors');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<BlogAuthorModel> getAuthor(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.blogAuthors}/$id');

      if (response.statusCode == 200) {
        return BlogAuthorModel.fromJson(response.data);
      }
      throw ServerException('Failed to load author');
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['message'] ?? 'Failed to load author');
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> applyForAuthor(String userId) async {
    try {
      final response =
          await _dio.post(ApiConstants.blogAuthors, data: {'userId': userId});
      if (response.statusCode == 200 || response.statusCode == 201) return;
      throw ServerException('Failed to apply');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Failed to apply');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUserAuthor() async {
    try {
      final response = await _dio.get(ApiConstants.blogAuthors);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      // Return null if user is not an author (404) or other errors
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException(
          e.response?.data?['message'] ?? 'Failed to get author status');
    }
  }
}
