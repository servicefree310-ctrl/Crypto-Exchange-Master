import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../injection/injection.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/countdown_timer.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/eco_token_entity.dart';
import '../../domain/entities/eco_deposit_address_entity.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';
import '../bloc/eco_deposit_bloc.dart';
import '../bloc/eco_deposit_event.dart';
import '../bloc/eco_deposit_state.dart';

class EcoDepositPage extends StatefulWidget {
  const EcoDepositPage({super.key});

  @override
  State<EcoDepositPage> createState() => _EcoDepositPageState();
}

class _EcoDepositPageState extends State<EcoDepositPage>
    with TickerProviderStateMixin {
  // State Management
  int _currentStep = 0;
  String? _selectedCurrency;
  EcoTokenEntity? _selectedToken;
  EcoDepositAddressEntity? _depositAddress;
  bool _isMonitoring = false;

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
      subtitle: 'Choose ECO currency',
      icon: Icons.eco_rounded,
    ),
    StepConfig(
      title: 'Select Token',
      subtitle: 'Choose blockchain network',
      icon: Icons.token_rounded,
    ),
    StepConfig(
      title: 'Deposit Address',
      subtitle: 'Get your ECO deposit address',
      icon: Icons.qr_code_2_rounded,
    ),
    StepConfig(
      title: 'Monitoring',
      subtitle: 'Tracking your deposit',
      icon: Icons.track_changes_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Request currencies when page opens
    context.read<EcoDepositBloc>().add(const EcoDepositCurrenciesRequested());
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
    context.read<EcoDepositBloc>().add(const EcoDepositReset());
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
        return _selectedToken != null;
      case 2:
        return _depositAddress != null;
      case 3:
        return true; // Always can continue from monitoring
      default:
        return false;
    }
  }

  // Reset the flow
  void _reset() {
    setState(() {
      _currentStep = 0;
      _selectedCurrency = null;
      _selectedToken = null;
      _depositAddress = null;
      _isMonitoring = false;
    });
    _pageController.jumpToPage(0);
    context.read<EcoDepositBloc>().add(const EcoDepositReset());
    context.read<EcoDepositBloc>().add(const EcoDepositCurrenciesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<EcoDepositBloc>()..add(const EcoDepositCurrenciesRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: BlocConsumer<EcoDepositBloc, EcoDepositState>(
          listener: (context, state) {
            if (state is EcoTokensLoaded && _currentStep == 0) {
              // Move to token selection when tokens are loaded
              _nextStep();
            } else if (state is EcoAddressGenerated && _currentStep == 1) {
              // Store address and move to address display step
              setState(() {
                _depositAddress = state.address;
              });
              _nextStep();
            } else if (state is EcoDepositMonitoring && _currentStep == 2) {
              // Move to monitoring step
              setState(() {
                _isMonitoring = true;
              });
              _nextStep();
            } else if (state is EcoDepositVerified) {
              // Show success dialog
              _showSuccessDialog(state.verification, state.newBalance);
            } else if (state is EcoDepositTimeout) {
              // Show timeout dialog
              _showTimeoutDialog(state.contractType, state.timeoutMessage);
            } else if (state is EcoDepositError) {
              _showErrorSnackBar(state.displayMessage);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // Modern App Bar
                _buildSliverAppBar(),

                // Progress Stepper
                SliverToBoxAdapter(
                  child: _buildModernProgressStepper(),
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
                      _buildTokenSelectionStep(state),
                      _buildAddressDisplayStep(state),
                      _buildMonitoringStep(state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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
                Colors.purple.withValues(alpha: 0.03),
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
                                      Colors.purple,
                                      Colors.purple.withValues(alpha: 0.8),
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
                                      color: Colors.purple.withValues(alpha: 0.2),
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
                                            Colors.purple,
                                            Colors.purple.withValues(alpha: 0.6),
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

  Widget _buildCurrencySelectionStep(EcoDepositState state) {
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
                          Colors.purple.withValues(alpha: 0.08),
                          Colors.purple.withValues(alpha: 0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.purple,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ECO Token Deposit',
                                style: context.bodyS.copyWith(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select your ECO currency to deposit',
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

                  // Currency List
                  Expanded(
                    child: state is EcoDepositLoading && _currentStep == 0
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.purple,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message ?? 'Loading currencies...',
                                  style: context.bodyM.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : state is EcoCurrenciesLoaded
                            ? ListView.builder(
                                itemCount: state.currencies.length,
                                itemBuilder: (context, index) {
                                  final currency = state.currencies[index];
                                  final isSelected =
                                      _selectedCurrency == currency;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                Colors.purple.withValues(alpha: 0.1),
                                                Colors.purple.withValues(alpha: 0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : context.cardBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.purple.withValues(alpha: 0.3)
                                            : context.borderColor
                                                .withValues(alpha: 0.2),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          _selectedCurrency = currency;
                                        });
                                        _fabAnimationController.forward(
                                            from: 0);
                                        context.read<EcoDepositBloc>().add(
                                              EcoDepositTokensRequested(
                                                  currency: currency),
                                            );
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: context.borderColor
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            currency
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: context.bodyL.copyWith(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        currency.toUpperCase(),
                                        style: context.bodyL.copyWith(
                                          color: context.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'ECO Token: $currency',
                                        style: context.bodyS.copyWith(
                                          color: context.textTertiary,
                                        ),
                                      ),
                                      trailing: Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.arrow_forward_ios_rounded,
                                        color: isSelected
                                            ? Colors.purple
                                            : context.textTertiary,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No currencies available',
                                  style: context.bodyM.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
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

  Widget _buildTokenSelectionStep(EcoDepositState state) {
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
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.purple,
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
                          _selectedCurrency?.toUpperCase() ?? '',
                          style: context.bodyS.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Token List
                  Expanded(
                    child: state is EcoDepositLoading && _currentStep == 1
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.purple,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message ?? 'Loading tokens...',
                                  style: context.bodyM.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : state is EcoTokensLoaded
                            ? ListView.builder(
                                itemCount: state.tokens.length,
                                itemBuilder: (context, index) {
                                  final token = state.tokens[index];
                                  final isSelected = _selectedToken == token;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                Colors.purple.withValues(alpha: 0.1),
                                                Colors.purple.withValues(alpha: 0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : context.cardBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.purple.withValues(alpha: 0.3)
                                            : context.borderColor
                                                .withValues(alpha: 0.2),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          _selectedToken = token;
                                        });
                                        _fabAnimationController.forward(
                                            from: 0);
                                        context.read<EcoDepositBloc>().add(
                                              EcoDepositAddressRequested(
                                                currency: _selectedCurrency!,
                                                chain: token.chain,
                                                contractType:
                                                    token.contractType,
                                                token: token,
                                              ),
                                            );
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      leading: token.icon.isNotEmpty
                                          ? Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    token.icon
                                                            .startsWith('http')
                                                        ? token.icon
                                                        : '${ApiConstants.baseUrl}${token.icon}',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: context.borderColor
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.token_rounded,
                                                color: Colors.purple,
                                                size: 24,
                                              ),
                                            ),
                                      title: Text(
                                        '${token.name} (${token.chain})',
                                        style: context.bodyL.copyWith(
                                          color: context.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              _buildContractTypeChip(
                                                  token.contractType),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Min: ${token.limits.deposit.min}',
                                                style: context.bodyS.copyWith(
                                                  color: context.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Max: ${token.limits.deposit.max}',
                                            style: context.bodyS.copyWith(
                                              color: context.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.arrow_forward_ios_rounded,
                                        color: isSelected
                                            ? Colors.purple
                                            : context.textTertiary,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No tokens available',
                                  style: context.bodyM.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
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

  Widget _buildAddressDisplayStep(EcoDepositState state) {
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
              child: state is EcoDepositLoading && _currentStep == 2
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message ?? 'Generating address...',
                            style: context.bodyM.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _depositAddress != null
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              // QR Code Container
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.colors.onSurface
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    QrImageView(
                                      data: _depositAddress!.address,
                                      version: QrVersions.auto,
                                      size: 200.0,
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Scan to deposit',
                                      style: context.bodyS.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Address Container
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.borderColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Deposit Address',
                                          style: context.bodyL.copyWith(
                                            color: context.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                  text:
                                                      _depositAddress!.address),
                                            );
                                            _showSuccessSnackBar(
                                                'Address copied to clipboard');
                                          },
                                          icon: Icon(
                                            Icons.copy_rounded,
                                            color: Colors.purple,
                                            size: 20,
                                          ),
                                          tooltip: 'Copy address',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      _depositAddress!.address,
                                      style: context.bodyS.copyWith(
                                        fontFamily: 'monospace',
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Token Info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.withValues(alpha: 0.05),
                                      Colors.purple.withValues(alpha: 0.02),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.purple.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      'Token',
                                      '${_selectedToken?.name} (${_selectedToken?.chain})',
                                      Icons.token_rounded,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildInfoRow(
                                      'Contract Type',
                                      _selectedToken?.contractType ?? '',
                                      Icons.description_rounded,
                                    ),
                                    if (_selectedToken?.network != null) ...[
                                      const SizedBox(height: 10),
                                      _buildInfoRow(
                                        'Network',
                                        _selectedToken!.network!,
                                        Icons.hub_rounded,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Warning for NO_PERMIT
                              if (_depositAddress!.locked) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        context.warningColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          context.warningColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_rounded,
                                        color: context.warningColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'This is a NO_PERMIT address. It will be unlocked automatically after deposit.',
                                          style: context.bodyS.copyWith(
                                            color: context.warningColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Start Monitoring Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<EcoDepositBloc>().add(
                                          EcoDepositMonitoringStarted(
                                            currency: _selectedCurrency!,
                                            chain: _selectedToken!.chain,
                                            address: _depositAddress!.address,
                                            contractType:
                                                _selectedToken!.contractType,
                                          ),
                                        );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Start Monitoring',
                                        style: context.bodyM.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.track_changes_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'No address generated',
                            style: context.bodyM.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonitoringStep(EcoDepositState state) {
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
              child: state is EcoDepositMonitoring
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          // Countdown Timer
                          CountdownTimer(
                            initialTimeInSeconds:
                                state.contractType == 'NO_PERMIT' ? 120 : 600,
                            onExpire: () {
                              context.read<EcoDepositBloc>().add(
                                    const EcoDepositMonitoringStopped(),
                                  );
                            },
                          ),
                          const SizedBox(height: 24),

                          // QR Code Container (white background for visibility)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: state.address,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scan with your wallet app',
                                  style: context.bodyS.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Address Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.borderColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Deposit Address',
                                      style: context.h6.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: state.address));
                                        _showSuccessSnackBar(
                                            'Address copied to clipboard');
                                      },
                                      icon: Icon(
                                        Icons.copy,
                                        color: Colors.purple,
                                      ),
                                      tooltip: 'Copy address',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  state.address,
                                  style: context.bodyS.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Monitoring Status Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withValues(alpha: 0.08),
                                  Colors.purple.withValues(alpha: 0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.purple.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.purple,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Monitoring Deposit',
                                      style: context.h6.copyWith(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Waiting for ${state.currency} deposit on ${state.chain} network...',
                                  style: context.bodyS.copyWith(
                                    color: context.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getContractTypeColor(
                                            state.contractType)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Contract Type: ${state.contractType}',
                                    style: context.bodyS.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Contract Type Warning
                          if (state.contractType == 'NO_PERMIT') ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.warningColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.warningColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: context.warningColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Important: NO_PERMIT Address',
                                        style: context.h6.copyWith(
                                          color: context.warningColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This is a temporary custodial address that will be unlocked automatically after deposit confirmation.',
                                    style: context.bodyS.copyWith(
                                      color:
                                          context.warningColor.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<EcoDepositBloc>().add(
                                          const EcoDepositMonitoringStopped(),
                                        );
                                    _reset();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(
                                      color:
                                          context.borderColor.withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.stop,
                                          color: context.textPrimary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Stop Monitoring',
                                        style: context.labelL.copyWith(
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Share functionality
                                    _showSuccessSnackBar(
                                        'Share feature coming soon!');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Share Address',
                                        style: context.labelL.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.share,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        'Monitoring not active',
                        style: context.bodyM.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContractTypeChip(String contractType) {
    final color = _getContractTypeColor(contractType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        contractType,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getContractTypeColor(String contractType) {
    switch (contractType) {
      case 'PERMIT':
        return Colors.purple;
      case 'NO_PERMIT':
        return context.warningColor;
      case 'NATIVE':
        return Colors.purple;
      default:
        return context.textSecondary;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.purple,
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
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(
      EcoDepositVerificationEntity verification, double newBalance) {
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
                      Colors.purple,
                      Colors.purple.withValues(alpha: 0.8),
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
                'Your ECO deposit has been verified and credited to your account.',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.borderColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Amount',
                      '${verification.transaction?.amount ?? 0} ${verification.currency ?? ''}',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'New Balance',
                      '$newBalance ${verification.currency ?? ''}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    _reset(); // Reset the flow
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'New Deposit',
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyS.copyWith(
            color: context.textSecondary,
          ),
        ),
        Text(
          value,
          style: context.bodyS.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showTimeoutDialog(String contractType, String message) {
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
              // Timeout Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.warningColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: context.warningColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Monitoring Timeout',
                style: context.bodyL.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                message,
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
                    _reset(); // Reset the flow
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Try Again',
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
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
