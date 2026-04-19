import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class TransferStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const TransferStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Step dots and connecting lines with enhanced design
          SizedBox(
            height: 28,
            child: Row(
              children: List.generate(totalSteps * 2 - 1, (index) {
                if (index % 2 == 0) {
                  // Step circle with animation
                  final stepNumber = index ~/ 2 + 1;
                  final isActive = stepNumber <= currentStep;
                  final isCompleted = stepNumber < currentStep;
                  final isCurrent = stepNumber == currentStep;

                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    tween: Tween(
                      begin: 0.0,
                      end: isActive ? 1.0 : 0.0,
                    ),
                    builder: (context, value, child) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isActive
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    context.colors.primary,
                                    context.colors.primary.withValues(alpha: 0.8),
                                  ],
                                )
                              : null,
                          color: !isActive
                              ? context.isDarkMode
                                  ? context.colors.surface
                                  : context.colors.surfaceContainerHighest
                              : null,
                          border: Border.all(
                            color: isActive
                                ? Colors.transparent
                                : context.borderColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: context.colors.primary
                                        .withValues(alpha: 0.3 * value),
                                    blurRadius: 8 * value,
                                    spreadRadius: 1 * value,
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
                                    key: const ValueKey('check'),
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : Text(
                                    '$stepNumber',
                                    key: ValueKey('number-$stepNumber'),
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : context.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Connecting line with animation
                  final stepNumber = index ~/ 2 + 1;
                  final isCompleted = stepNumber < currentStep;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        tween: Tween(
                          begin: 0.0,
                          end: isCompleted ? 1.0 : 0.0,
                        ),
                        builder: (context, value, child) {
                          return Stack(
                            children: [
                              // Background line
                              Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? context.colors.surface
                                      : context.colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              // Animated progress line
                              FractionallySizedBox(
                                widthFactor: value,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        context.colors.primary,
                                        context.colors.primary.withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.colors.primary
                                            .withValues(alpha: 0.2 * value),
                                        blurRadius: 2 * value,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Step labels with enhanced typography
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getStepLabels(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _getStepLabels(BuildContext context) {
    final labels = [
      'Type',
      'Source',
      'Currency',
      'Destination',
      'Details',
      'Confirm',
    ];

    return labels.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final stepNumber = index + 1;
      final isActive = stepNumber <= currentStep;
      final isCurrent = stepNumber == currentStep;

      return Expanded(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isActive
                ? isCurrent
                    ? context.colors.primary
                    : context.textPrimary
                : context.textTertiary,
            fontSize: isCurrent ? 11 : 10,
            fontWeight: isCurrent
                ? FontWeight.w600
                : isActive
                    ? FontWeight.w500
                    : FontWeight.w400,
            letterSpacing: -0.2,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();
  }
}
