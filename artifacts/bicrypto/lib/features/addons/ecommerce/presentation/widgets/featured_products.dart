import 'package:flutter/material.dart';

import '../../domain/entities/product_entity.dart';
import 'product_card.dart';

class FeaturedProducts extends StatelessWidget {
  final List<ProductEntity> products;

  const FeaturedProducts({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // Take only the first 4 products or fewer if not enough
    final featuredProducts = products.take(4).toList();

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featuredProducts.length,
        itemBuilder: (context, index) {
          final product = featuredProducts[index];
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
