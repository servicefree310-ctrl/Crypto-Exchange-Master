import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../bloc/blog_bloc.dart';
import '../pages/blog_post_detail_page.dart';
import '../../../../../core/utils/url_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/injection/injection.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';

class BlogFeaturedSection extends StatelessWidget {
  final List<Map<String, dynamic>> featuredPosts;

  const BlogFeaturedSection({
    super.key,
    required this.featuredPosts,
  });

  @override
  Widget build(BuildContext context) {
    if (featuredPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: context.orangeAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Featured Articles',
                style: context.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: PageView.builder(
              itemCount: featuredPosts.length,
              itemBuilder: (context, index) {
                final post = featuredPosts[index];
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: FeaturedPostCard(post: post),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const FeaturedPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
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
                child: BlogPostDetailPage(slug: post['slug']),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary.withValues(alpha: 0.8),
                context.colors.tertiary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Image
              if (post['image'] != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: UrlUtils.normalise(post['image']),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.colors.primary.withValues(alpha: 0.8),
                              context.colors.tertiary.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        context.colors.surface.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    if (post['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          post['category']['name'] ?? '',
                          style: context.bodyS.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      post['title'] ?? '',
                      style: context.h5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Description
                    if (post['description'] != null)
                      Text(
                        post['description'],
                        style: context.bodyM.copyWith(
                          color: context.colors.onPrimary.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 12),

                    // Author and Date
                    Row(
                      children: [
                        if (post['author'] != null &&
                            post['author']['user'] != null)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: post['author']['user']
                                            ['avatar'] !=
                                        null
                                    ? CachedNetworkImageProvider(
                                        UrlUtils.normalise(
                                            post['author']['user']['avatar']))
                                    : null,
                                backgroundColor: context.colors.surface,
                                child: post['author']['user']['avatar'] == null
                                    ? Text(
                                        post['author']['user']['firstName']
                                                ?[0] ??
                                            'A',
                                        style: context.bodyS.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${post['author']['user']['firstName']} ${post['author']['user']['lastName']}',
                                style: context.bodyS.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        if (post['createdAt'] != null)
                          Text(
                            _formatDate(post['createdAt']),
                            style: context.bodyS.copyWith(
                              color: context.colors.onPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
