import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class PlaceOrderUseCase implements UseCase<OrderEntity, PlaceOrderParams> {
  final EcommerceRepository repository;

  PlaceOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) {
    return repository.placeOrder(
      items: params.items,
      totalAmount: params.totalAmount,
      currency: params.currency,
      shippingAddressId: params.shippingAddressId,
      shippingMethodId: params.shippingMethodId,
      paymentMethod: params.paymentMethod,
      shippingAddress: params.shippingAddress,
      discountId: params.discountId,
    );
  }
}

class PlaceOrderParams extends Equatable {
  final List<CartItemEntity> items;
  final double totalAmount;
  final String currency;
  final String? shippingAddressId;
  final String? shippingMethodId;
  final String? paymentMethod;
  final Map<String, String>? shippingAddress;
  final String? discountId;

  const PlaceOrderParams({
    required this.items,
    required this.totalAmount,
    required this.currency,
    this.shippingAddressId,
    this.shippingMethodId,
    this.paymentMethod,
    this.shippingAddress,
    this.discountId,
  });

  @override
  List<Object?> get props => [
        items,
        totalAmount,
        currency,
        shippingAddressId,
        shippingMethodId,
        paymentMethod,
        shippingAddress,
        discountId,
      ];
}
