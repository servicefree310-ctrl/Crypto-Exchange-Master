import 'package:flutter/material.dart';
import '../../../../../core/utils/url_utils.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlogPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;

  const BlogPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with improved mobile design
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    // Background gradient as fallback
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colors.primary.withValues(alpha: 0.8),
                            context.colors.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    // Image
                    if (post['image'] != null)
                      CachedNetworkImage(
                        imageUrl: UrlUtils.normalise(post['image']),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: context.cardBackground,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colors.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.colors.primary.withValues(alpha: 0.8),
                                context.colors.secondary.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.article,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),

                    // Gradient overlay for better text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.7, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Category Badge - Mobile optimized
                    if (post['category'] != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            post['category']['name'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    // Reading Time Badge - Better visibility
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _calculateReadingTime(post['content'] ?? ''),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section - Mobile optimized padding
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Better typography
                  Text(
                    post['title'] ?? '',
                    style: context.h5.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description - Improved readability
                  if (post['description'] != null)
                    Text(
                      post['description'],
                      style: context.bodyM.copyWith(
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // Author and Date Row - Better mobile layout
                  Row(
                    children: [
                      // Author Avatar and Name
                      if (post['author'] != null &&
                          post['author']['user'] != null)
                        Expanded(
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    post['author']['user']['avatar'] != null
                                        ? UrlUtils.normalise(
                                            post['author']['user']['avatar'])
                                        : '',
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                  radius: 14,
                                  backgroundImage: imageProvider,
                                ),
                                placeholder: (context, url) => CircleAvatar(
                                  radius: 14,
                                  backgroundColor: context.cardBackground,
                                ),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  radius: 14,
                                  backgroundColor: context.colors.primary,
                                  child: Text(
                                    post['author']['user']['firstName']?[0] ??
                                        'A',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${post['author']['user']['firstName']} ${post['author']['user']['lastName']}',
                                  style: context.bodyS.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Date and Views
                      Row(
                        children: [
                          if (post['createdAt'] != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(post['createdAt']),
                              style: context.labelS.copyWith(
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                          if (post['views'] != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.visibility,
                              size: 12,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatViews(post['views']),
                              style: context.labelS.copyWith(
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  // Tags - Mobile optimized
                  if (post['tags'] != null &&
                      (post['tags'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (post['tags'] as List).take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '#${tag['name'] ?? ''}',
                            style: context.labelS.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateReadingTime(String content) {
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    final words = plainText.trim().split(RegExp(r'\s+'));
    final minutes = (words.length / 200).ceil();
    return '$minutes min';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months${months == 1 ? ' month' : ' months'} ago';
      } else if (difference.inDays > 0) {
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

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }
}
