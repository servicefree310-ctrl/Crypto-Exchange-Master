import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class WishlistEntity extends Equatable {
  final String id;
  final String userId;
  final List<ProductEntity> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WishlistEntity({
    required this.id,
    required this.userId,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, products, createdAt, updatedAt];

  WishlistEntity copyWith({
    String? id,
    String? userId,
    List<ProductEntity>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
