import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transfer_option_entity.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';

class DestinationSelectorWidget extends StatelessWidget {
  final String transferType;
  final List<TransferOptionEntity> availableDestinations;
  final String sourceCurrency;
  final double availableBalance;
  final String? selectedDestinationType;
  final List<CurrencyOptionEntity>? destinationCurrencies;

  const DestinationSelectorWidget({
    super.key,
    required this.transferType,
    required this.availableDestinations,
    required this.sourceCurrency,
    required this.availableBalance,
    this.selectedDestinationType,
    this.destinationCurrencies,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Destination Wallet',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose where you want to transfer your funds',
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Source info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transferring: ${sourceCurrency.toUpperCase()}',
                        style: context.labelM.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Available: \$${availableBalance.toStringAsFixed(2)}',
                        style: context.labelS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Show destination wallet selection if no destination is selected yet
          if (selectedDestinationType == null) ...[
            Text(
              'Available Destinations',
              style: context.labelL.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Destination Wallet Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: availableDestinations.length,
                itemBuilder: (context, index) {
                  final wallet = availableDestinations[index];
                  return _DestinationWalletCard(
                    wallet: wallet,
                    isSelected: selectedDestinationType == wallet.id,
                    onTap: () {
                      context.read<TransferBloc>().add(
                            DestinationWalletSelected(walletType: wallet.id),
                          );
                    },
                  );
                },
              ),
            ),
          ],

          // Show destination currency selection if destination wallet is selected
          if (selectedDestinationType != null &&
              destinationCurrencies != null &&
              destinationCurrencies!.isNotEmpty) ...[
            // Selected destination wallet indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.priceUpColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.priceUpColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getWalletIcon(selectedDestinationType!),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination Wallet:',
                          style: context.labelS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          availableDestinations
                              .firstWhere(
                                  (w) => w.id == selectedDestinationType)
                              .name,
                          style: context.labelL.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Go back to destination wallet selection
                      context.read<TransferBloc>().add(
                            SourceCurrencySelected(currency: sourceCurrency),
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.orangeAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: context.orangeAccent,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Select Destination Currency',
              style: context.labelL.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Destination Currency List
            Expanded(
              child: ListView.builder(
                itemCount: destinationCurrencies!.length,
                itemBuilder: (context, index) {
                  final currency = destinationCurrencies![index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CurrencyCard(
                      currency: currency,
                      onTap: () {
                        context.read<TransferBloc>().add(
                              DestinationCurrencySelected(
                                  currency: currency.value),
                            );
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          // Show loading if destination wallet is selected but currencies are loading
          if (selectedDestinationType != null &&
              (destinationCurrencies == null ||
                  destinationCurrencies!.isEmpty)) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.primary,
                      ),
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading destination currencies...',
                      style: context.bodyM.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to get wallet icons
  Widget _getWalletIcon(String walletType) {
    switch (walletType) {
      case 'FIAT':
        return Icon(Icons.attach_money, color: Colors.white, size: 16);
      case 'SPOT':
        return Icon(Icons.monetization_on, color: Colors.white, size: 16);
      case 'ECO':
        return Icon(Icons.eco, color: Colors.white, size: 16);
      case 'FUTURES':
        return Icon(Icons.trending_up, color: Colors.white, size: 16);
      default:
        return Icon(Icons.account_balance_wallet,
            color: Colors.white, size: 16);
    }
  }
}

class _DestinationWalletCard extends StatelessWidget {
  final TransferOptionEntity wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const _DestinationWalletCard({
    required this.wallet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? context.priceUpColor.withValues(alpha: 0.1)
              : context.isDarkMode
                  ? context.colors.surface
                  : context.colors.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? context.priceUpColor
                : context.borderColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.priceUpColor
                      : context.isDarkMode
                          ? context.colors.surfaceContainerHighest
                          : context.colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getWalletIcon(wallet.id),
                  color: isSelected ? Colors.white : context.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  wallet.name,
                  style: context.labelM.copyWith(
                    color: isSelected
                        ? context.textPrimary
                        : context.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                wallet.id,
                style: context.labelS.copyWith(
                  color: context.textTertiary,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWalletIcon(String walletType) {
    switch (walletType) {
      case 'FIAT':
        return Icons.attach_money;
      case 'SPOT':
        return Icons.currency_bitcoin;
      case 'ECO':
        return Icons.eco;
      case 'FUTURES':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }
}

class _CurrencyCard extends StatelessWidget {
  final CurrencyOptionEntity currency;
  final VoidCallback onTap;

  const _CurrencyCard({
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse currency name from label
    final currencyParts = currency.label.split(' - ');
    final currencyName =
        currencyParts.length > 1 ? currencyParts.last : currency.label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? context.colors.surface
              : context.colors.surfaceContainerHighest,
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  currency.value
                      .toUpperCase()
                      .substring(0, currency.value.length >= 2 ? 2 : 1),
                  style: TextStyle(
                    color: context.priceUpColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.value.toUpperCase(),
                    style: context.labelL.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (currencyName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      currencyName,
                      style: context.labelS.copyWith(
                        color: context.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: context.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
