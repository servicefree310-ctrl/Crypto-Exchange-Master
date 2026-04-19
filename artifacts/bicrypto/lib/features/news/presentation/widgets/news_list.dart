import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/news_entity.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import 'news_item.dart';

class NewsList extends StatelessWidget {
  const NewsList({
    super.key,
    required this.news,
    required this.bookmarkedIds,
    required this.onRefresh,
    required this.onLoadMore,
    required this.hasReachedMax,
  });

  final List<NewsEntity> news;
  final List<String> bookmarkedIds;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool hasReachedMax;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: context.colors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
        itemCount: news.length + (hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == news.length) {
            return _buildLoadMoreButton(context);
          }

          final newsItem = news[index];
          final isBookmarked = bookmarkedIds.contains(newsItem.id);

          return Padding(
            padding:
                EdgeInsets.only(bottom: context.isSmallScreen ? 8.0 : 12.0),
            child: NewsItem(
              news: newsItem,
              isBookmarked: isBookmarked,
              onTap: () => _openNewsUrl(newsItem.url),
              onBookmarkToggle: () =>
                  _toggleBookmark(context, newsItem.id, isBookmarked),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper_outlined,
            color: context.textSecondary,
            size: 64.0,
          ),
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          Text(
            'No news available',
            style: context.h6.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
          Text(
            'Pull to refresh to load latest news',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onLoadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: context.isSmallScreen ? 16.0 : 20.0,
              vertical: context.isSmallScreen ? 8.0 : 12.0,
            ),
          ),
          child: const Text('Load More'),
        ),
      ),
    );
  }

  Future<void> _openNewsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error
    }
  }

  void _toggleBookmark(BuildContext context, String newsId, bool isBookmarked) {
    if (isBookmarked) {
      context.read<NewsBloc>().add(NewsRemoveBookmarkRequested(newsId: newsId));
    } else {
      context.read<NewsBloc>().add(NewsBookmarkRequested(newsId: newsId));
    }
  }
}
