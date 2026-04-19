import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../../core/constants/api_constants.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/widgets/app_error_widget.dart';
import '../../../../../../core/widgets/app_loading_indicator.dart';
import '../bloc/categories/categories_bloc.dart';
import '../bloc/categories/categories_event.dart';
import '../bloc/categories/categories_state.dart';
import '../../domain/entities/product_entity.dart';
import 'category_detail_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CategoriesBloc>()
        ..add(const LoadCategoriesRequested()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Categories',
          style: context.h5,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.1),
                    context.colors.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Explore Our Collections',
                        style: context.labelS.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Shop by',
                      style: context.h2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Category',
                      style: context.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Discover our curated easy-to-browse categories',
                      style: context.bodyM.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              searchController: _searchController,
              onSearch: (query) {
                context.read<CategoriesBloc>().add(
                      SearchCategoriesRequested(query: query),
                    );
              },
            ),
          ),

          // Categories Content
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const SliverFillRemaining(
                  child: Center(child: AppLoadingIndicator()),
                );
              }

              if (state is CategoriesError) {
                return SliverFillRemaining(
                  child: Center(
                    child: AppErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<CategoriesBloc>().add(
                              const LoadCategoriesRequested(),
                            );
                      },
                    ),
                  ),
                );
              }

              if (state is CategoriesLoaded) {
                final categories = state.filteredCategories.isEmpty &&
                        state.searchQuery.isNotEmpty
                    ? <CategoryEntity>[]
                    : (state.filteredCategories.isEmpty
                        ? state.categories
                        : state.filteredCategories);

                if (categories.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: _EmptyState(
                        searchQuery: state.searchQuery,
                        onClearSearch: () {
                          _searchController.clear();
                          context.read<CategoriesBloc>().add(
                                const SearchCategoriesRequested(query: ''),
                              );
                        },
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return _CategoryCard(category: category);
                      },
                      childCount: categories.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(
                child: SizedBox(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  _SearchBarDelegate({
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearch,
          style: context.bodyM,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: context.bodyM.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      searchController.clear();
                      onSearch('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryCard({required this.category});

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    // Check if the URL is already absolute
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If it's a relative URL, prepend the base URL
    if (imageUrl.startsWith('/')) {
      return '${ApiConstants.baseUrl}$imageUrl';
    }

    // Otherwise, assume it needs a leading slash
    return '${ApiConstants.baseUrl}/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(
              categorySlug: category.slug,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Category Image
              CachedNetworkImage(
                imageUrl: _getImageUrl(category.image),
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: context.colors.surfaceContainerHighest,
                  child: const Center(
                    child: AppLoadingIndicator(size: 24),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: context.colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: context.colors.onSurface.withValues(alpha: 0.5),
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
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: context.labelL.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description!,
                        style: context.bodyS.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Browse',
                          style: context.labelS.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: context.colors.primary,
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
}

class _EmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const _EmptyState({
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 40,
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No categories found',
            style: context.labelL.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'We couldn\'t find any categories matching "$searchQuery"'
                : 'No categories available at the moment',
            style: context.bodyM.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onClearSearch,
              child: Text(
                'Clear search',
                style: context.labelM.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
