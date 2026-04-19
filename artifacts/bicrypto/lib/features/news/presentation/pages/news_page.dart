import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../widgets/news_list.dart';
import '../widgets/news_search_bar.dart';
import '../widgets/news_category_tabs.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NewsBloc>()
        ..add(const NewsLoadRequested()) // Only load initial data
        ..add(const NewsCategoriesLoadRequested()), // Load categories once
      child: const _NewsPageView(),
    );
  }
}

class _NewsPageView extends StatefulWidget {
  const _NewsPageView();

  @override
  State<_NewsPageView> createState() => _NewsPageViewState();
}

class _NewsPageViewState extends State<_NewsPageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
        // Use the new tab change event instead of direct API calls
        context
            .read<NewsBloc>()
            .add(NewsTabChanged(tabIndex: _tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          'Crypto News',
          style: context.h6.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                indicatorPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                labelColor: context.colors.primary,
                unselectedLabelColor: context.textSecondary,
                labelStyle: context.bodyM
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: context.bodyM
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Latest'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Categories'),
                  Tab(text: 'Bookmarks'),
                ],
                isScrollable: false,
              ),
              Divider(
                height: 1,
                thickness: 0.7,
                color: context.borderColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar for all tabs
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.isSmallScreen ? 10.0 : 14.0,
              vertical: context.isSmallScreen ? 6.0 : 8.0,
            ),
            child: NewsSearchBar(
              onSearch: (query) {
                if (query.isEmpty) {
                  // Clear search and load current tab using the new event
                  context
                      .read<NewsBloc>()
                      .add(NewsTabChanged(tabIndex: _currentIndex));
                } else {
                  // Perform search
                  context
                      .read<NewsBloc>()
                      .add(NewsSearchRequested(query: query));
                }
              },
            ),
          ),
          if (_currentIndex == 2) ...[
            // Category tabs only for categories tab
            NewsCategoryTabs(
              onCategoryChanged: (category) {
                context
                    .read<NewsBloc>()
                    .add(NewsCategoryChanged(category: category));
              },
            ),
          ],
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (context, state) {
                if (state is NewsLoading) {
                  return _buildLoadingWidget(context);
                } else if (state is NewsLoaded) {
                  return NewsList(
                    news: state.news,
                    bookmarkedIds: state.bookmarkedIds,
                    onRefresh: () {
                      context
                          .read<NewsBloc>()
                          .add(const NewsRefreshRequested());
                    },
                    onLoadMore: () {
                      context
                          .read<NewsBloc>()
                          .add(const NewsLoadMoreRequested());
                    },
                    hasReachedMax: state.hasReachedMax,
                  );
                } else if (state is NewsTrendingLoaded) {
                  return NewsList(
                    news: state.news,
                    bookmarkedIds: state.bookmarkedIds,
                    onRefresh: () {
                      context
                          .read<NewsBloc>()
                          .add(const NewsLoadTrendingRequested());
                    },
                    onLoadMore: () {
                      // Trending doesn't support load more
                    },
                    hasReachedMax: true,
                  );
                } else if (state is NewsSearchLoaded) {
                  return NewsList(
                    news: state.news,
                    bookmarkedIds: state.bookmarkedIds,
                    onRefresh: () {
                      // Refresh current search
                      context
                          .read<NewsBloc>()
                          .add(NewsSearchRequested(query: state.query));
                    },
                    onLoadMore: () {
                      // Load more search results
                      context.read<NewsBloc>().add(NewsLoadMoreRequested());
                    },
                    hasReachedMax: state.hasReachedMax,
                  );
                } else if (state is NewsBookmarkedLoaded) {
                  return NewsList(
                    news: state.news,
                    bookmarkedIds: state.bookmarkedIds,
                    onRefresh: () {
                      context
                          .read<NewsBloc>()
                          .add(const NewsLoadBookmarkedRequested());
                    },
                    onLoadMore: () {
                      // Bookmarks don't support load more
                    },
                    hasReachedMax: true,
                  );
                } else if (state is NewsError) {
                  return _buildErrorWidget(context, state.message);
                } else if (state is NewsEmpty) {
                  return _buildEmptyWidget(context, state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: context.colors.primary,
          ),
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          Text(
            'Loading news...',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.isSmallScreen ? 20.0 : 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: context.priceDownColor,
                  size: 64.0,
                ),
                SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
                Text(
                  'Error Loading News',
                  style: context.h6.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
                Text(
                  message,
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Use the new tab change event for retry
                    context
                        .read<NewsBloc>()
                        .add(NewsTabChanged(tabIndex: _currentIndex));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isSmallScreen ? 16.0 : 20.0,
                      vertical: context.isSmallScreen ? 8.0 : 12.0,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, String message) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.isSmallScreen ? 20.0 : 24.0),
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
                  message,
                  style: context.h6.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
