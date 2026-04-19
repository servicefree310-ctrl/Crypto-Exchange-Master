import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/news_entity.dart';

class NewsGatewayCard extends StatelessWidget {
  const NewsGatewayCard({
    super.key,
    this.trendingNews,
    this.onTap,
  });

  final List<NewsEntity>? trendingNews;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: context.borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.newspaper_outlined,
                            color: context.colors.primary,
                            size: context.isSmallScreen ? 18.0 : 20.0,
                          ),
                          SizedBox(width: context.isSmallScreen ? 6.0 : 8.0),
                          Text(
                            'Crypto News',
                            style: context.h6.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.isSmallScreen ? 4.0 : 6.0),
                      Text(
                        'Stay updated with the latest market insights',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                          fontSize: context.isSmallScreen ? 11.0 : 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(context.isSmallScreen ? 6.0 : 8.0),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: context.colors.primary,
                    size: context.isSmallScreen ? 14.0 : 16.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
            if (trendingNews != null && trendingNews!.isNotEmpty) ...[
              _buildTrendingNewsPreview(context),
              SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
            ] else ...[
              _buildPlaceholderContent(context),
              SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
            ],
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    return Column(
      children: [
        _buildPlaceholderItem(
            context, 'Latest crypto market updates and trends'),
        SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
        _buildPlaceholderItem(
            context, 'Breaking news from the blockchain world'),
      ],
    );
  }

  Widget _buildPlaceholderItem(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: EdgeInsets.all(context.isSmallScreen ? 10.0 : 12.0),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: context.bodyS.copyWith(
                    color: context.textPrimary,
                    fontSize: context.isSmallScreen ? 11.0 : 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.isSmallScreen ? 2.0 : 4.0),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: context.textTertiary,
                      size: context.isSmallScreen ? 10.0 : 12.0,
                    ),
                    SizedBox(width: context.isSmallScreen ? 2.0 : 4.0),
                    Text(
                      'Tap to explore',
                      style: context.bodyS.copyWith(
                        color: context.textTertiary,
                        fontSize: context.isSmallScreen ? 9.0 : 10.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: context.textTertiary,
            size: context.isSmallScreen ? 12.0 : 14.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingNewsPreview(BuildContext context) {
    final latestNews = trendingNews!.take(2).toList();

    return Column(
      children: latestNews
          .map((news) => _buildNewsPreviewItem(context, news))
          .toList(),
    );
  }

  Widget _buildNewsPreviewItem(BuildContext context, NewsEntity news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: EdgeInsets.all(context.isSmallScreen ? 10.0 : 12.0),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: context.bodyS.copyWith(
                    color: context.textPrimary,
                    fontSize: context.isSmallScreen ? 11.0 : 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.isSmallScreen ? 2.0 : 4.0),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: context.textTertiary,
                      size: context.isSmallScreen ? 10.0 : 12.0,
                    ),
                    SizedBox(width: context.isSmallScreen ? 2.0 : 4.0),
                    Text(
                      _getTimeAgo(news.publishedAt),
                      style: context.bodyS.copyWith(
                        color: context.textTertiary,
                        fontSize: context.isSmallScreen ? 9.0 : 10.0,
                      ),
                    ),
                    SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.isSmallScreen ? 4.0 : 6.0,
                        vertical: context.isSmallScreen ? 1.0 : 2.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getSentimentColor(news.sentiment).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getSentimentColor(news.sentiment)
                              .withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        news.sentiment.toUpperCase(),
                        style: context.bodyS.copyWith(
                          color: _getSentimentColor(news.sentiment),
                          fontSize: context.isSmallScreen ? 8.0 : 9.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: context.textTertiary,
            size: context.isSmallScreen ? 12.0 : 14.0,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Latest News',
            Icons.article_outlined,
            () => onTap?.call(),
          ),
        ),
        SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
        Expanded(
          child: _buildActionButton(
            context,
            'Trending',
            Icons.trending_up_outlined,
            () => onTap?.call(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.isSmallScreen ? 8.0 : 12.0,
          vertical: context.isSmallScreen ? 8.0 : 10.0,
        ),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: context.colors.primary,
              size: context.isSmallScreen ? 14.0 : 16.0,
            ),
            SizedBox(width: context.isSmallScreen ? 4.0 : 6.0),
            Text(
              label,
              style: context.bodyS.copyWith(
                color: context.colors.primary,
                fontSize: context.isSmallScreen ? 11.0 : 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
        return const Color(0xFF0ECE7A); // priceUpColor
      case 'negative':
        return const Color(0xFFFF5A5F); // priceDownColor
      default:
        return Colors.orange;
    }
  }
}
