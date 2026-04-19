import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/news_entity.dart';

class NewsItem extends StatefulWidget {
  const NewsItem({
    super.key,
    required this.news,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final NewsEntity news;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  @override
  State<NewsItem> createState() => _NewsItemState();
}

class _NewsItemState extends State<NewsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.amber,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(NewsItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when bookmark status changes
    if (widget.isBookmarked != oldWidget.isBookmarked) {
      if (widget.isBookmarked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleBookmarkToggle() {
    // Haptic feedback with error handling
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not supported on this device
    }

    // Call the actual toggle function first
    widget.onBookmarkToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: context.borderColor,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.news.imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.news.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: context.dividerColor,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.textSecondary,
                            size: 24.0,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              Padding(
                padding: EdgeInsets.all(context.isSmallScreen ? 10.0 : 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.news.title,
                            style: context.h6.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildAnimatedBookmarkButton(context),
                      ],
                    ),
                    SizedBox(height: context.isSmallScreen ? 4.0 : 6.0),
                    Text(
                      widget.news.summary,
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                        fontSize: 12.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          widget.news.source,
                          Icons.source,
                        ),
                        SizedBox(width: context.isSmallScreen ? 4.0 : 6.0),
                        _buildInfoChip(
                          context,
                          '${widget.news.readTime} min read',
                          Icons.access_time,
                        ),
                        SizedBox(width: context.isSmallScreen ? 4.0 : 6.0),
                        _buildSentimentChip(context, widget.news.sentiment),
                        const Spacer(),
                        Text(
                          _getTimeAgo(widget.news.publishedAt),
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                            fontSize: context.isSmallScreen ? 10.0 : 11.0,
                          ),
                        ),
                      ],
                    ),
                    if (widget.news.categories.isNotEmpty) ...[
                      SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
                      Wrap(
                        spacing: context.isSmallScreen ? 3.0 : 4.0,
                        runSpacing: context.isSmallScreen ? 3.0 : 4.0,
                        children: widget.news.categories
                            .take(3)
                            .map((category) =>
                                _buildCategoryChip(context, category))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBookmarkButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleBookmarkToggle,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: widget.isBookmarked
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Icon(
                widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: widget.isBookmarked
                    ? context.colors.primary
                    : context.textSecondary,
                size: 18.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 4.0 : 6.0,
        vertical: context.isSmallScreen ? 1.0 : 2.0,
      ),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: context.textSecondary,
            size: context.isSmallScreen ? 8.0 : 10.0,
          ),
          SizedBox(width: context.isSmallScreen ? 1.0 : 2.0),
          Text(
            label,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
              fontSize: context.isSmallScreen ? 8.0 : 9.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentChip(BuildContext context, String sentiment) {
    final color = _getSentimentColor(sentiment);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 4.0 : 6.0,
        vertical: context.isSmallScreen ? 1.0 : 2.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        sentiment.toUpperCase(),
        style: context.bodyS.copyWith(
          color: color,
          fontSize: context.isSmallScreen ? 8.0 : 9.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 4.0 : 6.0,
        vertical: context.isSmallScreen ? 1.0 : 2.0,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        category,
        style: context.bodyS.copyWith(
          color: context.colors.primary,
          fontSize: context.isSmallScreen ? 8.0 : 9.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
