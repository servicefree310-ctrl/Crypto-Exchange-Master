import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/blog_post_entity.dart';
import '../../../../../core/utils/url_utils.dart';

class BlogCommentCard extends StatelessWidget {
  final BlogCommentEntity comment;

  const BlogCommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.primaryColor,
                backgroundImage: comment.user?.avatar != null
                    ? CachedNetworkImageProvider(
                        UrlUtils.normalise(comment.user!.avatar!))
                    : null,
                child: comment.user?.avatar == null
                    ? Text(
                        comment.user?.firstName.substring(0, 1).toUpperCase() ??
                            'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Name
                    if (comment.user != null)
                      Text(
                        comment.user!.fullName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    // Comment Date
                    if (comment.createdAt != null)
                      Text(
                        dateFormat.format(comment.createdAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment Content
          Text(
            comment.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // No like/report buttons
        ],
      ),
    );
  }
}
