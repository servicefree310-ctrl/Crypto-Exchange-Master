import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/blog_post_entity.dart';
import '../../../../../core/utils/url_utils.dart';

class BlogAuthorCard extends StatelessWidget {
  final BlogAuthorEntity author;

  const BlogAuthorCard({
    super.key,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Author Avatar
          CachedNetworkImage(
            imageUrl: author.user?.avatar != null
                ? UrlUtils.normalise(author.user!.avatar)
                : '',
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 30,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => CircleAvatar(
              radius: 30,
              backgroundColor: theme.cardColor,
              child: const SizedBox.shrink(),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 30,
              backgroundColor: theme.primaryColor,
              child: Text(
                author.user?.firstName.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Name
                if (author.user != null)
                  Text(
                    author.user!.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                // Author Role
                if (author.user?.role != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    author.user!.role!.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // Author Bio
                if (author.bio != null && author.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    author.bio!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Post Count
                if (author.postCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 16,
                        color: theme.iconTheme.color?.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${author.postCount} ${author.postCount == 1 ? 'post' : 'posts'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Sized box to align without follow button
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
