import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../transfer/domain/entities/currency_option_entity.dart';
import '../bloc/withdraw_bloc.dart';
import '../bloc/withdraw_event.dart';

class CurrencySelectorWidget extends StatelessWidget {
  final String walletType;
  final List<CurrencyOptionEntity> currencies;

  const CurrencySelectorWidget({
    super.key,
    required this.walletType,
    required this.currencies,
  });

  @override
  Widget build(BuildContext context) {
    if (currencies.isEmpty) {
      return Center(
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
              'Loading available currencies...',
              style: context.bodyL.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<WithdrawBloc>().add(
                    const PreviousStepRequested(),
                  ),
              child: Text(
                'Go Back',
                style: context.bodyM.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.read<WithdrawBloc>().add(
                          const PreviousStepRequested(),
                        ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: context.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Currency',
                          style: context.h6.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From $walletType wallet',
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Choose a currency with available balance to withdraw',
                style: context.bodyM.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Currency List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return _buildCurrencyCard(context, currency);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyCard(
      BuildContext context, CurrencyOptionEntity currency) {
    final hasBalance = currency.balance != null && currency.balance! > 0;

    return GestureDetector(
      onTap: hasBalance
          ? () {
              HapticFeedback.lightImpact();
              context.read<WithdrawBloc>().add(
                    CurrencySelected(currency: currency.value),
                  );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasBalance
              ? context.colors.surface
              : context.colors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor.withValues(alpha: hasBalance ? 0.3 : 0.1),
            width: 1,
          ),
          boxShadow: hasBalance
              ? [
                  BoxShadow(
                    color: context.isDarkMode
                        ? Colors.black.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Currency Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasBalance
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  currency.value.substring(0, 1),
                  style: context.h6.copyWith(
                    color: hasBalance
                        ? context.colors.primary
                        : context.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currency.value,
                        style: context.bodyL.copyWith(
                          fontWeight: FontWeight.w700,
                          color: hasBalance
                              ? context.textPrimary
                              : context.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (currency.label != currency.value)
                        Expanded(
                          child: Text(
                            currency.label,
                            style: context.bodyS.copyWith(
                              color: context.textTertiary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Balance: ',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        '${currency.balance?.toStringAsFixed(8) ?? '0'} ${currency.value}',
                        style: context.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasBalance
                              ? context.textPrimary
                              : context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            if (hasBalance)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.textTertiary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
