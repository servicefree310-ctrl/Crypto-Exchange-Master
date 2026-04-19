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
import '../bloc/futures_deposit_bloc.dart';
import '../bloc/futures_deposit_event.dart';
import '../bloc/futures_deposit_state.dart';

class FuturesDepositPage extends StatefulWidget {
  const FuturesDepositPage({super.key});

  @override
  State<FuturesDepositPage> createState() => _FuturesDepositPageState();
}

class _FuturesDepositPageState extends State<FuturesDepositPage>
    with TickerProviderStateMixin {
  // State Management
  int _currentStep = 0;
  String? _selectedCurrency;
  EcoTokenEntity? _selectedToken;
  EcoDepositAddressEntity? _depositAddress;

  // Controllers
  final PageController _pageController = PageController();
  late AnimationController _stepAnimationController;
  late List<Animation<double>> _stepAnimations;
  late Animation<double> _fadeAnimation;

  // Step Configuration
  final List<StepConfig> _steps = [
    StepConfig(
      title: 'Select Currency',
      subtitle: 'Choose futures currency',
      icon: Icons.currency_exchange_rounded,
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
      title: 'Monitoring',
      subtitle: 'Tracking your deposit',
      icon: Icons.track_changes_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeIn,
    ));

    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stepAnimationController.dispose();
    context.read<FuturesDepositBloc>().add(const FuturesDepositReset());
    super.dispose();
  }

  void _navigateToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _selectedCurrency = null;
      _selectedToken = null;
      _depositAddress = null;
    });
    _pageController.jumpToPage(0);
    context.read<FuturesDepositBloc>().add(const FuturesDepositReset());
    context
        .read<FuturesDepositBloc>()
        .add(const FuturesDepositCurrenciesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FuturesDepositBloc>()
        ..add(const FuturesDepositCurrenciesRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: BlocListener<FuturesDepositBloc, FuturesDepositState>(
          listener: (context, state) {
            if (state is FuturesDepositTokensLoaded && _currentStep == 0) {
              setState(() {
                _selectedCurrency = state.selectedCurrency;
              });
              _navigateToStep(1);
            } else if (state is FuturesDepositAddressGenerated &&
                _currentStep == 1) {
              setState(() {
                _depositAddress = state.address;
              });
              _navigateToStep(2);
            } else if (state is FuturesDepositMonitoring && _currentStep == 2) {
              _navigateToStep(3);
            } else if (state is FuturesDepositCompleted) {
              _showSuccessDialog(
                  state.verification, state.currency, state.chain);
            }
          },
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              // Progress stepper as a fixed sliver
              SliverToBoxAdapter(
                child: _buildModernProgressStepper(),
              ),

              // PageView fills the remaining space
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
                    _buildCurrencySelectionStep(),
                    _buildTokenSelectionStep(),
                    _buildAddressDisplayStep(),
                    _buildMonitoringStep(),
                  ],
                ),
              ),
            ],
          ),
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
                Colors.orange.withValues(alpha: 0.03),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCurrent ? 36 : 32,
                        height: isCurrent ? 36 : 32,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(
                                  colors: [
                                    Colors.orange,
                                    Colors.orange.withValues(alpha: 0.8),
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
                                    color: Colors.orange.withValues(alpha: 0.2),
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
                                            Colors.orange,
                                            Colors.orange.withValues(alpha: 0.6),
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
    return BlocBuilder<FuturesDepositBloc, FuturesDepositState>(
      builder: (context, state) {
        if (state is FuturesDepositLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.orange,
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
          );
        }

        if (state is FuturesDepositCurrenciesLoaded) {
          final currencies = state.currencies.map((t) => t.currency).toList();

          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
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
                                Colors.orange.withValues(alpha: 0.08),
                                Colors.orange.withValues(alpha: 0.03),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Futures Deposit',
                                      style: context.bodyS.copyWith(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Select your futures currency to deposit',
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
                          child: ListView.builder(
                            itemCount: currencies.length,
                            itemBuilder: (context, index) {
                              final currency = currencies[index];

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.borderColor.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      context.read<FuturesDepositBloc>().add(
                                            FuturesDepositTokensRequested(
                                                currency: currency),
                                          );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
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
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  currency.toUpperCase(),
                                                  style: context.bodyL.copyWith(
                                                    color: context.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  'Futures Token: $currency',
                                                  style: context.bodyS.copyWith(
                                                    color: context.textTertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: context.textTertiary,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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

        return const Center(child: Text('No currencies available'));
      },
    );
  }

  Widget _buildTokenSelectionStep() {
    return BlocBuilder<FuturesDepositBloc, FuturesDepositState>(
      builder: (context, state) {
        if (state is FuturesDepositLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.orange,
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
          );
        }

        if (state is FuturesDepositTokensLoaded) {
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
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
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.currency_exchange_rounded,
                                  color: Colors.orange,
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
                          child: ListView.builder(
                            itemCount: state.tokens.length,
                            itemBuilder: (context, index) {
                              final token = state.tokens[index];

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.borderColor.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setState(() {
                                        _selectedToken = token;
                                      });
                                      context.read<FuturesDepositBloc>().add(
                                            FuturesDepositAddressRequested(
                                              currency: state.selectedCurrency,
                                              chain: token.chain,
                                              contractType: token.contractType,
                                            ),
                                          );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          token.icon.isNotEmpty
                                              ? Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        token.icon.startsWith(
                                                                'http')
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
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.token_rounded,
                                                    color: Colors.orange,
                                                    size: 24,
                                                  ),
                                                ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${token.name} (${token.chain})',
                                                  style: context.bodyL.copyWith(
                                                    color: context.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _buildContractTypeChip(
                                                        token.contractType),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Min: ${token.limits.deposit.min}',
                                                      style: context.bodyS
                                                          .copyWith(
                                                        color: context
                                                            .textTertiary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: context.textTertiary,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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

        return const Center(child: Text('No tokens available'));
      },
    );
  }

  Widget _buildAddressDisplayStep() {
    return BlocBuilder<FuturesDepositBloc, FuturesDepositState>(
      builder: (context, state) {
        if (state is FuturesDepositLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.orange,
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
          );
        }

        if (state is FuturesDepositAddressGenerated) {
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
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
                                  data: state.address.address,
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
                                              text: state.address.address),
                                        );
                                        _showSuccessSnackBar(
                                            'Address copied to clipboard');
                                      },
                                      icon: Icon(
                                        Icons.copy_rounded,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      tooltip: 'Copy address',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  state.address.address,
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
                                  Colors.orange.withValues(alpha: 0.05),
                                  Colors.orange.withValues(alpha: 0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.15),
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
                                  state.contractType,
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

                          const SizedBox(height: 20),

                          // Start Monitoring Button - Auto navigates
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<FuturesDepositBloc>().add(
                                      FuturesDepositMonitoringStarted(
                                        currency: state.selectedCurrency,
                                        chain: state.selectedChain,
                                        address: state.address.address,
                                        contractType: state.contractType,
                                      ),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('No address generated'));
      },
    );
  }

  Widget _buildMonitoringStep() {
    return BlocBuilder<FuturesDepositBloc, FuturesDepositState>(
      builder: (context, state) {
        if (state is FuturesDepositMonitoring) {
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Countdown Timer
                          CountdownTimer(
                            initialTimeInSeconds:
                                state.contractType == 'NO_PERMIT' ? 120 : 600,
                            onExpire: () {
                              context.read<FuturesDepositBloc>().add(
                                    const FuturesDepositReset(),
                                  );
                            },
                          ),
                          const SizedBox(height: 24),

                          // QR Code Container
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

                          // Monitoring Status Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withValues(alpha: 0.08),
                                  Colors.orange.withValues(alpha: 0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.2),
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
                                          Colors.orange,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Monitoring Deposit',
                                      style: context.h6.copyWith(
                                        color: Colors.orange,
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
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<FuturesDepositBloc>().add(
                                          const FuturesDepositReset(),
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
                                  onPressed: _reset,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
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
                                        'New Deposit',
                                        style: context.labelL.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.add_rounded,
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
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('Monitoring not active'));
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
        return Colors.orange;
      case 'NO_PERMIT':
        return context.warningColor;
      case 'NATIVE':
        return Colors.orange;
      default:
        return context.textSecondary;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.orange,
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
    EcoDepositVerificationEntity verification,
    String currency,
    String chain,
  ) {
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
                      Colors.orange,
                      Colors.orange.withValues(alpha: 0.8),
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
                'Your futures deposit has been verified and credited to your account.',
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
                      'Currency',
                      currency.toUpperCase(),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Network',
                      chain,
                    ),
                    ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Transaction',
                      '${verification.transactionHash.substring(0, 10)}...',
                    ),
                  ],
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
                    Navigator.of(context).pop(); // Return to main page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.orange,
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
