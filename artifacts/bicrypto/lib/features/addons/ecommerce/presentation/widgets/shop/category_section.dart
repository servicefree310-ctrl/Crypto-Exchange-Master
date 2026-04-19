import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/shop/shop_bloc.dart';
import '../../pages/categories_page.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.categories,
  });

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Categories',
            style: context.h6,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1, // +1 for "View All" button
            itemBuilder: (context, index) {
              if (index == categories.length) {
                // "View All" button
                return _ViewAllCategoriesCard();
              }

              final category = categories[index];
              return _CategoryCard(
                category: category,
                isFirst: index == 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isFirst,
  });

  final CategoryEntity category;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ShopBloc>().add(
              ShopCategorySelected(categoryId: category.id),
            );
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(
          left: isFirst ? 0 : 8,
          right: 8,
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _getCategoryIcon(context, category.name),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: context.labelS,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(BuildContext context, String categoryName) {
    // Map category names to icons
    IconData icon;
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        icon = Icons.devices;
        break;
      case 'fashion':
      case 'clothing':
        icon = Icons.checkroom;
        break;
      case 'food':
      case 'grocery':
        icon = Icons.local_grocery_store;
        break;
      case 'books':
        icon = Icons.menu_book;
        break;
      case 'sports':
        icon = Icons.sports_basketball;
        break;
      case 'home':
        icon = Icons.home;
        break;
      case 'beauty':
        icon = Icons.face;
        break;
      case 'toys':
        icon = Icons.toys;
        break;
      case 'health':
        icon = Icons.health_and_safety;
        break;
      default:
        icon = Icons.category;
    }

    return Icon(
      icon,
      color: Theme.of(context).primaryColor,
      size: 28,
    );
  }
}

class _ViewAllCategoriesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CategoriesPage(),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.grid_view,
                color: context.colors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View All',
              style: context.labelS.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
