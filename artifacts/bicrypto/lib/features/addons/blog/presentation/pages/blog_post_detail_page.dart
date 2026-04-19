import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../bloc/blog_bloc.dart';
import '../../domain/entities/blog_post_entity.dart';
import '../widgets/blog_post_card.dart';
import '../widgets/blog_author_card.dart';
import '../widgets/blog_comment_card.dart';
import '../widgets/blog_loading_shimmer.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';

class BlogPostDetailPage extends StatefulWidget {
  final String slug;

  const BlogPostDetailPage({
    super.key,
    required this.slug,
  });

  @override
  State<BlogPostDetailPage> createState() => _BlogPostDetailPageState();
}

class _BlogPostDetailPageState extends State<BlogPostDetailPage> {
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load the post
    context.read<BlogBloc>().add(BlogLoadPostRequested(widget.slug));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  String _calculateReadingTime(String content) {
    // Remove HTML tags and calculate reading time
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    final words = plainText.trim().split(RegExp(r'\s+'));
    final minutes = (words.length / 200).ceil(); // 200 words per minute
    return '$minutes min read';
  }

  String _prepareHtml(String content) {
    // If no HTML tags are present, wrap paragraphs and line breaks
    if (!content.contains('<')) {
      // Split by two or more newlines into paragraphs
      final paragraphs = content.split(RegExp(r'\n{2,}')).map((p) => p.trim());
      final htmlParagraphs = paragraphs.map((p) {
        // Within a paragraph, single newlines become <br/>
        final withBreaks = p.replaceAll('\n', '<br/>');
        return '<p>$withBreaks</p>';
      });
      return htmlParagraphs.join();
    }
    return content;
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

    return Scaffold(
      body: BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoading) {
            return const BlogLoadingShimmer();
          }

          if (state is BlogError) {
            return _buildErrorState(context, state);
          }

          if (state is BlogPostLoaded) {
            return _buildPostContent(context, state.post, state.comments);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, BlogError state) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Post'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load post',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.failure.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<BlogBloc>()
                      .add(BlogLoadPostRequested(widget.slug));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context, BlogPostEntity post,
      List<BlogCommentEntity> comments) {
    final theme = Theme.of(context);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar with Hero Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.textTheme.titleLarge?.color,
          title: _showAppBarTitle
              ? Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeroImage(post),
          ),
        ),

        // Post Content
        SliverToBoxAdapter(
          child: _buildPostBody(context, post, comments),
        ),
      ],
    );
  }

  Widget _buildHeroImage(BlogPostEntity post) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        if (post.image != null)
          CachedNetworkImage(
            imageUrl: post.image!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Theme.of(context).cardColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).cardColor,
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // Category Badge
        Positioned(
          bottom: 80,
          left: 16,
          child: post.category != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.category!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Post Title
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPostBody(BuildContext context, BlogPostEntity post,
      List<BlogCommentEntity> comments) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Meta Information
          _buildPostMeta(context, post),

          const SizedBox(height: 24),

          // Post Description
          if (post.description != null && post.description!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                post.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Post Content
          Html(
            data: _prepareHtml(post.content),
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.6),
                color: theme.textTheme.bodyLarge?.color,
              ),
              "h1": Style(
                fontSize: FontSize(24),
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
                margin: Margins.only(top: 24, bottom: 16),
              ),
              "h2": Style(
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
                margin: Margins.only(top: 20, bottom: 12),
              ),
              "h3": Style(
                fontSize: FontSize(18),
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleSmall?.color,
                margin: Margins.only(top: 16, bottom: 8),
              ),
              "p": Style(
                margin: Margins.only(bottom: 16),
              ),
              "blockquote": Style(
                backgroundColor: theme.cardColor,
                border: Border(
                  left: BorderSide(
                    color: theme.primaryColor,
                    width: 4,
                  ),
                ),
                padding: HtmlPaddings.all(16),
                margin: Margins.symmetric(vertical: 16),
              ),
              "code": Style(
                backgroundColor: theme.cardColor,
                padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
                fontFamily: 'monospace',
              ),
              "pre": Style(
                backgroundColor: theme.cardColor,
                padding: HtmlPaddings.all(16),
                margin: Margins.symmetric(vertical: 16),
              ),
            },
          ),

          const SizedBox(height: 32),

          // Tags
          if (post.tags.isNotEmpty) ...[
            _buildTagsSection(context, post.tags),
            const SizedBox(height: 32),
          ],

          // Author Section
          if (post.author != null) ...[
            _buildAuthorSection(context, post.author!),
            const SizedBox(height: 32),
          ],

          // Comments Section
          if (comments.isNotEmpty) ...[
            _buildCommentsSection(context, comments),
            const SizedBox(height: 32),
          ],

          // Related Posts
          if (post.relatedPosts.isNotEmpty) ...[
            _buildRelatedPostsSection(context, post.relatedPosts),
          ],
        ],
      ),
    );
  }

  Widget _buildPostMeta(BuildContext context, BlogPostEntity post) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Row(
      children: [
        // Author Avatar
        if (post.author?.user?.avatar != null)
          CachedNetworkImage(
            imageUrl: post.author!.user!.avatar!,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 20,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => CircleAvatar(
              radius: 20,
              backgroundColor: theme.cardColor,
              child: const SizedBox.shrink(),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 20,
              backgroundColor: theme.primaryColor,
              child: Text(
                post.author?.user?.firstName.substring(0, 1).toUpperCase() ??
                    'A',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.primaryColor,
            child: Text(
              post.author?.user?.firstName.substring(0, 1).toUpperCase() ?? 'A',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Name
              if (post.author?.user != null)
                Text(
                  post.author!.user!.fullName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

              // Date and Reading Time
              Row(
                children: [
                  if (post.createdAt != null) ...[
                    Text(
                      dateFormat.format(post.createdAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _calculateReadingTime(post.content),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  if (post.views != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.views} views',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context, List<BlogTagEntity> tags) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAuthorSection(BuildContext context, BlogAuthorEntity author) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Author',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        BlogAuthorCard(author: author),
      ],
    );
  }

  Widget _buildCommentsSection(
      BuildContext context, List<BlogCommentEntity> comments) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${comments.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...comments.map((comment) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BlogCommentCard(comment: comment),
            )),
        const SizedBox(height: 16),
        _buildCommentInput(context),
      ],
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    final theme = Theme.of(context);
    AuthState? authState;
    try {
      authState = context.read<AuthBloc>().state;
    } catch (_) {}
    if (authState is! AuthAuthenticated) {
      return TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to comment')),
          );
        },
        child: const Text('Login to comment'),
      );
    }

    final controller = TextEditingController();
    String? postId;
    final blocState = context.read<BlogBloc>().state;
    if (blocState is BlogPostLoaded) {
      postId = blocState.post.id;
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Add a comment…',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            final userId = (authState as AuthAuthenticated).user.id;
            if (postId != null) {
              context.read<BlogBloc>().add(
                    BlogAddCommentRequested(
                      postId: postId,
                      content: text,
                      userId: userId,
                    ),
                  );
            }
            controller.clear();
          },
        ),
      ],
    );
  }

  Widget _buildRelatedPostsSection(
      BuildContext context, List<BlogPostEntity> relatedPosts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Posts',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedPosts.length,
            itemBuilder: (context, index) {
              final post = relatedPosts[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < relatedPosts.length - 1 ? 16 : 0,
                ),
                child: BlogPostCard(
                  post: _postToMap(post),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BlogPostDetailPage(slug: post.slug),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
