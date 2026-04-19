import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/withdraw_bloc.dart';
import '../bloc/withdraw_event.dart';

class WalletTypeSelectorWidget extends StatelessWidget {
  final List<String> walletTypes;

  const WalletTypeSelectorWidget({
    super.key,
    required this.walletTypes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (walletTypes.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Wallets Available',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have any wallets with balance available for withdrawal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Wallet Type',
            style: context.h6.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the wallet type you want to withdraw from',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...walletTypes.map((type) => _buildWalletTypeCard(context, type)),
        ],
      ),
    );
  }

  Widget _buildWalletTypeCard(BuildContext context, String walletType) {
    final walletInfo = _getWalletTypeInfo(walletType);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<WithdrawBloc>().add(
              WalletTypeSelected(walletType: walletType),
            );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: walletInfo['color'].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                walletInfo['icon'],
                color: walletInfo['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletInfo['title'],
                    style: context.bodyL.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    walletInfo['description'],
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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

  Map<String, dynamic> _getWalletTypeInfo(String type) {
    switch (type) {
      case 'FIAT':
        return {
          'title': 'Fiat Wallet',
          'description': 'Withdraw traditional currencies (USD, EUR, etc.)',
          'icon': Icons.attach_money_rounded,
          'color': Colors.green,
        };
      case 'SPOT':
        return {
          'title': 'Spot Wallet',
          'description': 'Withdraw cryptocurrencies from your spot wallet',
          'icon': Icons.currency_bitcoin_rounded,
          'color': Colors.orange,
        };
      case 'ECO':
        return {
          'title': 'Eco Wallet',
          'description': 'Withdraw from your eco-friendly wallet',
          'icon': Icons.eco_rounded,
          'color': Colors.blue,
        };
      default:
        return {
          'title': type,
          'description': 'Withdraw from $type wallet',
          'icon': Icons.account_balance_wallet_rounded,
          'color': Colors.grey,
        };
    }
  }
}
