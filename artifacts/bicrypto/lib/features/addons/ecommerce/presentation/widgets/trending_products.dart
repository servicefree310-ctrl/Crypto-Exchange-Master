import 'package:flutter/material.dart';

import '../../domain/entities/product_entity.dart';
import 'product_card.dart';

class TrendingProducts extends StatelessWidget {
  final List<ProductEntity> products;

  const TrendingProducts({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // Sort by rating and take top 4
    final trendingProducts = List<ProductEntity>.from(products)
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

    // Take only the first 4 products or fewer if not enough
    final displayProducts = trendingProducts.take(4).toList();

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 150,
              child: ProductCard(
                product: product,
                aspectRatio: 0.85,
                showCategory: false,
                showRating: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
