// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String,
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      walletType: json['walletType'] as String,
      inventoryQuantity: (json['inventoryQuantity'] as num).toInt(),
      status: json['status'] as bool,
      image: json['image'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      isFeatured: json['isFeatured'] as bool? ?? false,
      categoryId: json['categoryId'] as String?,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'shortDescription': instance.shortDescription,
      'type': instance.type,
      'price': instance.price,
      'currency': instance.currency,
      'walletType': instance.walletType,
      'inventoryQuantity': instance.inventoryQuantity,
      'status': instance.status,
      'image': instance.image,
      'images': instance.images,
      'salePrice': instance.salePrice,
      'isFeatured': instance.isFeatured,
      'categoryId': instance.categoryId,
      'category': instance.category,
      'rating': instance.rating,
      'reviewsCount': instance.reviewsCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'image': instance.image,
    };
