import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/withdraw_bloc.dart';
import '../bloc/withdraw_event.dart';
import '../bloc/withdraw_state.dart';
import '../widgets/withdraw_step_indicator.dart';
import '../widgets/wallet_type_selector.dart';
import '../widgets/currency_selector.dart';
import '../widgets/withdraw_method_selector.dart';
import '../widgets/withdraw_amount_input.dart';
import '../widgets/withdraw_success.dart';

class WithdrawPage extends StatelessWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<WithdrawBloc>()..add(const WithdrawInitialized()),
      child: const WithdrawView(),
    );
  }
}

class WithdrawView extends StatefulWidget {
  const WithdrawView({super.key});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildAppBar(context),
              ),
            ),

            // Main Content
            Expanded(
              child: BlocBuilder<WithdrawBloc, WithdrawState>(
                builder: (context, state) {
                  if (state is WithdrawInitial) {
                    return const LoadingWidget();
                  }

                  if (state is WithdrawLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is WithdrawError) {
                    // Check if it's the specific "no wallets" error
                    if (state.failure.message
                        .contains('No wallets with balance')) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color:
                                    context.colors.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Withdrawable Balance',
                                style: context.h5,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You don\'t have any balance available for withdrawal. Please deposit funds first.',
                                style: context.bodyM.copyWith(
                                  color:
                                      context.colors.onSurface.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Go Back'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.failure.message}',
                            style: context.bodyL,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<WithdrawBloc>()
                                  .add(const WithdrawInitialized());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is WithdrawSuccess) {
                    return WithdrawSuccessWidget(response: state.response);
                  }

                  if (state is WalletTypesLoaded) {
                    // If no wallet types have balance, show empty state
                    if (state.walletTypes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color:
                                    context.colors.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Withdrawable Balance',
                                style: context.h5,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You don\'t have any balance available for withdrawal. Please deposit funds first.',
                                style: context.bodyM.copyWith(
                                  color:
                                      context.colors.onSurface.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Go Back'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: WithdrawStepIndicator(
                              currentStep: state.currentStep,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.borderColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: WalletTypeSelectorWidget(
                                walletTypes: state.walletTypes,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      // Step indicator
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: WithdrawStepIndicator(
                            currentStep: _getCurrentStep(state),
                          ),
                        ),
                      ),

                      // Main content area
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey(state.runtimeType),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.borderColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.isDarkMode
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildCurrentStep(context, state),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? context.colors.surface
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: context.textPrimary,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              'Withdraw Funds',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Action buttons
          BlocBuilder<WithdrawBloc, WithdrawState>(
            builder: (context, state) {
              if (state is WithdrawSuccess) return const SizedBox.shrink();

              return Row(
                children: [
                  // Help button
                  GestureDetector(
                    onTap: () => _showHelpDialog(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: context.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<WithdrawBloc>().add(const WithdrawReset());
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: context.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: context.colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Withdrawal Help',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '• Withdrawal fees vary by method and currency\n'
                  '• Processing time depends on the network\n'
                  '• Ensure withdrawal address is correct\n'
                  '• Minimum and maximum limits apply',
                  style: context.bodyM.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: context.buttonText(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getCurrentStep(WithdrawState state) {
    if (state is WalletTypesLoaded) return 1;
    if (state is CurrenciesLoaded) return 2;
    if (state is WithdrawMethodsLoaded) return 3;
    if (state is WithdrawAmountReady) return 4;
    if (state is WithdrawSubmitting) return 4;
    return 1;
  }

  Widget _buildCurrentStep(BuildContext context, WithdrawState state) {
    if (state is WalletTypesLoaded) {
      return WalletTypeSelectorWidget(walletTypes: state.walletTypes);
    }

    if (state is CurrenciesLoaded) {
      return CurrencySelectorWidget(
        walletType: state.selectedWalletType,
        currencies: state.currencies,
      );
    }

    if (state is WithdrawMethodsLoaded) {
      return WithdrawMethodSelectorWidget(
        walletType: state.selectedWalletType,
        currency: state.selectedCurrency,
        availableBalance: state.availableBalance,
        methods: state.methods,
        selectedMethodId: state.selectedMethodId,
        selectedMethod: state.selectedMethod,
        customFieldValues: state.customFieldValues,
      );
    }

    if (state is WithdrawAmountReady) {
      return WithdrawAmountInputWidget(
        walletType: state.selectedWalletType,
        currency: state.selectedCurrency,
        availableBalance: state.availableBalance,
        selectedMethod: state.selectedMethod,
        amount: state.amount,
        withdrawAmount: state.withdrawAmount,
        fee: state.fee,
        netAmount: state.netAmount,
        isValidAmount: state.isValidAmount,
        errorMessage: state.errorMessage,
      );
    }

    if (state is WithdrawSubmitting) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Processing Withdrawal',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we process your withdrawal request',
              style: context.bodyS.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
