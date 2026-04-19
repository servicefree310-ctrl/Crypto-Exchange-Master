import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/cart_entity.dart';
import '../entities/order_entity.dart';
import '../entities/product_entity.dart';
import '../entities/shipping_entity.dart';
import '../entities/review_entity.dart';

abstract class EcommerceRepository {
  // Product operations
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? categoryId,
  });

  Future<Either<Failure, ProductEntity>> getProductBySlug(String slug);

  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts();

  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts(
    String productId,
  );

  // Category operations
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> getCategoryBySlug(String slug);

  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categorySlug, {
    int? page,
    int? limit,
  });

  // Search
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);

  // Cart
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addToCart(
      ProductEntity product, int quantity);
  Future<Either<Failure, CartEntity>> updateCartItemQuantity(
      String productId, int quantity);
  Future<Either<Failure, CartEntity>> removeFromCart(String productId);
  Future<Either<Failure, CartEntity>> clearCart();

  // Wishlist
  Future<Either<Failure, List<ProductEntity>>> getWishlist();
  Future<Either<Failure, List<ProductEntity>>> addToWishlist(
      ProductEntity product);
  Future<Either<Failure, List<ProductEntity>>> removeFromWishlist(
      String productId);
  Future<Either<Failure, bool>> isInWishlist(String productId);
  Future<Either<Failure, List<ProductEntity>>> clearWishlist();

  // Orders
  Future<Either<Failure, List<OrderEntity>>> getOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
    required String currency,
    String? shippingAddressId,
    String? shippingMethodId,
    String? paymentMethod,
    Map<String, String>? shippingAddress,
    String? discountId,
  });

  // Shipping
  Future<Either<Failure, List<ShippingMethodEntity>>> getShippingMethods();
  Future<Either<Failure, List<AddressEntity>>> getShippingAddresses();
  Future<Either<Failure, AddressEntity>> addShippingAddress(
      AddressEntity address);
  Future<Either<Failure, AddressEntity>> updateShippingAddress(
      AddressEntity address);
  Future<Either<Failure, bool>> deleteShippingAddress(String addressId);

  // Reviews
  Future<Either<Failure, ReviewEntity>> addReview({
    required String productId,
    required int rating,
    required String comment,
  });

  // Order tracking & digital download
  Future<Either<Failure, dynamic>> trackOrder(String orderId);
  Future<Either<Failure, String>> downloadDigitalProduct(String orderItemId);
}
