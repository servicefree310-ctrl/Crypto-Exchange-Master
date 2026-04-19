import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../domain/entities/deposit_gateway_entity.dart';
import '../../bloc/deposit_bloc.dart';
import '../../widgets/deposit/currency_selector.dart';
import '../../widgets/deposit/deposit_methods_list.dart';
import '../../widgets/deposit/amount_input_section.dart';

class FiatDepositPage extends StatefulWidget {
  const FiatDepositPage({super.key});

  @override
  State<FiatDepositPage> createState() => _FiatDepositPageState();
}

class _FiatDepositPageState extends State<FiatDepositPage>
    with TickerProviderStateMixin {
  // State Management
  int _currentStep = 0;
  String? _selectedCurrency;
  String? _selectedMethodId;
  DepositGatewayEntity? _selectedGateway;
  double? _depositAmount;
  Map<String, dynamic> _customFields = {};
  String? _paymentIntentId;

  // Controllers
  final PageController _pageController = PageController();
  late AnimationController _stepAnimationController;
  late AnimationController _fabAnimationController;
  late List<Animation<double>> _stepAnimations;
  late Animation<double> _fabScaleAnimation;

  // Step Configuration
  final List<StepConfig> _steps = [
    StepConfig(
      title: 'Select Currency',
      subtitle: 'Choose your deposit currency',
      icon: Icons.attach_money_rounded,
    ),
    StepConfig(
      title: 'Payment Method',
      subtitle: 'How would you like to deposit?',
      icon: Icons.payment_rounded,
    ),
    StepConfig(
      title: 'Enter Amount',
      subtitle: 'Specify deposit amount',
      icon: Icons.account_balance_wallet_rounded,
    ),
    StepConfig(
      title: 'Confirm & Pay',
      subtitle: 'Review your deposit details',
      icon: Icons.fact_check_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Step animations with staggered effect
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _stepAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.3;
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _stepAnimationController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    // FAB animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _stepAnimationController.forward();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stepAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset animations when page becomes visible again
    if (_stepAnimationController.status == AnimationStatus.completed ||
        _stepAnimationController.status == AnimationStatus.dismissed) {
      _stepAnimationController.reset();
      _stepAnimationController.forward();
    }
  }

  // Navigation Methods
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _fabAnimationController.forward(from: 0);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _fabAnimationController.forward(from: 0);
    }
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedCurrency != null;
      case 1:
        return _selectedMethodId != null;
      case 2:
        return _depositAmount != null && _depositAmount! > 0;
      case 3:
        return true;
      default:
        return false;
    }
  }

  // Action Methods
  void _onCreateDeposit() {
    if (_selectedCurrency != null &&
        _selectedMethodId != null &&
        _depositAmount != null) {
      context.read<DepositBloc>().add(
            FiatDepositCreated(
              currency: _selectedCurrency!,
              amount: _depositAmount!,
              methodId: _selectedMethodId!,
              customFields: _customFields,
            ),
          );
    }
  }

  void _onStripePayment() {
    if (_selectedGateway != null &&
        _depositAmount != null &&
        _selectedCurrency != null) {
      _initiateStripePayment(
          _selectedGateway!, _depositAmount!, _selectedCurrency!);
    }
  }

  void _onStripeGatewaySelected(DepositGatewayEntity gateway) {
    setState(() {
      _selectedMethodId = gateway.id;
      _selectedGateway = gateway;
    });
    _nextStep();
  }

  // Stripe Payment Methods
  Future<void> _initiateStripePayment(
    DepositGatewayEntity gateway,
    double amount,
    String currency,
  ) async {
    try {
      context.read<DepositBloc>().add(
            DepositCreateStripePaymentIntentRequested(
              amount: amount,
              currency: currency,
            ),
          );
    } catch (e) {
      _showErrorSnackBar('Failed to initiate payment: $e');
    }
  }

  Future<void> _presentStripePaymentSheet(String clientSecret) async {
    try {
      dev.log('🔵 STRIPE: Initializing payment sheet with client secret');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppConstants.appName,
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: context.colors.primary,
              background: context.colors.surface,
              componentBackground: context.cardBackground,
              componentBorder: context.borderColor,
              componentDivider: context.borderColor,
              primaryText: context.textPrimary,
              secondaryText: context.textSecondary,
              componentText: context.textPrimary,
              placeholderText: context.textTertiary,
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1,
            ),
          ),
        ),
      );

      dev.log('🔵 STRIPE: Payment sheet initialized, presenting...');
      await Stripe.instance.presentPaymentSheet();
      dev.log('🟢 STRIPE: Payment sheet completed successfully');

      if (_paymentIntentId != null) {
        _showProcessingSnackBar();
        context.read<DepositBloc>().add(
              DepositVerifyStripePaymentRequested(
                paymentIntentId: _paymentIntentId!,
              ),
            );
      }
    } on StripeException catch (e) {
      dev.log('🔴 STRIPE: StripeException: ${e.error.code} - ${e.error.message}');

      if (e.error.code != FailureCode.Canceled) {
        _showErrorSnackBar(
            e.error.localizedMessage ?? e.error.message ?? 'Payment failed');
      }
    } catch (e) {
      dev.log('🔴 STRIPE: Unexpected error: $e');
      _showErrorSnackBar('Payment failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: BlocListener<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositCreated) {
            _showSuccessDialog(state.transaction);
          } else if (state is DepositStripePaymentIntentCreated) {
            _paymentIntentId = state.paymentIntentId;
            _presentStripePaymentSheet(state.clientSecret);
          } else if (state is DepositStripePaymentVerified) {
            _showSuccessDialog(state.transaction);
          } else if (state is DepositError) {
            _showErrorSnackBar(state.failure.message);
          }
        },
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            _buildSliverAppBar(),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Progress Stepper
                  _buildModernProgressStepper(),

                  // Page Content
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.68,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      children: [
                        _buildCurrencySelectionStep(),
                        _buildMethodSelectionStep(),
                        _buildAmountInputStep(),
                        _buildConfirmationStep(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: context.textPrimary,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        title: AnimatedBuilder(
          animation: _stepAnimationController,
          builder: (context, child) {
            return Opacity(
              opacity: _stepAnimations[_currentStep].value.clamp(0.0, 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _steps[_currentStep].title,
                    style: context.bodyL.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _steps[_currentStep].subtitle,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.03),
                context.colors.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: AnimatedBuilder(
              animation: _stepAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _stepAnimations[index].value.clamp(0.0, 1.1),
                  child: Row(
                    children: [
                      // Step Circle
                      GestureDetector(
                        onTap: index < _currentStep
                            ? () {
                                setState(() {
                                  _currentStep = index;
                                });
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                );
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isCurrent ? 36 : 32,
                          height: isCurrent ? 36 : 32,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      context.colors.primary,
                                      context.colors.primary.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isActive
                                ? null
                                : context.borderColor.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: context.colors.primary
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isCompleted
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: isCurrent ? 18 : 16,
                                    )
                                  : Icon(
                                      _steps[index].icon,
                                      color: isActive
                                          ? Colors.white
                                          : context.textTertiary,
                                      size: isCurrent ? 18 : 16,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      // Connection Line
                      if (index < 3)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(1),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          context.borderColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 400),
                                    widthFactor: isCompleted ? 1.0 : 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            context.colors.primary,
                                            context.colors.primary
                                                .withValues(alpha: 0.6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrencySelectionStep() {
    return AnimatedBuilder(
      animation: _stepAnimations[0],
      builder: (context, child) {
        return Opacity(
          opacity: _stepAnimations[0].value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset:
                Offset(0, 20 * (1 - _stepAnimations[0].value.clamp(0.0, 1.0))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary.withValues(alpha: 0.08),
                          context.colors.primary.withValues(alpha: 0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: context.colors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fiat Currency Deposit',
                                style: context.bodyS.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select your preferred fiat currency',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Currency Selector
                  Expanded(
                    child: CurrencySelector(
                      walletType: 'FIAT',
                      selectedCurrency: _selectedCurrency,
                      onCurrencySelected: (currency) {
                        setState(() {
                          _selectedCurrency = currency;
                        });
                        _fabAnimationController.forward(from: 0);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMethodSelectionStep() {
    return AnimatedBuilder(
      animation: _stepAnimations[1],
      builder: (context, child) {
        return Opacity(
          opacity: _stepAnimations[1].value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset:
                Offset(0, 20 * (1 - _stepAnimations[1].value.clamp(0.0, 1.0))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Currency Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.attach_money_rounded,
                            color: context.colors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Depositing: ',
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        Text(
                          _selectedCurrency ?? '',
                          style: context.bodyS.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Method Selection
                  Expanded(
                    child: DepositMethodsList(
                      currency: _selectedCurrency ?? '',
                      selectedMethodId: _selectedMethodId,
                      onMethodSelected: (methodId) {
                        setState(() {
                          _selectedMethodId = methodId;
                        });
                        _fabAnimationController.forward(from: 0);
                      },
                      onStripeGatewaySelected: _onStripeGatewaySelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountInputStep() {
    final isStripe = _selectedGateway?.alias?.toLowerCase() == 'stripe';

    return AnimatedBuilder(
      animation: _stepAnimations[2],
      builder: (context, child) {
        return Opacity(
          opacity: _stepAnimations[2].value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset:
                Offset(0, 20 * (1 - _stepAnimations[2].value.clamp(0.0, 1.0))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                isStripe
                                    ? const Color(0xFF635BFF)
                                    : context.colors.primary,
                                isStripe
                                    ? const Color(0xFF635BFF).withValues(alpha: 0.8)
                                    : context.colors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isStripe
                                ? Icons.credit_card_rounded
                                : Icons.payment_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isStripe ? 'Stripe Payment' : 'Custom Deposit',
                                style: context.bodyS.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isStripe
                                    ? 'Secure payment via Stripe'
                                    : 'Enter deposit amount',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Amount Input
                  Expanded(
                    child: AmountInputSection(
                      currency: _selectedCurrency ?? '',
                      amount: _depositAmount,
                      showCustomFields: !isStripe,
                      gateway: _selectedGateway,
                      onAmountChanged: (amount) {
                        setState(() {
                          _depositAmount = amount;
                        });
                        _fabAnimationController.forward(from: 0);
                      },
                      onCustomFieldsChanged: (fields) {
                        setState(() {
                          _customFields = fields;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationStep() {
    return AnimatedBuilder(
      animation: _stepAnimations[3],
      builder: (context, child) {
        return Opacity(
          opacity: _stepAnimations[3].value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset:
                Offset(0, 20 * (1 - _stepAnimations[3].value.clamp(0.0, 1.0))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.cardBackground,
                          context.cardBackground.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.onSurface.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: context.colors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Deposit Summary',
                              style: context.bodyL.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Details
                        _buildDetailRow(
                          'Currency',
                          _selectedCurrency ?? '',
                          Icons.attach_money_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Amount',
                          '\$${_depositAmount?.toStringAsFixed(2) ?? '0.00'}',
                          Icons.account_balance_wallet_rounded,
                          isHighlighted: true,
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Method',
                          _selectedGateway?.title ?? 'Custom Deposit',
                          Icons.payment_rounded,
                        ),

                        if (_customFields.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.borderColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Additional Information',
                                  style: context.bodyS.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._customFields.entries
                                    .map((entry) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: context.bodyS.copyWith(
                                                  color: context.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                entry.value.toString(),
                                                style: context.bodyS.copyWith(
                                                  color: context.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    ,
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Security Notice
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: context.colors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your transaction is secured with bank-level encryption',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 11,
                              height: 1.3,
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
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? context.colors.primary.withValues(alpha: 0.05)
            : context.borderColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted
              ? context.colors.primary.withValues(alpha: 0.15)
              : context.borderColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                isHighlighted ? context.colors.primary : context.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: context.bodyS.copyWith(
              color:
                  isHighlighted ? context.colors.primary : context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.borderColor.withValues(alpha: 0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: context.borderColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      color: context.textPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back',
                      style: context.bodyS.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 10),

          // Continue/Action Button
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: BlocBuilder<DepositBloc, DepositState>(
              builder: (context, state) {
                final isLoading = state is DepositLoading;
                final isStripe =
                    _selectedGateway?.alias?.toLowerCase() == 'stripe';

                return AnimatedBuilder(
                  animation: _fabScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fabScaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _canContinue() && !isLoading
                              ? LinearGradient(
                                  colors: [
                                    context.colors.primary,
                                    context.colors.primary.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _canContinue() && !isLoading
                              ? [
                                  BoxShadow(
                                    color:
                                        context.colors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: (_canContinue() && !isLoading)
                              ? (_currentStep == 3
                                  ? _onCreateDeposit
                                  : (_currentStep == 2 && isStripe
                                      ? _onStripePayment
                                      : _nextStep))
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canContinue() && !isLoading
                                ? Colors.transparent
                                : context.borderColor.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor:
                                context.borderColor.withValues(alpha: 0.2),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      context.textPrimary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getButtonText(),
                                      style: context.bodyS.copyWith(
                                        color: _canContinue()
                                            ? Colors.white
                                            : context.textTertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _getButtonIcon(),
                                      color: _canContinue()
                                          ? Colors.white
                                          : context.textTertiary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (_currentStep == 3) return 'Confirm Deposit';
    if (_currentStep == 2 &&
        _selectedGateway?.alias?.toLowerCase() == 'stripe') {
      return 'Pay with Stripe';
    }
    return 'Continue';
  }

  IconData _getButtonIcon() {
    if (_currentStep == 3) return Icons.check_rounded;
    if (_currentStep == 2 &&
        _selectedGateway?.alias?.toLowerCase() == 'stripe') {
      return Icons.credit_card_rounded;
    }
    return Icons.arrow_forward_rounded;
  }

  void _showSuccessDialog(dynamic transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.priceUpColor,
                      context.priceUpColor.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Deposit Successful!',
                style: context.bodyL.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                'Your deposit has been processed successfully and will be credited to your account shortly.',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: context.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.priceDownColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: context.priceDownColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: context.bodyM.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showProcessingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.warningColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Verifying payment...',
              style: context.bodyM.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Step Configuration Model
class StepConfig {
  final String title;
  final String subtitle;
  final IconData icon;

  const StepConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
