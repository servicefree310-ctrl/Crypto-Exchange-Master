import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class WithdrawStepIndicator extends StatelessWidget {
  final int currentStep;
  static const int totalSteps = 4;

  const WithdrawStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;
          final isCompleted = stepNumber < currentStep;
          final isLast = index == totalSteps - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStep(
                    context,
                    stepNumber,
                    _getStepLabel(stepNumber),
                    isActive,
                    isCompleted,
                  ),
                ),
                if (!isLast) _buildConnector(context, isCompleted || isActive),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    int stepNumber,
    String label,
    bool isActive,
    bool isCompleted,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? context.colors.primary : context.colors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? context.colors.primary
                  : context.borderColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    stepNumber.toString(),
                    style: context.bodyS.copyWith(
                      color: isActive ? Colors.white : context.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.bodyS.copyWith(
            color: isActive ? context.textPrimary : context.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildConnector(BuildContext context, bool isActive) {
    return Container(
      height: 2,
      width: 20,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive
            ? context.colors.primary
            : context.borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 1:
        return 'Wallet';
      case 2:
        return 'Currency';
      case 3:
        return 'Method';
      case 4:
        return 'Amount';
      default:
        return '';
    }
  }
}
