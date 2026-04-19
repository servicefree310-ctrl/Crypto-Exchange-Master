import 'dart:developer' as dev;


import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';

import '../../../../../core/errors/exceptions.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/shipping_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../../core/constants/api_constants.dart' hide OrderStatus;
import '../../../../../core/network/dio_client.dart';

abstract class EcommerceRemoteDataSource {
  // Products
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? categoryId,
  });
  Future<ProductModel> getProductBySlug(String slug);
  Future<List<ProductModel>> getProductsByCategory(String categorySlug);

  // Categories
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryBySlug(String slug);

  // Cart
  Future<CartModel> getCart(String userId);
  Future<CartModel> addToCart(String userId, String productId, int quantity);
  Future<CartModel> updateCartItemQuantity(
      String userId, String productId, int quantity);
  Future<CartModel> removeFromCart(String userId, String productId);
  Future<void> clearCart(String userId);

  // Orders
  Future<OrderModel> getOrder(String orderId);
  Future<List<OrderModel>> getOrders(String userId);
  Future<OrderModel> createOrder(Map<String, dynamic> orderData);

  // Wishlist
  Future<List<ProductModel>> getWishlist(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);

  // Reviews
  Future<ReviewModel> addReview({
    required String productId,
    required int rating,
    required String comment,
  });

  Future<dynamic> trackOrder(String orderId);
  Future<String> downloadDigitalProduct(String orderItemId);

  // Shipping
  Future<List<ShippingMethodModel>> getShippingMethods();
}

@Injectable(as: EcommerceRemoteDataSource)
class EcommerceRemoteDataSourceImpl implements EcommerceRemoteDataSource {
  final DioClient _dioClient;
  final String baseUrl = ApiConstants.baseUrl;

  EcommerceRemoteDataSourceImpl({required http.Client client})
      : _dioClient = GetIt.instance<DioClient>();

  @override
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['perPage'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category'] = categoryId;
      }

      final response = await _dioClient.get(
        ApiConstants.ecommerceProducts,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return _mapProductList(response.data);
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    try {
      final response =
          await _dioClient.get('${ApiConstants.ecommerceProduct}/$slug');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on NotFoundException {
      rethrow;
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categorySlug) async {
    try {
      final response = await _dioClient
          .get('${ApiConstants.ecommerceCategory}/$categorySlug/product');
      return _mapProductList(response.data);
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.get(ApiConstants.ecommerceCategories);
      return _mapCategoryList(response.data);
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<CategoryModel> getCategoryBySlug(String slug) async {
    try {
      final response =
          await _dioClient.get('${ApiConstants.ecommerceCategory}/$slug');
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
    } on NotFoundException {
      rethrow;
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    try {
      dev.log('🌐 Getting orders for userId: $userId');
      final response = await _dioClient.get(ApiConstants.ecommerceOrders);

      dev.log('📡 Orders API Response Status: ${response.statusCode}');
      dev.log('📡 Orders API Response Data Type: ${response.data.runtimeType}');
      dev.log('📡 Orders API Response Data: ${response.data}');

      return _mapOrderList(response.data);
    } catch (e, stackTrace) {
      dev.log('❌ Error getting orders: $e');
      dev.log('📍 Stack trace: $stackTrace');
      throw ServerException('Server error: $e');
    }
  }

  @override
  Future<OrderModel> getOrder(String orderId) async {
    try {
      final response =
          await _dioClient.get('${ApiConstants.ecommerceOrder}/$orderId');
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } on NotFoundException {
      rethrow;
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response =
          await _dioClient.post(ApiConstants.ecommerceOrders, data: orderData);
      final orderId = response.data['id']?.toString();
      if (orderId == null) throw ServerException('Server error');
      final orderResp =
          await _dioClient.get('${ApiConstants.ecommerceOrder}/$orderId');
      return OrderModel.fromJson(orderResp.data as Map<String, dynamic>);
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<CartModel> getCart(String userId) async {
    try {
      // For now, return an empty cart
      await Future.delayed(const Duration(milliseconds: 500));
      return CartModel.empty();
    } catch (e) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<CartModel> addToCart(
      String userId, String productId, int quantity) async {
    try {
      // Mock implementation - in real app this would call the API
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, return an empty cart with the added item
      return CartModel.empty();
    } catch (e) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<CartModel> updateCartItemQuantity(
      String userId, String productId, int quantity) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 500));

      return CartModel.empty();
    } catch (e) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<CartModel> removeFromCart(String userId, String productId) async {
    try {
      // Mock implementation - return empty cart
      await Future.delayed(const Duration(milliseconds: 500));
      return CartModel.empty();
    } catch (e) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<List<ProductModel>> getWishlist(String userId) async {
    try {
      final response = await _dioClient.get(ApiConstants.ecommerceWishlist);
      return _mapProductList(response.data);
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      await _dioClient
          .post(ApiConstants.ecommerceWishlist, data: {'productId': productId});
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _dioClient.delete('${ApiConstants.ecommerceWishlist}/$productId');
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  // Mock data methods
  List<ProductModel> _getMockProducts() {
    final categories = _getMockCategories();

    return [
      ProductModel(
        id: '1',
        name: 'Bitcoin T-Shirt',
        slug: 'bitcoin-t-shirt',
        description: 'A high-quality t-shirt featuring the Bitcoin logo.',
        shortDescription: 'Bitcoin logo t-shirt',
        type: 'PHYSICAL',
        price: 29.99,
        categoryId: categories[0].id,
        inventoryQuantity: 100,
        status: true,
        image: 'https://via.placeholder.com/500x500?text=Bitcoin+T-Shirt',
        currency: 'USD',
        walletType: 'FIAT',
        rating: 4.5,
        reviewsCount: 12,
        category: categories[0],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ProductModel(
        id: '2',
        name: 'Ethereum Hoodie',
        slug: 'ethereum-hoodie',
        description: 'A comfortable hoodie featuring the Ethereum logo.',
        shortDescription: 'Ethereum logo hoodie',
        type: 'PHYSICAL',
        price: 49.99,
        categoryId: categories[0].id,
        inventoryQuantity: 75,
        status: true,
        image: 'https://via.placeholder.com/500x500?text=Ethereum+Hoodie',
        currency: 'USD',
        walletType: 'FIAT',
        rating: 4.8,
        reviewsCount: 8,
        category: categories[0],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ProductModel(
        id: '3',
        name: 'Crypto Trading Guide',
        slug: 'crypto-trading-guide',
        description: 'A comprehensive guide to cryptocurrency trading.',
        shortDescription: 'Learn crypto trading',
        type: 'DOWNLOADABLE',
        price: 19.99,
        categoryId: categories[1].id,
        inventoryQuantity: 999,
        status: true,
        image: 'https://via.placeholder.com/500x500?text=Crypto+Trading+Guide',
        currency: 'USD',
        walletType: 'FIAT',
        rating: 4.2,
        reviewsCount: 24,
        category: categories[1],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ProductModel(
        id: '4',
        name: 'Hardware Wallet',
        slug: 'hardware-wallet',
        description: 'A secure hardware wallet for your cryptocurrencies.',
        shortDescription: 'Secure crypto storage',
        type: 'PHYSICAL',
        price: 99.99,
        categoryId: categories[2].id,
        inventoryQuantity: 50,
        status: true,
        image: 'https://via.placeholder.com/500x500?text=Hardware+Wallet',
        currency: 'USD',
        walletType: 'FIAT',
        rating: 4.9,
        reviewsCount: 36,
        category: categories[2],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  List<CategoryModel> _getMockCategories() {
    return [
      const CategoryModel(
        id: '1',
        name: 'Clothing',
        slug: 'clothing',
        description: 'Cryptocurrency-themed clothing and apparel',
        image: 'https://via.placeholder.com/500x500?text=Clothing',
      ),
      const CategoryModel(
        id: '2',
        name: 'Books',
        slug: 'books',
        description: 'Books and guides about cryptocurrency',
        image: 'https://via.placeholder.com/500x500?text=Books',
      ),
      const CategoryModel(
        id: '3',
        name: 'Hardware',
        slug: 'hardware',
        description: 'Cryptocurrency hardware and accessories',
        image: 'https://via.placeholder.com/500x500?text=Hardware',
      ),
    ];
  }

  List<OrderModel> _getMockOrders() {
    final products = _getMockProducts();

    return [
      OrderModel(
        id: '1',
        userId: 'user1',
        orderNumber: 'ORD-12345',
        status: OrderStatus.closed,
        totalAmount: 79.98,
        currency: 'USD',
        walletType: WalletType.fiat,
        items: [
          OrderItemModel(
            id: 'item1',
            orderId: '1',
            productId: products[0].id,
            product: products[0].toEntity(),
            price: products[0].price,
            quantity: 1,
          ),
          OrderItemModel(
            id: 'item2',
            orderId: '1',
            productId: products[2].id,
            product: products[2].toEntity(),
            price: products[2].price,
            quantity: 1,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      OrderModel(
        id: '2',
        userId: 'user1',
        orderNumber: 'ORD-67890',
        status: OrderStatus.pending,
        totalAmount: 99.99,
        currency: 'USD',
        walletType: WalletType.fiat,
        items: [
          OrderItemModel(
            id: 'item3',
            orderId: '2',
            productId: products[3].id,
            product: products[3].toEntity(),
            price: products[3].price,
            quantity: 1,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Mapping helpers
  List<ProductModel> _mapProductList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ServerException('Server error');
  }

  List<CategoryModel> _mapCategoryList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ServerException('Server error');
  }

  List<OrderModel> _mapOrderList(dynamic data) {
    dev.log('🔍 Mapping order list data: $data');
    dev.log('🔍 Data type: ${data.runtimeType}');

    if (data is List) {
      dev.log('✅ Data is a List with ${data.length} items');
      try {
        return data.map((e) {
          dev.log('🔍 Processing order item: $e');
          return OrderModel.fromJson(e as Map<String, dynamic>);
        }).toList();
      } catch (e, stackTrace) {
        dev.log('❌ Error mapping order item: $e');
        dev.log('📍 Stack trace: $stackTrace');
        throw ServerException('Error mapping order data: $e');
      }
    }

    // If data is not a List, it might be wrapped in an object
    if (data is Map<String, dynamic>) {
      dev.log('🔍 Data is a Map, checking for orders array...');

      // Common patterns: {data: [...]} or {orders: [...]} or {result: [...]}
      final possibleKeys = ['data', 'orders', 'result', 'items'];
      for (final key in possibleKeys) {
        if (data.containsKey(key) && data[key] is List) {
          dev.log('✅ Found orders under key "$key"');
          return _mapOrderList(data[key]);
        }
      }

      dev.log('❌ No recognizable order array found in Map keys: ${data.keys}');
    }

    throw ServerException(
        'Expected List or Map with orders array, got: ${data.runtimeType}');
  }

  // Reviews
  @override
  Future<ReviewModel> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.ecommerceReviews}/$productId',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
      return ReviewModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<dynamic> trackOrder(String orderId) async {
    try {
      final response =
          await _dioClient.get('${ApiConstants.ecommerceOrder}/$orderId/track');
      return response.data;
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<String> downloadDigitalProduct(String orderItemId) async {
    try {
      final response = await _dioClient
          .get('${ApiConstants.ecommerceDownload}/$orderItemId');
      return (response.data as Map<String, dynamic>)['downloadUrl']
              ?.toString() ??
          '';
    } catch (_) {
      throw ServerException('Server error');
    }
  }

  @override
  Future<List<ShippingMethodModel>> getShippingMethods() async {
    try {
      final response = await _dioClient.get(ApiConstants.ecommerceShipping);
      if (response.data is List) {
        return (response.data as List)
            .map((e) =>
                ShippingMethodModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      throw ServerException('Server error');
    }
  }
}
