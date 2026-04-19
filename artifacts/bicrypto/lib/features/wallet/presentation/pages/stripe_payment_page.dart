import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/deposit_bloc.dart';

class StripePaymentPage extends StatefulWidget {
  const StripePaymentPage({
    super.key,
    required this.amount,
    required this.currency,
    required this.gatewayId,
  });

  final double amount;
  final String currency;
  final String gatewayId;

  @override
  State<StripePaymentPage> createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  String? _paymentIntentId;
  String? _clientSecret;

  @override
  void initState() {
    super.initState();
    _createPaymentIntent();
  }

  void _createPaymentIntent() {
    context.read<DepositBloc>().add(
          DepositCreateStripePaymentIntentRequested(
            amount: widget.amount,
            currency: widget.currency,
          ),
        );
  }

  Future<void> _processPayment() async {
    if (_clientSecret == null) {
      _showError('Payment not initialized. Please try again.');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      dev.log('🔵 STRIPE_PAGE: Processing payment with client secret');

      // Confirm payment with Stripe directly instead of using service
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: _clientSecret!,
      );

      dev.log('🔵 STRIPE_PAGE: Payment status: ${paymentIntent.status}');

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        dev.log('🟢 STRIPE_PAGE: Payment succeeded, verifying with backend');
        // Verify payment with backend
        context.read<DepositBloc>().add(
              DepositVerifyStripePaymentRequested(
                paymentIntentId: paymentIntent.id,
              ),
            );
      } else {
        _showError('Payment failed: ${paymentIntent.status}');
      }
    } on StripeException catch (e) {
      dev.log(
          '🔴 STRIPE_PAGE: StripeException: ${e.error.code} - ${e.error.message}');
      if (e.error.code == FailureCode.Canceled) {
        // User canceled - don't show error
        dev.log('🔵 STRIPE_PAGE: Payment was canceled by user');
        Navigator.pop(context, false);
      } else {
        _showError(
            'Payment failed: ${e.error.localizedMessage ?? e.error.message ?? 'Unknown error'}');
      }
    } catch (e) {
      dev.log('🔴 STRIPE_PAGE: Unexpected error: $e');
      _showError('Payment failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.priceDownColor,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.priceUpColor,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pay with Stripe',
          style: context.h6.copyWith(
            color: context.textPrimary,
          ),
        ),
      ),
      body: BlocListener<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositStripePaymentIntentCreated) {
            setState(() {
              _paymentIntentId = state.paymentIntentId;
              _clientSecret = state.clientSecret;
            });
          } else if (state is DepositStripePaymentVerified) {
            _showSuccess('Payment successful!');
            // Navigate back to deposit page or show success
            Navigator.pop(context, true);
          } else if (state is DepositError) {
            _showError(state.failure.message);
          }
        },
        child: BlocBuilder<DepositBloc, DepositState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Payment Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Summary',
                          style: context.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amount:',
                              style: context.bodyM.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                            Text(
                              '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                              style: context.h6.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment Method:',
                              style: context.bodyM.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Stripe',
                                style: context.labelM.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card Payment Form
                  if (_clientSecret != null) ...[
                    Text(
                      'Payment Details',
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Stripe Card Field
                            CardField(
                              onCardChanged: (card) {
                                // Card validation handled by Stripe
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: context.bodyL.copyWith(
                                color: context.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Security Note
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.colors.tertiary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      context.colors.tertiary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: context.colors.tertiary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Your payment is secured by Stripe. We never store your card details.',
                                      style: context.bodyS.copyWith(
                                        color: context.colors.tertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (state is DepositLoading) ...[
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Initializing payment...',
                            style: context.bodyM.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Pay Button
                  if (_clientSecret != null)
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          disabledBackgroundColor: context.textTertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.colors.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Processing...',
                                    style: context.labelL.copyWith(
                                      color: context.colors.onPrimary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Pay ${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                                style: context.labelL.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onPrimary,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
