import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/shipping_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/ecommerce_repository.dart';
import '../datasources/ecommerce_local_datasource.dart';
import '../datasources/ecommerce_remote_datasource.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

@Injectable(as: EcommerceRepository)
class EcommerceRepositoryImpl implements EcommerceRepository {
  const EcommerceRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  final EcommerceRemoteDataSource remoteDataSource;
  final EcommerceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? categoryId,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await remoteDataSource.getProducts(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        categoryId: categoryId,
      );

      final products = models.map((model) => model.toEntity()).toList();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductBySlug(String slug) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await remoteDataSource.getProductBySlug(slug);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    // For now, just return first 8 products as featured
    final result = await getProducts();
    return result.fold(
      (failure) => Left(failure),
      (products) => Right(products.take(8).toList()),
    );
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts(
    String productId,
  ) async {
    // For now, just return some products
    final result = await getProducts();
    return result.fold(
      (failure) => Left(failure),
      (products) => Right(products.take(4).toList()),
    );
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await remoteDataSource.getCategories();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryBySlug(String slug) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await remoteDataSource.getCategoryBySlug(slug);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categorySlug, {
    int? page,
    int? limit,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await remoteDataSource.getProductsByCategory(categorySlug);
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query,
  ) async {
    // Use the getProducts method with search parameter
    return getProducts(search: query);
  }

  // Cart operations - using local data source only for now
  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cart = await localDataSource.getCart();
      return Right(cart);
    } on CacheException {
      // Return empty cart if none exists
      return Right(CartModel.empty());
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(
      ProductEntity product, int quantity) async {
    try {
      CartEntity currentCart;
      try {
        currentCart = await localDataSource.getCart();
      } catch (_) {
        currentCart = CartModel.empty();
      }

      // Check if product already exists in cart
      final existingIndex = currentCart.items.indexWhere(
        (item) => item.product.id == product.id,
      );

      List<CartItemEntity> updatedItems;
      if (existingIndex != -1) {
        // Update quantity
        updatedItems = List.from(currentCart.items);
        final existingItem = updatedItems[existingIndex];
        updatedItems[existingIndex] = CartItemEntity(
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          total:
              existingItem.product.price * (existingItem.quantity + quantity),
        );
      } else {
        // Add new item
        final newItem = CartItemEntity(
          product: product,
          quantity: quantity,
          total: product.price * quantity,
        );
        updatedItems = [...currentCart.items, newItem];
      }

      // Calculate new total
      final newTotal = updatedItems.fold(
        0.0,
        (sum, item) => sum + item.total,
      );

      final updatedCart = CartEntity(
        items: updatedItems,
        total: newTotal,
        currency: product.currency,
      );

      // Save cart - need to convert entities back to models
      final cartModel = CartModel(
        items: updatedItems
            .map((item) => CartItemModel(
                  product: item.product,
                  quantity: item.quantity,
                  total: item.total,
                ))
            .toList(),
        total: newTotal,
        currency: product.currency,
      );

      await localDataSource.saveCart(cartModel);
      return Right(updatedCart);
    } on CacheException {
      return const Left(CacheFailure('Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateCartItemQuantity(
      String productId, int quantity) async {
    try {
      final currentCart = await localDataSource.getCart();

      final updatedItems = currentCart.items.map((item) {
        if (item.product.id == productId) {
          return CartItemEntity(
            product: item.product,
            quantity: quantity,
            total: item.product.price * quantity,
          );
        }
        return item;
      }).toList();

      final newTotal = updatedItems.fold(
        0.0,
        (sum, item) => sum + item.total,
      );

      final updatedCart = CartEntity(
        items: updatedItems,
        total: newTotal,
        currency: currentCart.currency,
      );

      // Save cart
      final cartModel = CartModel(
        items: updatedItems
            .map((item) => CartItemModel(
                  product: item.product,
                  quantity: item.quantity,
                  total: item.total,
                ))
            .toList(),
        total: newTotal,
        currency: currentCart.currency,
      );

      await localDataSource.saveCart(cartModel);
      return Right(updatedCart);
    } on CacheException {
      return const Left(CacheFailure('Failed to update cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(String productId) async {
    try {
      final currentCart = await localDataSource.getCart();

      final updatedItems = currentCart.items
          .where((item) => item.product.id != productId)
          .toList();

      final newTotal = updatedItems.fold(
        0.0,
        (sum, item) => sum + item.total,
      );

      final updatedCart = CartEntity(
        items: updatedItems,
        total: newTotal,
        currency: currentCart.currency,
      );

      // Save cart
      final cartModel = CartModel(
        items: updatedItems
            .map((item) => CartItemModel(
                  product: item.product,
                  quantity: item.quantity,
                  total: item.total,
                ))
            .toList(),
        total: newTotal,
        currency: currentCart.currency,
      );

      await localDataSource.saveCart(cartModel);
      return Right(updatedCart);
    } on CacheException {
      return const Left(CacheFailure('Failed to remove item from cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return Right(CartModel.empty());
    } on CacheException {
      return const Left(CacheFailure('Failed to clear cart'));
    }
  }

  // Wishlist operations
  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlist() async {
    try {
      // First try to get from local storage
      final localWishlist = await localDataSource.getWishlist();

      // If we have network, try to sync with server
      if (await networkInfo.isConnected) {
        try {
          // userId param is unused by the API (backend uses JWT auth)
          const userId = '';
          final remoteProducts = await remoteDataSource.getWishlist(userId);

          // Save to local storage
          await localDataSource.saveWishlist(remoteProducts);

          return Right(
              remoteProducts.map((model) => model.toEntity()).toList());
        } catch (_) {
          // If remote fails, use local
          return Right(localWishlist.map((model) => model.toEntity()).toList());
        }
      }

      // No network, use local
      return Right(localWishlist.map((model) => model.toEntity()).toList());
    } on CacheException {
      // No local data either
      return const Right([]);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> addToWishlist(
      ProductEntity product) async {
    try {
      // Get current wishlist from local storage
      List<ProductModel> currentWishlist;
      try {
        currentWishlist = await localDataSource.getWishlist();
      } catch (_) {
        currentWishlist = [];
      }

      // Check if already in wishlist
      if (currentWishlist.any((p) => p.id == product.id)) {
        return Right(currentWishlist.map((model) => model.toEntity()).toList());
      }

      // Add to wishlist
      final productModel = ProductModel(
        id: product.id,
        name: product.name,
        slug: product.slug,
        description: product.description,
        shortDescription: product.shortDescription,
        price: product.price,
        currency: product.currency,
        image: product.image,
        category: product.category != null
            ? CategoryModel(
                id: product.category!.id,
                name: product.category!.name,
                slug: product.category!.slug,
                image: product.category!.image,
                description: product.category!.description,
              )
            : null,
        type: product.type.name.toUpperCase(),
        walletType: product.walletType.name.toUpperCase(),
        inventoryQuantity: product.inventoryQuantity,
        rating: product.rating,
        reviewsCount: product.reviewsCount,
        status: product.status,
        categoryId: product.categoryId,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );

      final updatedWishlist = [...currentWishlist, productModel];
      await localDataSource.saveWishlist(updatedWishlist);

      // Try to sync with server in background
      if (await networkInfo.isConnected) {
        try {
          const userId = '';
          await remoteDataSource.addToWishlist(userId, product.id);
        } catch (_) {
          // Ignore remote errors, local is source of truth
        }
      }

      return Right(updatedWishlist.map((model) => model.toEntity()).toList());
    } on CacheException {
      return const Left(CacheFailure('Failed to add to wishlist'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> removeFromWishlist(
      String productId) async {
    try {
      // Get current wishlist from local storage
      List<ProductModel> currentWishlist;
      try {
        currentWishlist = await localDataSource.getWishlist();
      } catch (_) {
        currentWishlist = [];
      }

      // Remove from wishlist
      final updatedWishlist =
          currentWishlist.where((product) => product.id != productId).toList();

      await localDataSource.saveWishlist(updatedWishlist);

      // Try to sync with server in background
      if (await networkInfo.isConnected) {
        try {
          const userId = '';
          await remoteDataSource.removeFromWishlist(userId, productId);
        } catch (_) {
          // Ignore remote errors, local is source of truth
        }
      }

      return Right(updatedWishlist.map((model) => model.toEntity()).toList());
    } on CacheException {
      return const Left(CacheFailure('Failed to remove from wishlist'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String productId) async {
    try {
      final wishlist = await localDataSource.getWishlist();
      return Right(wishlist.any((p) => p.id == productId));
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> clearWishlist() async {
    try {
      await localDataSource.clearWishlist();
      return const Right([]);
    } on CacheException {
      return const Left(CacheFailure('Failed to clear wishlist'));
    }
  }

  // Order operations
  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      dev.log('🚀 Repository: Starting getOrders request');

      if (!await networkInfo.isConnected) {
        dev.log('❌ Repository: No internet connection');
        return const Left(NetworkFailure('No internet connection'));
      }

      // userId param is unused by the API (backend uses JWT auth)
      const userId = '';
      dev.log('🔍 Repository: Calling remote data source with userId: $userId');

      final models = await remoteDataSource.getOrders(userId);
      dev.log('✅ Repository: Got ${models.length} order models from remote');

      final entities = models.map((model) => model.toEntity()).toList();
      dev.log('✅ Repository: Converted to ${entities.length} order entities');

      return Right(entities);
    } on ServerException catch (e) {
      dev.log('❌ Repository: ServerException - ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e, stackTrace) {
      dev.log('❌ Repository: Unknown error - $e');
      dev.log('📍 Stack trace: $stackTrace');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await remoteDataSource.getOrder(orderId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
    required String currency,
    String? shippingAddressId,
    String? shippingMethodId,
    String? paymentMethod,
    Map<String, String>? shippingAddress,
    String? discountId,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Backend expects one order per product (like the web frontend).
      // Process each cart item as a separate order sequentially.
      OrderModel? lastOrder;

      for (final item in items) {
        final orderData = <String, dynamic>{
          'productId': item.product.id,
          'amount': item.quantity,
        };

        // Only attach discount if provided
        if (discountId != null) {
          orderData['discountId'] = discountId;
        }

        // Only attach shipping address for physical products
        if (item.product.type == ProductType.physical &&
            shippingAddress != null) {
          orderData['shippingAddress'] = shippingAddress;
        }

        lastOrder = await remoteDataSource.createOrder(orderData);
      }

      if (lastOrder == null) {
        return const Left(ServerFailure('No items to order'));
      }

      return Right(lastOrder.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to place order'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Shipping operations
  @override
  Future<Either<Failure, List<ShippingMethodEntity>>>
      getShippingMethods() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final models = await remoteDataSource.getShippingMethods();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> getShippingAddresses() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AddressEntity>> addShippingAddress(
      AddressEntity address) async {
    return Right(address);
  }

  @override
  Future<Either<Failure, AddressEntity>> updateShippingAddress(
      AddressEntity address) async {
    return Right(address);
  }

  @override
  Future<Either<Failure, bool>> deleteShippingAddress(String addressId) async {
    return const Right(true);
  }

  // Reviews
  @override
  Future<Either<Failure, ReviewEntity>> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final model = await remoteDataSource.addReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> trackOrder(String orderId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final data = await remoteDataSource.trackOrder(orderId);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadDigitalProduct(
      String orderItemId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final url = await remoteDataSource.downloadDigitalProduct(orderItemId);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
