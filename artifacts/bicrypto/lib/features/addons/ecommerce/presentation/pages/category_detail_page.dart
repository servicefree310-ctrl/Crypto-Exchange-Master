import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/widgets/app_error_widget.dart';
import '../../../../../../core/widgets/app_loading_indicator.dart';
import '../bloc/category_products/category_products_bloc.dart';
import '../bloc/category_products/category_products_event.dart';
import '../bloc/category_products/category_products_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/wishlist/wishlist_bloc.dart';
import '../widgets/product_card.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categorySlug;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categorySlug,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<CategoryProductsBloc>()
            ..add(LoadCategoryProductsRequested(categorySlug: categorySlug)),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<CartBloc>(),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<WishlistBloc>(),
        ),
      ],
      child: _CategoryDetailView(
        categoryName: categoryName,
      ),
    );
  }
}

class _CategoryDetailView extends StatelessWidget {
  final String categoryName;

  const _CategoryDetailView({
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: context.colors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: context.colors.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 56,
                right: 16,
                bottom: 16,
              ),
              title: Text(
                categoryName,
                style: context.labelL.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.primary.withValues(alpha: 0.1),
                      context.colors.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
            builder: (context, state) {
              if (state is CategoryProductsLoading) {
                return const SliverFillRemaining(
                  child: Center(child: AppLoadingIndicator()),
                );
              }

              if (state is CategoryProductsError) {
                return SliverFillRemaining(
                  child: Center(
                    child: AppErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<CategoryProductsBloc>().add(
                              LoadCategoryProductsRequested(
                                categorySlug: context
                                    .read<CategoryProductsBloc>()
                                    .categorySlug,
                              ),
                            );
                      },
                    ),
                  ),
                );
              }

              if (state is CategoryProductsLoaded) {
                if (state.products.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: _EmptyState(categoryName: categoryName),
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
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                        );
                      },
                      childCount: state.products.length,
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

class _EmptyState extends StatelessWidget {
  final String categoryName;

  const _EmptyState({required this.categoryName});

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
              Icons.inventory_2_outlined,
              size: 40,
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No products in $categoryName',
            style: context.labelL.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This category doesn\'t have any products yet',
            style: context.bodyM.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Go back',
              style: context.labelM.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
