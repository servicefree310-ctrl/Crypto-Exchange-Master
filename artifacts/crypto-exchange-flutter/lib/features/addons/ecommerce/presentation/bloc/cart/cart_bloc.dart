import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/cart_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/add_to_cart_usecase.dart';
import '../../../domain/usecases/get_cart_usecase.dart';
import '../../../domain/usecases/update_cart_item_quantity_usecase.dart';
import '../../../domain/usecases/remove_from_cart_usecase.dart';
import '../../../domain/usecases/clear_cart_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartItemQuantityUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<LoadCartRequested>(_onLoadCartRequested);
    on<AddToCartRequested>(_onAddToCartRequested);
    on<UpdateCartItemQuantityRequested>(_onUpdateCartItemQuantityRequested);
    on<RemoveFromCartRequested>(_onRemoveFromCartRequested);
    on<ClearCartRequested>(_onClearCartRequested);
  }

  Future<void> _onLoadCartRequested(
    LoadCartRequested event,
    Emitter<CartState> emit,
  ) async {
    dev.log('🛒 CartBloc: Loading cart requested');
    emit(CartLoading());

    try {
      final result = await getCartUseCase(NoParams());
      result.fold(
        (failure) {
          dev.log('❌ CartBloc: Cart loading failed - ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (cart) {
          dev.log(
              '✅ CartBloc: Cart loaded successfully with ${cart.items.length} items');
          emit(CartLoaded(cart: cart));
        },
      );
    } catch (e, stackTrace) {
      dev.log('💥 CartBloc: Unexpected error loading cart - $e');
      dev.log('📍 Stack trace: $stackTrace');
      emit(CartError(message: 'Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCartRequested(
    AddToCartRequested event,
    Emitter<CartState> emit,
  ) async {
    dev.log(
        '🛒 CartBloc: Adding ${event.product.name} to cart (quantity: ${event.quantity})');
    emit(CartLoading());

    try {
      final result = await addToCartUseCase(AddToCartParams(
        product: event.product,
        quantity: event.quantity,
      ));
      result.fold(
        (failure) {
          dev.log('❌ CartBloc: Add to cart failed - ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (cart) {
          dev.log(
              '✅ CartBloc: Added to cart successfully, total items: ${cart.items.length}');
          emit(CartLoaded(cart: cart));
        },
      );
    } catch (e, stackTrace) {
      dev.log('💥 CartBloc: Unexpected error adding to cart - $e');
      dev.log('📍 Stack trace: $stackTrace');
      emit(CartError(message: 'Failed to add to cart: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCartItemQuantityRequested(
    UpdateCartItemQuantityRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await updateCartItemQuantityUseCase(
      UpdateCartItemQuantityParams(
        productId: event.productId,
        quantity: event.quantity,
      ),
    );
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  Future<void> _onRemoveFromCartRequested(
    RemoveFromCartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await removeFromCartUseCase(
      RemoveFromCartParams(productId: event.productId),
    );
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  Future<void> _onClearCartRequested(
    ClearCartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await clearCartUseCase(NoParams());
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }
}
