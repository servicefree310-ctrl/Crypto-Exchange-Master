import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../bloc/products/products_bloc.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryEntity> categories;

  const CategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryItem(category: category);
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CategoryEntity category;

  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ProductsBloc>().add(
              FilterProductsByCategory(categoryId: category.id),
            );
        Navigator.pushNamed(
          context,
          '/ecommerce/category/${category.slug}',
          arguments: category,
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(35),
              ),
              child: category.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.network(
                        category.image!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.category,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
