import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/spot_deposit_bloc.dart';
import '../bloc/spot_deposit_event.dart';
import '../bloc/spot_deposit_state.dart';
import '../widgets/spot_deposit/spot_currency_selector.dart';
import '../widgets/spot_deposit/spot_network_selector.dart';
import '../widgets/spot_deposit/spot_deposit_address_widget.dart';
import '../widgets/spot_deposit/spot_deposit_verification.dart';

class SpotDepositPage extends StatefulWidget {
  const SpotDepositPage({super.key});

  @override
  State<SpotDepositPage> createState() => _SpotDepositPageState();
}

class _SpotDepositPageState extends State<SpotDepositPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _stepAnimationController;
  late AnimationController _fabAnimationController;
  late List<Animation<double>> _stepAnimations;
  late Animation<double> _fabScaleAnimation;

  int _currentStep = 0;
  String? _selectedCurrency;
  String? _selectedNetwork;
  String? _depositAddress;
  String? _transactionId;

  // Step configuration
  final List<StepConfig> _steps = const [
    StepConfig(
      title: 'Select Currency',
      subtitle: 'Choose cryptocurrency',
      icon: Icons.currency_bitcoin_rounded,
    ),
    StepConfig(
      title: 'Select Network',
      subtitle: 'Choose blockchain network',
      icon: Icons.hub_rounded,
    ),
    StepConfig(
      title: 'Deposit Address',
      subtitle: 'Get your deposit address',
      icon: Icons.qr_code_2_rounded,
    ),
    StepConfig(
      title: 'Verification',
      subtitle: 'Confirm your transaction',
      icon: Icons.verified_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _initializeAnimations();

    // Request currencies when page opens
    context.read<SpotDepositBloc>().add(const SpotCurrenciesRequested());

    // Start animations
    _stepAnimationController.forward();
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

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      _stepAnimationController.forward(from: 0.7);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _selectedCurrency = null;
      _selectedNetwork = null;
      _depositAddress = null;
      _transactionId = null;
    });
    _pageController.jumpToPage(0);
    context.read<SpotDepositBloc>().add(const SpotDepositReset());
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedCurrency != null;
      case 1:
        return _selectedNetwork != null;
      case 2:
        return _depositAddress != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: BlocConsumer<SpotDepositBloc, SpotDepositState>(
        listener: (context, state) {
          if (state is SpotNetworksLoaded && _currentStep == 0) {
            // Move to network selection step when networks are loaded
            _nextStep();
          } else if (state is SpotDepositAddressGenerated &&
              _currentStep == 1) {
            // Store address and move to address display step
            setState(() {
              _depositAddress = state.address.address;
            });
            _nextStep();
          } else if (state is SpotDepositTransactionCreated &&
              _currentStep == 2) {
            // Start verification process and move to verification step
            // Backend looks up transaction by referenceId (blockchain tx hash), not by internal DB id
            _transactionId = state.transaction.referenceId;
            context.read<SpotDepositBloc>().add(
                  SpotDepositVerificationStarted(state.transaction.referenceId),
                );
            _nextStep();
          } else if (state is SpotDepositVerified) {
            // Show success dialog
            _showSuccessDialog();
          } else if (state is SpotDepositError) {
            _showErrorSnackBar(state.failure.message);
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Modern App Bar
              _buildSliverAppBar(),

              // Progress Stepper
              SliverToBoxAdapter(
                child: _buildCompactProgressStepper(),
              ),

              // Page Content fills remaining space
              SliverFillRemaining(
                hasScrollBody: true,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildCurrencySelectionStep(state),
                    _buildNetworkSelectionStep(state),
                    _buildDepositAddressStep(state),
                    _buildVerificationStep(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
                Colors.blue.withValues(alpha: 0.03),
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

  Widget _buildCompactProgressStepper() {
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
                                      Colors.blue,
                                      Colors.blue.withValues(alpha: 0.8),
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
                                      color: Colors.blue.withValues(alpha: 0.2),
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
                                            Colors.blue,
                                            Colors.blue.withValues(alpha: 0.6),
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

  Widget _buildCurrencySelectionStep(SpotDepositState state) {
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
                          Colors.blue.withValues(alpha: 0.08),
                          Colors.blue.withValues(alpha: 0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cryptocurrency Deposit',
                                style: context.bodyS.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select the cryptocurrency to deposit',
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
                    child: state is SpotDepositLoading && _currentStep == 0
                        ? const Center(child: LoadingWidget())
                        : SpotCurrencySelector(
                            onCurrencySelected: (currency) {
                              setState(() {
                                _selectedCurrency = currency;
                              });
                              _fabAnimationController.forward(from: 0);
                              context.read<SpotDepositBloc>().add(
                                    SpotNetworksRequested(currency),
                                  );
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

  Widget _buildNetworkSelectionStep(SpotDepositState state) {
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
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.currency_bitcoin_rounded,
                            color: Colors.blue,
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

                  // Network Selection
                  Expanded(
                    child: state is SpotDepositLoading && _currentStep == 1
                        ? const Center(child: LoadingWidget())
                        : SpotNetworkSelector(
                            currency: _selectedCurrency!,
                            onNetworkSelected: (network) {
                              setState(() {
                                _selectedNetwork = network;
                              });
                              _fabAnimationController.forward(from: 0);
                              context.read<SpotDepositBloc>().add(
                                    SpotDepositAddressRequested(
                                      _selectedCurrency!,
                                      network,
                                    ),
                                  );
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

  Widget _buildDepositAddressStep(SpotDepositState state) {
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
              child: state is SpotDepositLoading && _currentStep == 2
                  ? const Center(child: LoadingWidget())
                  : SpotDepositAddressWidget(
                      currency: _selectedCurrency!,
                      network: _selectedNetwork!,
                      onContinue: () {
                        _fabAnimationController.forward(from: 0);
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationStep(SpotDepositState state) {
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
              child: SpotDepositVerification(
                transactionId: _transactionId,
                currency: _selectedCurrency!,
                network: _selectedNetwork!,
                onComplete: _reset,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                'Your cryptocurrency deposit has been verified and credited to your account.',
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
                    backgroundColor: Colors.blue,
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
