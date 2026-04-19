import 'package:equatable/equatable.dart';

import '../../../../../core/constants/api_constants.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.shortDescription,
    required this.type,
    required this.price,
    required this.currency,
    required this.walletType,
    required this.inventoryQuantity,
    required this.status,
    this.image,
    this.images = const [],
    this.salePrice,
    this.isFeatured = false,
    this.categoryId,
    this.category,
    this.rating,
    this.reviewsCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final ProductType type;
  final double price;
  final String currency;
  final WalletType walletType;
  final int inventoryQuantity;
  final bool status;
  final String? image;
  final List<String> images;
  final double? salePrice;
  final bool isFeatured;
  final String? categoryId;
  final CategoryEntity? category;
  final double? rating;
  final int? reviewsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isInStock => inventoryQuantity > 0;
  bool get isLowStock => inventoryQuantity > 0 && inventoryQuantity <= 10;
  bool get isDigital => type == ProductType.downloadable;
  bool get isOnSale => salePrice != null && salePrice! < price;
  double get effectivePrice => isOnSale ? salePrice! : price;

  String get typeDisplayText {
    switch (type) {
      case ProductType.downloadable:
        return 'Downloadable';
      case ProductType.physical:
        return 'Physical';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        shortDescription,
        type,
        price,
        currency,
        walletType,
        inventoryQuantity,
        status,
        image,
        images,
        salePrice,
        isFeatured,
        categoryId,
        category,
        rating,
        reviewsCount,
        createdAt,
        updatedAt,
      ];

  ProductEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? shortDescription,
    ProductType? type,
    double? price,
    String? currency,
    WalletType? walletType,
    int? inventoryQuantity,
    bool? status,
    String? image,
    List<String>? images,
    double? salePrice,
    bool? isFeatured,
    String? categoryId,
    CategoryEntity? category,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      type: type ?? this.type,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      walletType: walletType ?? this.walletType,
      inventoryQuantity: inventoryQuantity ?? this.inventoryQuantity,
      status: status ?? this.status,
      image: image ?? this.image,
      images: images ?? this.images,
      salePrice: salePrice ?? this.salePrice,
      isFeatured: isFeatured ?? this.isFeatured,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;

  @override
  List<Object?> get props => [id, name, slug, description, image];
}
