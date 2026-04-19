import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import 'package:mobile/core/constants/api_constants.dart';
import '../bloc/blog_bloc.dart';
import '../widgets/blog_category_chips.dart';
import '../widgets/blog_featured_section.dart';
import '../widgets/blog_post_card.dart';
import '../widgets/blog_search_bar.dart';
import 'blog_post_detail_page.dart';
import '../../domain/entities/blog_post_entity.dart';
import 'package:mobile/injection/injection.dart';
import '../widgets/blog_authors_section.dart';
import 'author_application_page.dart';
import '../bloc/authors_bloc.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../profile/data/services/profile_service.dart';
import '../widgets/blog_loading_shimmer.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<BlogBloc>().add(const BlogLoadPostsRequested(refresh: true));
    context.read<BlogBloc>().add(const BlogLoadCategoriesRequested());
    context.read<BlogBloc>().add(const BlogLoadTagsRequested());
    context.read<BlogBloc>().add(const BlogLoadAuthorsRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BlogBloc>().add(const BlogLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<BlogBloc>().add(BlogLoadPostsRequested(
          category: category,
          refresh: true,
        ));
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<BlogBloc>().add(BlogLoadPostsRequested(
            category: _selectedCategory,
            refresh: true,
          ));
    } else {
      context.read<BlogBloc>().add(BlogSearchRequested(query));
    }
  }

  Map<String, dynamic> _postToMap(BlogPostEntity post) {
    return {
      'id': post.id,
      'title': post.title,
      'content': post.content,
      'slug': post.slug,
      'status': post.status.name,
      'description': post.description,
      'image': post.image,
      'views': post.views,
      'categoryId': post.categoryId,
      'authorId': post.authorId,
      'createdAt': post.createdAt?.toIso8601String(),
      'updatedAt': post.updatedAt?.toIso8601String(),
      'deletedAt': post.deletedAt?.toIso8601String(),
      'category': post.category != null ? _categoryToMap(post.category!) : null,
      'author': post.author != null ? _authorToMap(post.author!) : null,
      'tags': post.tags.map(_tagToMap).toList(),
      'comments': post.comments.map(_commentToMap).toList(),
      'relatedPosts': post.relatedPosts.map(_postToMap).toList(),
    };
  }

  Map<String, dynamic> _categoryToMap(BlogCategoryEntity category) {
    return {
      'id': category.id,
      'name': category.name,
      'slug': category.slug,
      'description': category.description,
      'image': category.image,
      'postCount': category.postCount,
      'createdAt': category.createdAt?.toIso8601String(),
      'updatedAt': category.updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _authorToMap(BlogAuthorEntity author) {
    return {
      'id': author.id,
      'userId': author.userId,
      'user': author.user != null ? _userToMap(author.user!) : null,
      'bio': author.bio,
      'postCount': author.postCount,
    };
  }

  Map<String, dynamic> _userToMap(BlogUserEntity user) {
    return {
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'avatar': user.avatar,
      'role': user.role != null ? _roleToMap(user.role!) : null,
    };
  }

  String _getCategoryName(
      List<BlogCategoryEntity> categories, String categoryId) {
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (e) {
      return 'Unknown Category';
    }
  }

  Map<String, dynamic> _roleToMap(BlogRoleEntity role) {
    return {
      'name': role.name,
    };
  }

  Map<String, dynamic> _tagToMap(BlogTagEntity tag) {
    return {
      'id': tag.id,
      'name': tag.name,
      'slug': tag.slug,
      'description': tag.description,
      'postCount': tag.postCount,
      'createdAt': tag.createdAt?.toIso8601String(),
      'updatedAt': tag.updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _commentToMap(BlogCommentEntity comment) {
    return {
      'id': comment.id,
      'content': comment.content,
      'postId': comment.postId,
      'userId': comment.userId,
      'createdAt': comment.createdAt?.toIso8601String(),
      'updatedAt': comment.updatedAt?.toIso8601String(),
      'user': comment.user != null ? _userToMap(comment.user!) : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      backgroundColor: context.colors.surface,
      floatingActionButton: _buildFloatingActionButton(context, authState),
      body: SafeArea(
        child: Column(
          children: [
            // Mobile-First Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back,
                            color: context.colors.onSurface),
                      ),
                      Expanded(
                        child: Text(
                          '${AppConstants.appName} Blog',
                          style: context.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay updated with the latest crypto insights',
                    style: context.bodyM.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlogSearchBar(
                    onChanged: _onSearchChanged,
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<BlogBloc, BlogState>(
                builder: (context, state) {
                  if (state is BlogLoading) {
                    return const BlogListLoadingShimmer();
                  }

                  if (state is BlogError) {
                    return _buildErrorState(context, state);
                  }

                  if (state is BlogPostsLoaded) {
                    return _buildLoadedState(context, state);
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, AuthState authState) {
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    // Get author status from ProfileService (most up-to-date)
    final profileService = getIt<ProfileService>();
    final isApprovedAuthor = profileService.isApprovedAuthor;
    final hasPendingApplication = profileService.hasPendingAuthorApplication;

    if (isApprovedAuthor) {
      // Show Create Post button for approved authors
      return FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create post page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create post feature coming soon!')),
          );
        },
        backgroundColor: context.priceUpColor,
        foregroundColor: context.colors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
      );
    } else {
      // Show Become Author button for non-authors
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => getIt<AuthorsBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<AuthBloc>(),
                  ),
                ],
                child: const AuthorApplicationPage(),
              ),
            ),
          );
        },
        backgroundColor: context.orangeAccent,
        foregroundColor: context.colors.onPrimary,
        icon: const Icon(Icons.edit_note),
        label: Text(
            hasPendingApplication ? 'Application Pending' : 'Become an Author'),
      );
    }
  }

  Widget _buildErrorState(BuildContext context, BlogError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.priceDownColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: context.priceDownColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load blog posts',
              style: context.h4.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.failure.message,
              textAlign: TextAlign.center,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context
                    .read<BlogBloc>()
                    .add(const BlogLoadPostsRequested(refresh: true));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, BlogPostsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<BlogBloc>().add(const BlogRefreshRequested());
      },
      color: context.colors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Featured Posts Section - Mobile Optimized
          if (state.posts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: BlogFeaturedSection(
                featuredPosts: state.posts.take(3).map(_postToMap).toList(),
              ),
            ),
          ],

          // Authors Section - Horizontal Scroll
          if (state.authors.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: BlogAuthorsSection(
                authors: state.authors.map(_authorToMap).toList(),
              ),
            ),
          ],

          // Categories Section - Chips
          if (state.categories.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: BlogCategoryChips(
                categories: state.categories.map(_categoryToMap).toList(),
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
            ),
          ],

          // Posts Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    _selectedCategory != null
                        ? 'Posts in ${_getCategoryName(state.categories, _selectedCategory!)}'
                        : 'Latest Articles',
                    style: context.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (state.pagination.totalItems > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.posts.length} of ${state.pagination.totalItems}',
                        style: context.bodyS.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Posts List or Empty State
          if (state.posts.isEmpty) ...[
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No posts found',
                        style: context.h5.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCategory != null
                            ? 'Try selecting a different category'
                            : 'Check back later for new content',
                        style: context.bodyM.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.posts.length) {
                      // Loading more indicator
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                        ),
                      );
                    }

                    final post = state.posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BlogPostCard(
                        post: _postToMap(post),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (_) => getIt<BlogBloc>(),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<AuthBloc>(),
                                  ),
                                ],
                                child: BlogPostDetailPage(slug: post.slug),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount:
                      state.posts.length + (state is BlogLoadingMore ? 1 : 0),
                ),
              ),
            ),
          ],

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
