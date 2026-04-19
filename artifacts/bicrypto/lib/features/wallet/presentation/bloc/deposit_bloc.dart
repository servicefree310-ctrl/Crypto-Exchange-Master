import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/deposit_gateway_entity.dart';
import '../../domain/entities/deposit_method_entity.dart';
import '../../domain/entities/deposit_transaction_entity.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../../domain/usecases/get_deposit_methods_usecase.dart';
import '../../domain/usecases/create_fiat_deposit_usecase.dart';
import '../../domain/usecases/get_currency_options_usecase.dart';
import '../../domain/usecases/create_stripe_payment_intent_usecase.dart';
import '../../domain/usecases/verify_stripe_payment_usecase.dart';
import '../../domain/usecases/create_paypal_order_usecase.dart';
import '../../domain/usecases/verify_paypal_payment_usecase.dart';

part 'deposit_event.dart';
part 'deposit_state.dart';

@injectable
class DepositBloc extends Bloc<DepositEvent, DepositState> {
  DepositBloc(
    this._getCurrencyOptionsUseCase,
    this._getDepositMethodsUseCase,
    this._createFiatDepositUseCase,
    this._createStripePaymentIntentUseCase,
    this._verifyStripePaymentUseCase,
    this._createPayPalOrderUseCase,
    this._verifyPayPalPaymentUseCase,
  ) : super(const DepositInitial()) {
    on<CurrencyOptionsRequested>(_onCurrencyOptionsRequested);
    on<DepositMethodsRequested>(_onDepositMethodsRequested);
    on<FiatDepositCreated>(_onFiatDepositCreated);
    on<DepositCreateStripePaymentIntentRequested>(
        _onCreateStripePaymentIntentRequested);
    on<DepositVerifyStripePaymentRequested>(_onVerifyStripePaymentRequested);
    on<DepositCreatePayPalOrderRequested>(_onCreatePayPalOrderRequested);
    on<DepositVerifyPayPalPaymentRequested>(_onVerifyPayPalPaymentRequested);
    on<DepositReset>(_onDepositReset);
  }

  final GetCurrencyOptionsUseCase _getCurrencyOptionsUseCase;
  final GetDepositMethodsUseCase _getDepositMethodsUseCase;
  final CreateFiatDepositUseCase _createFiatDepositUseCase;
  final CreateStripePaymentIntentUseCase _createStripePaymentIntentUseCase;
  final VerifyStripePaymentUseCase _verifyStripePaymentUseCase;
  final CreatePayPalOrderUseCase _createPayPalOrderUseCase;
  final VerifyPayPalPaymentUseCase _verifyPayPalPaymentUseCase;

  Future<void> _onCurrencyOptionsRequested(
    CurrencyOptionsRequested event,
    Emitter<DepositState> emit,
  ) async {
    dev.log('🔵 DEPOSIT_BLOC: Fetching currency options for ${event.walletType}');
    emit(const DepositLoading());

    final result = await _getCurrencyOptionsUseCase(
      GetCurrencyOptionsParams(walletType: event.walletType),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 DEPOSIT_BLOC: Failed to fetch currency options: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (currencies) {
        dev.log(
            '🟢 DEPOSIT_BLOC: Successfully loaded ${currencies.length} currency options');
        emit(CurrencyOptionsLoaded(currencies: currencies));
      },
    );
  }

  Future<void> _onDepositMethodsRequested(
    DepositMethodsRequested event,
    Emitter<DepositState> emit,
  ) async {
    dev.log('🔵 DEPOSIT_BLOC: Fetching deposit methods for ${event.currency}');
    emit(const DepositLoading());

    final result = await _getDepositMethodsUseCase(
      GetDepositMethodsParams(currency: event.currency),
    );

    result.fold(
      (failure) {
        dev.log('🔴 DEPOSIT_BLOC: Failed to fetch methods: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (methodsResult) {
        dev.log(
            '🟢 DEPOSIT_BLOC: Successfully loaded ${methodsResult.gateways.length} gateways and ${methodsResult.methods.length} methods');
        emit(DepositMethodsLoaded(
          gateways: methodsResult.gateways,
          methods: methodsResult.methods,
        ));
      },
    );
  }

  Future<void> _onFiatDepositCreated(
    FiatDepositCreated event,
    Emitter<DepositState> emit,
  ) async {
    dev.log('🔵 DEPOSIT_BLOC: Creating FIAT deposit');
    emit(const DepositCreating());

    final result = await _createFiatDepositUseCase(
      CreateFiatDepositParams(
        methodId: event.methodId,
        amount: event.amount,
        currency: event.currency,
        customFields: event.customFields,
      ),
    );

    result.fold(
      (failure) {
        dev.log('🔴 DEPOSIT_BLOC: Failed to create deposit: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (transaction) {
        dev.log(
            '🟢 DEPOSIT_BLOC: Successfully created deposit: ${transaction.id}');
        emit(DepositCreated(transaction: transaction));
      },
    );
  }

  Future<void> _onCreateStripePaymentIntentRequested(
    DepositCreateStripePaymentIntentRequested event,
    Emitter<DepositState> emit,
  ) async {
    dev.log(
        '🔵 DEPOSIT_BLOC: Creating Stripe payment intent for ${event.amount} ${event.currency}');
    emit(const DepositLoading());

    final result = await _createStripePaymentIntentUseCase(
      CreateStripePaymentIntentParams(
        amount: event.amount,
        currency: event.currency,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 DEPOSIT_BLOC: Failed to create Stripe payment intent: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (paymentIntentData) {
        final paymentIntentId = paymentIntentData['id'] as String;
        final clientSecret = paymentIntentData['clientSecret'] as String;

        dev.log(
            '🟢 DEPOSIT_BLOC: Successfully created Stripe payment intent: $paymentIntentId');
        emit(DepositStripePaymentIntentCreated(
          paymentIntentId: paymentIntentId,
          clientSecret: clientSecret,
        ));
      },
    );
  }

  Future<void> _onVerifyStripePaymentRequested(
    DepositVerifyStripePaymentRequested event,
    Emitter<DepositState> emit,
  ) async {
    dev.log(
        '🔵 DEPOSIT_BLOC: Verifying Stripe payment for intent: ${event.paymentIntentId}');
    emit(const DepositLoading());

    final result = await _verifyStripePaymentUseCase(
      VerifyStripePaymentParams(
        paymentIntentId: event.paymentIntentId,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 DEPOSIT_BLOC: Failed to verify Stripe payment: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (transaction) {
        dev.log(
            '🟢 DEPOSIT_BLOC: Successfully verified Stripe payment: ${transaction.id}');
        emit(DepositStripePaymentVerified(transaction: transaction));
      },
    );
  }

  Future<void> _onCreatePayPalOrderRequested(
    DepositCreatePayPalOrderRequested event,
    Emitter<DepositState> emit,
  ) async {
    dev.log(
        '🔵 DEPOSIT_BLOC: Creating PayPal order for ${event.amount} ${event.currency}');
    emit(const DepositLoading());

    final result = await _createPayPalOrderUseCase(
      CreatePayPalOrderParams(
        amount: event.amount,
        currency: event.currency,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 DEPOSIT_BLOC: Failed to create PayPal order: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (orderData) {
        final orderId = orderData['id'] as String;
        final links = orderData['links'] as List<dynamic>;

        // Find approval URL from links
        String approvalUrl = '';
        for (final link in links) {
          final linkMap = link as Map<String, dynamic>;
          if (linkMap['rel'] == 'approve') {
            approvalUrl = linkMap['href'] as String;
            break;
          }
        }

        dev.log('🟢 DEPOSIT_BLOC: Successfully created PayPal order: $orderId');
        emit(DepositPayPalOrderCreated(
          orderId: orderId,
          approvalUrl: approvalUrl,
        ));
      },
    );
  }

  Future<void> _onVerifyPayPalPaymentRequested(
    DepositVerifyPayPalPaymentRequested event,
    Emitter<DepositState> emit,
  ) async {
    dev.log(
        '🔵 DEPOSIT_BLOC: Verifying PayPal payment for order: ${event.orderId}');
    emit(const DepositLoading());

    final result = await _verifyPayPalPaymentUseCase(
      VerifyPayPalPaymentParams(
        orderId: event.orderId,
      ),
    );

    result.fold(
      (failure) {
        dev.log(
            '🔴 DEPOSIT_BLOC: Failed to verify PayPal payment: ${failure.message}');
        emit(DepositError(failure: failure));
      },
      (transaction) {
        dev.log(
            '🟢 DEPOSIT_BLOC: Successfully verified PayPal payment: ${transaction.id}');
        emit(DepositPayPalPaymentVerified(transaction: transaction));
      },
    );
  }

  void _onDepositReset(
    DepositReset event,
    Emitter<DepositState> emit,
  ) {
    dev.log('🔵 DEPOSIT_BLOC: Resetting deposit state');
    emit(const DepositInitial());
  }
}
