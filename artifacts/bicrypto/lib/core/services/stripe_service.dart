import 'dart:developer' as dev;

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_constants.dart';

@singleton
class StripeService {
  Future<void> initialize() async {
    dev.log('🔵 STRIPE_SERVICE: Initializing Stripe');

    // Get the publishable key from API constants (now from configuration)
    final publishableKey = ApiConstants.stripePublishableKey;

    if (publishableKey.isEmpty) {
      dev.log(
          '⚠️ STRIPE_SERVICE: No Stripe publishable key configured, skipping initialization');
      return;
    }

    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();

    dev.log('🟢 STRIPE_SERVICE: Stripe initialized successfully');
  }

  Future<PaymentIntent> confirmPayment({
    required String clientSecret,
  }) async {
    dev.log(
        '🔵 STRIPE_SERVICE: Confirming payment with client secret: ${clientSecret.substring(0, 20)}...');

    try {
      // Always create new payment method for card payments
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      dev.log(
          '🟢 STRIPE_SERVICE: Payment confirmed successfully: ${paymentIntent.status}');
      return paymentIntent;
    } on StripeException catch (e) {
      dev.log('🔴 STRIPE_SERVICE: Stripe error: ${e.error.message}');
      rethrow;
    } catch (e) {
      dev.log('🔴 STRIPE_SERVICE: Unexpected error: $e');
      rethrow;
    }
  }

  Future<PaymentMethod> createPaymentMethod({
    required PaymentMethodParams params,
  }) async {
    dev.log('🔵 STRIPE_SERVICE: Creating payment method');

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: params,
      );

      dev.log('🟢 STRIPE_SERVICE: Payment method created: ${paymentMethod.id}');
      return paymentMethod;
    } on StripeException catch (e) {
      dev.log(
          '🔴 STRIPE_SERVICE: Failed to create payment method: ${e.error.message}');
      rethrow;
    }
  }

  Future<void> presentPaymentSheet() async {
    dev.log('🔵 STRIPE_SERVICE: Presenting payment sheet');

    try {
      await Stripe.instance.presentPaymentSheet();
      dev.log('🟢 STRIPE_SERVICE: Payment sheet completed');
    } on StripeException catch (e) {
      dev.log('🔴 STRIPE_SERVICE: Payment sheet error: ${e.error.message}');
      if (e.error.code == FailureCode.Canceled) {
        dev.log('🟡 STRIPE_SERVICE: Payment was cancelled by user');
      }
      rethrow;
    }
  }

  Future<bool> isCardValid({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    try {
      // Basic validation
      if (cardNumber.length < 16 ||
          expiryMonth.isEmpty ||
          expiryYear.isEmpty ||
          cvc.length < 3) {
        return false;
      }

      // Additional Stripe validation can be added here
      return true;
    } catch (e) {
      dev.log('🔴 STRIPE_SERVICE: Card validation error: $e');
      return false;
    }
  }
}
