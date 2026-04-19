import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../domain/entities/product_entity.dart';
import '../../../../../../../core/constants/api_constants.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

@injectable
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final SharedPreferences _prefs;
  static const String _wishlistKey = 'ecommerce_wishlist';

  WishlistBloc(this._prefs) : super(const WishlistInitial()) {
    on<LoadWishlistRequested>(_onLoadWishlistRequested);
    on<AddToWishlistRequested>(_onAddToWishlistRequested);
    on<RemoveFromWishlistRequested>(_onRemoveFromWishlistRequested);
    on<ClearWishlistRequested>(_onClearWishlistRequested);
  }

  Future<void> _onLoadWishlistRequested(
    LoadWishlistRequested event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      emit(const WishlistLoading());
      final products = await _loadWishlistFromStorage();
      emit(WishlistLoaded(products: products));
    } catch (e) {
      emit(WishlistError(
        message: 'Failed to load wishlist: ${e.toString()}',
        previousProducts: [],
      ));
    }
  }

  Future<void> _onAddToWishlistRequested(
    AddToWishlistRequested event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      final currentProducts = await _loadWishlistFromStorage();

      // Check if product already exists
      if (currentProducts.any((p) => p.id == event.product.id)) {
        emit(WishlistLoaded(products: currentProducts));
        return;
      }

      final updatedProducts = [...currentProducts, event.product];
      await _saveWishlistToStorage(updatedProducts);
      emit(WishlistLoaded(products: updatedProducts));
    } catch (e) {
      final currentProducts = await _loadWishlistFromStorage();
      emit(WishlistError(
        message: 'Failed to add to wishlist: ${e.toString()}',
        previousProducts: currentProducts,
      ));
    }
  }

  Future<void> _onRemoveFromWishlistRequested(
    RemoveFromWishlistRequested event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      final currentProducts = await _loadWishlistFromStorage();
      final updatedProducts = currentProducts
          .where((product) => product.id != event.productId)
          .toList();

      await _saveWishlistToStorage(updatedProducts);
      emit(WishlistLoaded(products: updatedProducts));
    } catch (e) {
      final currentProducts = await _loadWishlistFromStorage();
      emit(WishlistError(
        message: 'Failed to remove from wishlist: ${e.toString()}',
        previousProducts: currentProducts,
      ));
    }
  }

  Future<void> _onClearWishlistRequested(
    ClearWishlistRequested event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await _saveWishlistToStorage([]);
      emit(const WishlistLoaded(products: []));
    } catch (e) {
      emit(WishlistError(
        message: 'Failed to clear wishlist: ${e.toString()}',
        previousProducts: [],
      ));
    }
  }

  Future<List<ProductEntity>> _loadWishlistFromStorage() async {
    try {
      final wishlistJson = _prefs.getString(_wishlistKey);
      if (wishlistJson == null) {
        return [];
      }

      final wishlistData = json.decode(wishlistJson) as List<dynamic>;
      return wishlistData
          .map((item) => _productFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveWishlistToStorage(List<ProductEntity> products) async {
    try {
      final wishlistData =
          products.map((product) => _productToJson(product)).toList();
      await _prefs.setString(_wishlistKey, json.encode(wishlistData));
    } catch (e) {
      throw Exception('Failed to save wishlist to storage: $e');
    }
  }

  Map<String, dynamic> _productToJson(ProductEntity product) {
    return {
      'id': product.id,
      'name': product.name,
      'slug': product.slug,
      'price': product.price,
      'currency': product.currency,
      'image': product.image,
      'inventoryQuantity': product.inventoryQuantity,
      'status': product.status,
      'description': product.description,
      'shortDescription': product.shortDescription,
      'type': product.type.name,
      'walletType': product.walletType.name,
    };
  }

  ProductEntity _productFromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String,
      type: ProductType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductType.downloadable,
      ),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      walletType: WalletType.values.firstWhere(
        (e) => e.name == json['walletType'],
        orElse: () => WalletType.spot,
      ),
      inventoryQuantity: json['inventoryQuantity'] as int,
      status: json['status'] as bool,
      image: json['image'] as String?,
    );
  }

  // Helper method to check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    final products = await _loadWishlistFromStorage();
    return products.any((product) => product.id == productId);
  }
}
