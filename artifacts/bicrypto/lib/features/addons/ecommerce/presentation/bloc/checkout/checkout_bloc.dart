import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/constants/api_constants.dart';
import '../../../../../wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../domain/usecases/place_order_usecase.dart';
import '../../../domain/usecases/get_cart_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase _placeOrderUseCase;
  final GetCartUseCase _getCartUseCase;

  CheckoutBloc(
    this._placeOrderUseCase,
    this._getCartUseCase,
  ) : super(CheckoutInitial()) {
    on<CheckoutInitialized>(_onCheckoutInitialized);
    on<WalletsLoaded>(_onWalletsLoaded);
    on<WalletSelected>(_onWalletSelected);
    on<ShippingAddressUpdated>(_onShippingAddressUpdated);
    on<ShippingMethodSelected>(_onShippingMethodSelected);
    on<CouponApplied>(_onCouponApplied);
    on<CouponRemoved>(_onCouponRemoved);
    on<OrderPlaced>(_onOrderPlaced);
    on<CheckoutReset>(_onCheckoutReset);
  }

  Future<void> _onCheckoutInitialized(
    CheckoutInitialized event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    try {
      // Calculate initial totals — backend handles tax/shipping during order creation,
      // but we show subtotal to the user for reference.
      final subtotal = event.cart.total;
      final total = subtotal;

      final checkoutState = CheckoutLoaded(
        cart: event.cart,
        subtotal: subtotal,
        total: total,
      );

      emit(checkoutState);

      // Auto-load wallets for each currency/type combination
      final cartGroups = checkoutState.cartByWallet;
      for (final entry in cartGroups.entries) {
        final group = entry.value;
        add(WalletsLoaded(
          walletType: group.walletType.name,
          currency: group.currency,
        ));
      }
    } catch (e) {
      emit(CheckoutError(UnknownFailure(e.toString())));
    }
  }

  Future<void> _onWalletsLoaded(
    WalletsLoaded event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;
    final walletKey = '${event.walletType}-${event.currency}';

    // Set loading state for this wallet
    emit(currentState.copyWith(
      walletLoading: {
        ...currentState.walletLoading,
        walletKey: true,
      },
    ));

    try {
      // Fetch real wallet data from the wallet service
      final walletDataSource = GetIt.instance<WalletRemoteDataSource>();
      final walletModel = await walletDataSource.getWallet(
        event.walletType.toUpperCase(),
        event.currency.toUpperCase(),
      );

      final walletOption = WalletOption(
        id: walletModel.id,
        name: '${walletModel.currency} Wallet',
        type: event.walletType,
        currency: event.currency,
        balance: walletModel.balance,
      );

      dev.log('Wallet loaded: ${walletOption.name} balance=${walletOption.balance}');

      emit(currentState.copyWith(
        walletLoading: {
          ...currentState.walletLoading,
          walletKey: false,
        },
        availableWallets: {
          ...currentState.availableWallets,
          walletKey: [walletOption],
        },
        selectedWallets: {
          ...currentState.selectedWallets,
          walletKey: walletOption.id,
        },
      ));
    } catch (e) {
      dev.log('Failed to load wallet: $e');
      emit(currentState.copyWith(
        walletLoading: {
          ...currentState.walletLoading,
          walletKey: false,
        },
        walletErrors: {
          ...currentState.walletErrors,
          walletKey:
              'No ${event.walletType} wallet with ${event.currency} found',
        },
      ));
    }
  }

  void _onWalletSelected(
    WalletSelected event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;

    emit(currentState.copyWith(
      selectedWallets: {
        ...currentState.selectedWallets,
        event.walletKey: event.walletId,
      },
    ));
  }

  void _onShippingAddressUpdated(
    ShippingAddressUpdated event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;

    emit(currentState.copyWith(
      shippingAddress: event.address,
    ));
  }

  void _onShippingMethodSelected(
    ShippingMethodSelected event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;

    // Recalculate totals with new shipping cost
    final subtotal = currentState.subtotal;
    final shipping = event.method.cost;
    final discount = currentState.discount;
    final total = subtotal + shipping - discount;

    emit(currentState.copyWith(
      shippingMethod: event.method,
      shipping: shipping,
      total: total,
    ));
  }

  Future<void> _onCouponApplied(
    CouponApplied event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;

    // Note: Coupon validation is handled in CheckoutPageV5 via ValidateDiscountUseCase.
    // This event is for the old CheckoutPage's bloc-based flow.
    // The discount data (id, code, type, value) should be passed from the page.
    const mockDiscount = DiscountData(
      id: 'mock',
      code: 'DISCOUNT10',
      type: 'PERCENTAGE',
      value: 10.0,
      message: '10% discount applied!',
    );

    final discountAmount = currentState.subtotal * (mockDiscount.value / 100);
    final total = currentState.subtotal +
        currentState.shipping -
        discountAmount;

    emit(currentState.copyWith(
      appliedDiscount: mockDiscount,
      discount: discountAmount,
      total: total,
    ));
  }

  void _onCouponRemoved(
    CouponRemoved event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;
    final total = currentState.subtotal + currentState.shipping;

    emit(currentState.copyWith(
      appliedDiscount: null,
      discount: 0.0,
      total: total,
    ));
  }

  Future<void> _onOrderPlaced(
    OrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;

    emit(CheckoutProcessing());

    try {
      // Validate all required data
      if (!currentState.isWalletSelectionComplete) {
        emit(CheckoutError(
            ValidationFailure('Please select wallets for all items')));
        return;
      }

      if (currentState.hasWalletErrors) {
        emit(
            CheckoutError(ValidationFailure('Wallet validation errors found')));
        return;
      }

      // Build shipping address map for physical products
      Map<String, String>? shippingAddressMap;
      if (currentState.hasPhysicalProducts) {
        final addr = currentState.shippingAddress;
        if (addr == null) {
          emit(CheckoutError(ValidationFailure(
              'Shipping address required for physical products')));
          return;
        }
        shippingAddressMap = {
          'name': addr.fullName,
          'email': '', // filled from form in page
          'phone': addr.phone,
          'street': addr.address1,
          'city': addr.city,
          'state': addr.state,
          'postalCode': addr.postalCode,
          'country': addr.country,
        };
      }

      // Place the order — backend handles tax, shipping, and wallet deduction
      final result = await _placeOrderUseCase(PlaceOrderParams(
        items: currentState.cart.items,
        totalAmount: currentState.total,
        currency: currentState.cart.currency,
        shippingAddressId: currentState.shippingAddress?.id,
        shippingMethodId: currentState.shippingMethod?.id,
        paymentMethod: 'wallet',
        shippingAddress: shippingAddressMap,
        discountId: currentState.appliedDiscount?.id,
      ));

      result.fold(
        (failure) => emit(CheckoutError(failure)),
        (order) => emit(CheckoutSuccess(order)),
      );
    } catch (e) {
      emit(CheckoutError(UnknownFailure(e.toString())));
    }
  }

  void _onCheckoutReset(
    CheckoutReset event,
    Emitter<CheckoutState> emit,
  ) {
    emit(CheckoutInitial());
  }
}
