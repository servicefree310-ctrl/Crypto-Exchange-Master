import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as core_widgets;
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import '../widgets/transfer_step_indicator.dart';
import '../widgets/transfer_type_selector.dart';
import '../widgets/source_wallet_selector.dart';
import '../widgets/destination_selector.dart';
import '../widgets/transfer_amount_input.dart';
import '../widgets/transfer_success.dart';
import '../widgets/recipient_input.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<TransferBloc>()..add(const TransferInitialized()),
      child: const TransferView(),
    );
  }
}

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView>
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
            // Custom App Bar with animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildAppBar(context),
              ),
            ),

            // Main Content
            Expanded(
              child: BlocBuilder<TransferBloc, TransferState>(
                builder: (context, state) {
                  if (state is TransferInitial || state is TransferLoading) {
                    return const LoadingWidget();
                  }

                  if (state is TransferError) {
                    return core_widgets.ErrorWidget(
                      message: state.failure.message,
                      onRetry: () {
                        context
                            .read<TransferBloc>()
                            .add(const TransferInitialized());
                      },
                    );
                  }

                  if (state is TransferSuccess) {
                    return TransferSuccessWidget(response: state.response);
                  }

                  return Column(
                    children: [
                      // Step indicator with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: TransferStepIndicator(
                            currentStep: _getCurrentStep(state),
                          ),
                        ),
                      ),

                      // Main content area with animation
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
          // Back button with custom design
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
              'Transfer Funds',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Action buttons
          BlocBuilder<TransferBloc, TransferState>(
            builder: (context, state) {
              if (state is TransferSuccess) return const SizedBox.shrink();

              return Row(
                children: [
                  // Help button
                  GestureDetector(
                    onTap: () {
                      _showHelpDialog(context);
                    },
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
                      context.read<TransferBloc>().add(const TransferReset());
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
                        'Transfer Help',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '• Wallet transfers are free and instant\n'
                  '• User transfers include a 1% fee\n'
                  '• Minimum transfer amount varies by currency\n'
                  '• All transfers are processed securely',
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

  int _getCurrentStep(TransferState state) {
    if (state is TransferOptionsLoaded) return 1;
    if (state is TransferTypeSelectedState) return 2;
    if (state is SourceWalletReady) return 3;
    if (state is SourceCurrencySelectedState) return 4;
    if (state is ClientRecipientValidatedState) return 4;
    if (state is DestinationWalletSelectedState) return 5;
    if (state is TransferReadyToSubmit) {
      final transferType = state.transferType;
      return transferType == 'client' ? 5 : 6;
    }
    if (state is TransferSubmitting) {
      return 6;
    }
    return 1;
  }

  Widget _buildCurrentStep(BuildContext context, TransferState state) {
    if (state is TransferOptionsLoaded) {
      return TransferTypeSelectorWidget(walletTypes: state.walletTypes);
    }

    if (state is TransferTypeSelectedState) {
      return SourceWalletSelectorWidget(
        walletTypes: state.walletTypes,
        transferType: state.transferType,
      );
    }

    if (state is SourceWalletReady) {
      return SourceWalletSelectorWidget(
        walletTypes: state.walletTypes,
        transferType: state.transferType,
        selectedWalletType: state.sourceWalletType,
        currencies: state.sourceCurrencies,
      );
    }

    if (state is SourceCurrencySelectedState) {
      // For client transfers, show recipient input directly
      if (state.transferType == 'client') {
        return RecipientInputWidget(
          sourceCurrency: state.sourceCurrency,
          availableBalance: state.availableBalance,
        );
      }

      // For wallet transfers, show destination selector
      return DestinationSelectorWidget(
        transferType: state.transferType,
        availableDestinations: state.availableDestinations,
        sourceCurrency: state.sourceCurrency,
        availableBalance: state.availableBalance,
      );
    }

    if (state is ClientRecipientValidatedState) {
      return RecipientInputWidget(
        sourceCurrency: state.sourceCurrency,
        availableBalance: state.availableBalance,
      );
    }

    if (state is DestinationWalletSelectedState) {
      return DestinationSelectorWidget(
        transferType: state.transferType,
        availableDestinations: state.availableDestinations,
        sourceCurrency: state.sourceCurrency,
        availableBalance: state.availableBalance,
        selectedDestinationType: state.destinationWalletType,
        destinationCurrencies: state.destinationCurrencies,
      );
    }

    if (state is TransferReadyToSubmit) {
      return TransferAmountInputWidget(
        transferType: state.transferType,
        sourceCurrency: state.sourceCurrency,
        destinationCurrency: state.destinationCurrency,
        availableBalance: state.availableBalance,
        amount: state.amount,
        transferFee: state.transferFee,
        receiveAmount: state.receiveAmount,
        isReadyToSubmit: state.isReadyToSubmit,
      );
    }

    if (state is TransferSubmitting) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom loading animation
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: RotationTransition(
                        turns: AlwaysStoppedAnimation(value),
                        child: CustomPaint(
                          painter: GradientCircularProgressPainter(
                            progress: value,
                            gradient: LinearGradient(
                              colors: [
                                context.colors.primary,
                                context.colors.primary.withValues(alpha: 0.3),
                              ],
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Processing Transfer',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we securely process your transfer',
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

// Custom gradient circular progress painter
class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final double strokeWidth;

  GradientCircularProgressPainter({
    required this.progress,
    required this.gradient,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      progress * 6.28,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
