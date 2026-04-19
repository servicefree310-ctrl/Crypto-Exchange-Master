import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

abstract class EcommerceLocalDataSource {
  // Cart
  Future<CartModel> getCart();
  Future<void> saveCart(CartModel cart);
  Future<void> clearCart();

  // Wishlist
  Future<List<ProductModel>> getWishlist();
  Future<void> saveWishlist(List<ProductModel> wishlist);
  Future<void> clearWishlist();

  // Cache
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);

  Future<List<CategoryModel>> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
}

@Injectable(as: EcommerceLocalDataSource)
class EcommerceLocalDataSourceImpl implements EcommerceLocalDataSource {
  final SharedPreferences sharedPreferences;

  EcommerceLocalDataSourceImpl({required this.sharedPreferences});

  // Keys for SharedPreferences
  static const String cartKey = 'ECOMMERCE_CART';
  static const String wishlistKey = 'ECOMMERCE_WISHLIST';
  static const String productsKey = 'ECOMMERCE_PRODUCTS';
  static const String categoriesKey = 'ECOMMERCE_CATEGORIES';

  @override
  Future<CartModel> getCart() async {
    try {
      final jsonString = sharedPreferences.getString(cartKey);
      if (jsonString != null) {
        return CartModel.fromJson(json.decode(jsonString));
      } else {
        return CartModel.empty();
      }
    } catch (e) {
      return CartModel.empty();
    }
  }

  @override
  Future<void> saveCart(CartModel cart) async {
    await sharedPreferences.setString(
      cartKey,
      json.encode(cart.toJson()),
    );
  }

  @override
  Future<void> clearCart() async {
    await sharedPreferences.remove(cartKey);
  }

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final jsonString = sharedPreferences.getString(wishlistKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveWishlist(List<ProductModel> wishlist) async {
    await sharedPreferences.setString(
      wishlistKey,
      json.encode(wishlist.map((product) => product.toJson()).toList()),
    );
  }

  @override
  Future<void> clearWishlist() async {
    await sharedPreferences.remove(wishlistKey);
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final jsonString = sharedPreferences.getString(productsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw CacheException('Cache error');
      }
    } catch (e) {
      throw CacheException('Cache error');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    await sharedPreferences.setString(
      productsKey,
      json.encode(products.map((product) => product.toJson()).toList()),
    );
  }

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    try {
      final jsonString = sharedPreferences.getString(categoriesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw CacheException('Cache error');
      }
    } catch (e) {
      throw CacheException('Cache error');
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    await sharedPreferences.setString(
      categoriesKey,
      json.encode(categories.map((category) => category.toJson()).toList()),
    );
  }
}
