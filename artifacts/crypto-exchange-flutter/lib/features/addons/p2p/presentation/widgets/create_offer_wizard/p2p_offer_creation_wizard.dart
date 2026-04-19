import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../bloc/offers/create_offer_bloc.dart';
import '../../bloc/offers/create_offer_event.dart';
import '../../bloc/offers/create_offer_state.dart';
import 'wizard_steps/step_1_trade_type.dart';
import 'wizard_steps/step_2_wallet_type.dart';
import 'wizard_steps/step_3_select_crypto.dart';
import 'wizard_steps/step_4_amount_price.dart';
import 'wizard_steps/step_5_payment_methods.dart';
import 'wizard_steps/step_6_trade_settings.dart';
import 'wizard_steps/step_7_location_settings.dart';
import 'wizard_steps/step_8_user_requirements.dart';
import 'wizard_steps/step_9_review.dart';

/// P2P Offer Creation Wizard - V5-Compatible 9-Step Process
class P2POfferCreationWizard extends StatefulWidget {
  const P2POfferCreationWizard({
    super.key,
    this.initialTradeType,
  });

  final String? initialTradeType;

  @override
  State<P2POfferCreationWizard> createState() => _P2POfferCreationWizardState();
}

class _P2POfferCreationWizardState extends State<P2POfferCreationWizard> {
  late CreateOfferBloc _bloc;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CreateOfferBloc>();
    _pageController = PageController();

    // Initialize the wizard
    _bloc.add(const CreateOfferStarted());

    // Pre-set trade type if provided
    if (widget.initialTradeType != null) {
      _bloc.add(CreateOfferFieldUpdated(
        field: 'type',
        value: widget.initialTradeType,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: _buildAppBar(context),
      body: BlocListener<CreateOfferBloc, CreateOfferState>(
        listener: (context, state) {
          if (state is CreateOfferSuccess) {
            dev.log('🎉 UI SUCCESS: P2P offer created successfully!');
            dev.log('📋 UI SUCCESS: Offer data: ${state.offer}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'P2P offer created successfully!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Navigate to home page
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is CreateOfferFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to create offer: ${state.failure.message}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: context.colors.error,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    _bloc.add(const CreateOfferSubmitted());
                  },
                ),
              ),
            );
          }
        },
        child: BlocBuilder<CreateOfferBloc, CreateOfferState>(
          builder: (context, state) {
            if (state is CreateOfferInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CreateOfferEditing) {
              return Column(
                children: [
                  _buildProgressStepper(state),
                  Expanded(
                    child: _buildStepContent(state),
                  ),
                  _buildNavigationButtons(state),
                ],
              );
            }

            if (state is CreateOfferSubmitting) {
              return _buildSubmittingState(context);
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: context.textPrimary),
        onPressed: () {
          _showExitConfirmation(context);
        },
      ),
      title: Text(
        'Create P2P Offer',
        style: context.h6.copyWith(
          color: context.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: context.borderColor,
        ),
      ),
    );
  }

  Widget _buildProgressStepper(CreateOfferEditing state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(color: context.borderColor, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Step indicator
          Row(
            children: [
              Text(
                'Step ${state.step.stepNumber} of ${CreateOfferStep.values.length}',
                style: context.bodyM.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _getStepTitle(state.step),
                style: context.bodyM.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            children: List.generate(CreateOfferStep.values.length, (index) {
              final step = CreateOfferStep.values[index];
              final isCompleted = state.isStepCompleted(step);
              final isCurrent = state.step == step;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < CreateOfferStep.values.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? context.colors.primary
                        : context.colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(CreateOfferEditing state) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Step1TradeType(bloc: _bloc),
        Step2WalletType(bloc: _bloc),
        Step3SelectCrypto(bloc: _bloc),
        Step4AmountPrice(bloc: _bloc),
        const Step5PaymentMethods(),
        const Step6TradeSettings(),
        const Step7LocationSettings(),
        const Step8UserRequirements(),
        const Step9Review(),
      ],
    );
  }

  Widget _buildNavigationButtons(CreateOfferEditing state) {
    final canGoNext = _canProceedToNext(state);
    final isLastStep = state.step.isLastStep;
    final canGoBack = state.step != CreateOfferStep.tradeType;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (canGoBack) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _bloc.add(const CreateOfferPreviousStep());
                  _animateToStep(state.step.previousStep!);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.borderColor),
                  foregroundColor: context.textPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios,
                        size: 16, color: context.textSecondary),
                    const SizedBox(width: 8),
                    Text('Back'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: canGoBack ? 1 : 2,
            child: ElevatedButton(
              onPressed: canGoNext
                  ? () {
                      if (isLastStep) {
                        dev.log('🖱️ UI: "Create Offer" button pressed');
                        dev.log('📊 UI: Current state data: ${state.formData}');
                        _bloc.add(const CreateOfferSubmitted());
                      } else {
                        dev.log(
                            '🖱️ UI: "Continue" button pressed for step: ${state.step}');
                        _bloc.add(const CreateOfferNextStep());
                        _animateToStep(state.step.nextStep!);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor:
                    context.colors.primary.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(isLastStep ? 'Create Offer' : 'Continue'),
                  if (!state.isLoading && !isLastStep) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 24),
          Text(
            'Creating Your Offer...',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your offer',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _animateToStep(CreateOfferStep step) {
    _pageController.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _canProceedToNext(CreateOfferEditing state) {
    // Check if current step is valid
    switch (state.step) {
      case CreateOfferStep.tradeType:
        return state.tradeType != null &&
            ['BUY', 'SELL'].contains(state.tradeType);

      case CreateOfferStep.walletType:
        return state.walletType != null &&
            ['FIAT', 'SPOT', 'ECO'].contains(state.walletType);

      case CreateOfferStep.selectCrypto:
        return state.currency != null && state.currency!.isNotEmpty;

      case CreateOfferStep.amountPrice:
        return _validateAmountPriceStep(state);

      case CreateOfferStep.paymentMethods:
        final methods = state.paymentMethodIds;
        return methods != null && methods.isNotEmpty;

      case CreateOfferStep.tradeSettings:
        return _validateTradeSettingsStep(state);

      case CreateOfferStep.locationSettings:
        final location = state.locationSettings;
        return location != null &&
            location['country'] != null &&
            location['country'].toString().trim().isNotEmpty;

      case CreateOfferStep.userRequirements:
        return _validateUserRequirementsStep(state);

      case CreateOfferStep.review:
        // Review step - check all required steps are completed
        return _validateAllSteps(state);
    }
  }

  bool _validateAmountPriceStep(CreateOfferEditing state) {
    final amountConfig = state.amountConfig;
    final priceConfig = state.priceConfig;

    dev.log('🔍 STEP 4 VALIDATION: Checking amount & price step');

    // Basic existence checks
    if (amountConfig == null || priceConfig == null) {
      dev.log('❌ STEP 4 VALIDATION: Missing amount or price config');
      return false;
    }

    final total = amountConfig['total'] as num?;
    final min = amountConfig['min'] as num?;
    final max = amountConfig['max'] as num?;
    final finalPrice = priceConfig['finalPrice'] as num?;

    dev.log(
        '📊 STEP 4 VALIDATION: total=$total, min=$min, max=$max, price=$finalPrice');

    // Check basic requirements
    if (total == null || total <= 0) {
      dev.log('❌ STEP 4 VALIDATION: Invalid total amount');
      return false;
    }

    if (finalPrice == null || finalPrice <= 0) {
      dev.log('❌ STEP 4 VALIDATION: Invalid price');
      return false;
    }

    if (min != null && min <= 0) {
      dev.log('❌ STEP 4 VALIDATION: Invalid minimum limit');
      return false;
    }

    if (max != null && max <= 0) {
      dev.log('❌ STEP 4 VALIDATION: Invalid maximum limit');
      return false;
    }

    // Business logic validation
    if (min != null && max != null && min > max) {
      dev.log('❌ STEP 4 VALIDATION: Min > Max');
      return false;
    }

    // For SELL orders, max amount cannot exceed total available
    final tradeType = state.tradeType;
    if (tradeType == 'SELL' && max != null && max > total) {
      dev.log('❌ STEP 4 VALIDATION: Max > Total for SELL order');
      return false;
    }

    // Check available balance for SELL orders
    final availableBalance = amountConfig['availableBalance'] as num?;
    if (tradeType == 'SELL' &&
        availableBalance != null &&
        total > availableBalance) {
      dev.log('❌ STEP 4 VALIDATION: Insufficient balance');
      return false;
    }

    dev.log('✅ STEP 4 VALIDATION: All checks passed');
    return true;
  }

  bool _validateTradeSettingsStep(CreateOfferEditing state) {
    final settings = state.tradeSettings;

    dev.log('🔍 STEP 6 VALIDATION: Checking trade settings step');

    if (settings == null) {
      dev.log('❌ STEP 6 VALIDATION: Missing trade settings');
      return false;
    }

    final termsOfTrade = settings['termsOfTrade']?.toString().trim() ?? '';
    final autoCancel = settings['autoCancel'] as num?;

    dev.log(
        '📊 STEP 6 VALIDATION: terms="$termsOfTrade", autoCancel=$autoCancel');

    if (termsOfTrade.isEmpty) {
      dev.log('❌ STEP 6 VALIDATION: Empty terms of trade');
      return false;
    }

    if (termsOfTrade.length > 500) {
      dev.log('❌ STEP 6 VALIDATION: Terms too long');
      return false;
    }

    if (autoCancel == null || autoCancel <= 0) {
      dev.log('❌ STEP 6 VALIDATION: Invalid auto cancel time');
      return false;
    }

    if (autoCancel > 1440) {
      // 24 hours
      dev.log('❌ STEP 6 VALIDATION: Auto cancel time too long');
      return false;
    }

    dev.log('✅ STEP 6 VALIDATION: All checks passed');
    return true;
  }

  bool _validateUserRequirementsStep(CreateOfferEditing state) {
    final requirements = state.userRequirements;

    dev.log('🔍 STEP 8 VALIDATION: Checking user requirements step');

    // This step is optional, but if data exists, validate it
    if (requirements == null) {
      dev.log('✅ STEP 8 VALIDATION: No requirements set (optional step)');
      return true;
    }

    final minCompletedTrades = requirements['minCompletedTrades'] as num?;
    final minSuccessRate = requirements['minSuccessRate'] as num?;
    final minAccountAge = requirements['minAccountAge'] as num?;

    dev.log(
        '📊 STEP 8 VALIDATION: trades=$minCompletedTrades, rate=$minSuccessRate, age=$minAccountAge');

    if (minCompletedTrades != null) {
      if (minCompletedTrades < 0) {
        dev.log('❌ STEP 8 VALIDATION: Negative completed trades');
        return false;
      }
      if (minCompletedTrades > 1000) {
        dev.log('❌ STEP 8 VALIDATION: Too many required trades');
        return false;
      }
    }

    if (minSuccessRate != null) {
      if (minSuccessRate < 0 || minSuccessRate > 100) {
        dev.log('❌ STEP 8 VALIDATION: Invalid success rate');
        return false;
      }
    }

    if (minAccountAge != null) {
      if (minAccountAge < 0) {
        dev.log('❌ STEP 8 VALIDATION: Negative account age');
        return false;
      }
      if (minAccountAge > 365) {
        dev.log('❌ STEP 8 VALIDATION: Account age too long');
        return false;
      }
    }

    dev.log('✅ STEP 8 VALIDATION: All checks passed');
    return true;
  }

  bool _validateAllSteps(CreateOfferEditing state) {
    // Check all required fields are present
    return state.tradeType != null &&
        state.walletType != null &&
        state.currency != null &&
        state.amountConfig != null &&
        state.priceConfig != null &&
        state.tradeSettings != null &&
        state.locationSettings != null &&
        state.paymentMethodIds != null &&
        state.paymentMethodIds!.isNotEmpty;
  }

  String _getStepTitle(CreateOfferStep step) {
    switch (step) {
      case CreateOfferStep.tradeType:
        return 'Trade Type';
      case CreateOfferStep.walletType:
        return 'Wallet Type';
      case CreateOfferStep.selectCrypto:
        return 'Cryptocurrency';
      case CreateOfferStep.amountPrice:
        return 'Amount & Price';
      case CreateOfferStep.paymentMethods:
        return 'Payment Methods';
      case CreateOfferStep.tradeSettings:
        return 'Trade Settings';
      case CreateOfferStep.locationSettings:
        return 'Location';
      case CreateOfferStep.userRequirements:
        return 'Requirements';
      case CreateOfferStep.review:
        return 'Review & Create';
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Offer Creation?'),
        content: const Text(
          'Are you sure you want to exit? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close wizard
            },
            child: Text(
              'Exit',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
