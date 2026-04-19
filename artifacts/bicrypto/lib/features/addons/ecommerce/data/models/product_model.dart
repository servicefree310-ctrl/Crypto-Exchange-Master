import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String slug,
    required String description,
    required String shortDescription,
    required String type,
    required double price,
    required String currency,
    required String walletType,
    required int inventoryQuantity,
    required bool status,
    String? image,
    @Default([]) List<String> images,
    double? salePrice,
    @Default(false) bool isFeatured,
    String? categoryId,
    CategoryModel? category,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      shortDescription: entity.shortDescription,
      type: entity.type.name.toUpperCase(),
      price: entity.price,
      currency: entity.currency,
      walletType: entity.walletType.name.toUpperCase(),
      inventoryQuantity: entity.inventoryQuantity,
      status: entity.status,
      image: entity.image,
      images: entity.images,
      salePrice: entity.salePrice,
      isFeatured: entity.isFeatured,
      categoryId: entity.categoryId,
      category: entity.category != null
          ? CategoryModel.fromEntity(entity.category!)
          : null,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      slug: slug,
      description: description,
      shortDescription: shortDescription,
      type: _parseProductType(type),
      price: price,
      currency: currency,
      walletType: _parseWalletType(walletType),
      inventoryQuantity: inventoryQuantity,
      status: status,
      image: image,
      images: images,
      salePrice: salePrice,
      isFeatured: isFeatured,
      categoryId: categoryId,
      category: category?.toEntity(),
      rating: rating,
      reviewsCount: reviewsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ProductType _parseProductType(String type) {
    switch (type.toUpperCase()) {
      case 'DOWNLOADABLE':
        return ProductType.downloadable;
      case 'PHYSICAL':
        return ProductType.physical;
      default:
        return ProductType.physical;
    }
  }

  static WalletType _parseWalletType(String type) {
    switch (type.toUpperCase()) {
      case 'FIAT':
        return WalletType.fiat;
      case 'SPOT':
        return WalletType.spot;
      case 'ECO':
        return WalletType.eco;
      default:
        return WalletType.fiat;
    }
  }
}

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? image,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      image: entity.image,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      slug: slug,
      description: description,
      image: image,
    );
  }
}
