import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/p2p_offer_entity.dart';

/// Trade Type Step - Choose between Buy and Sell
class TradeTypeStep extends StatelessWidget {
  const TradeTypeStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final P2PTradeType? initialValue;
  final ValueChanged<P2PTradeType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you want to do?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose whether you want to buy or sell cryptocurrency',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? context.textSecondary
                      : context.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // Buy option
          _TradeTypeCard(
            type: P2PTradeType.buy,
            title: 'Buy Crypto',
            subtitle: 'I want to buy cryptocurrency with fiat money',
            icon: Icons.shopping_cart_outlined,
            color: context.buyColor,
            isSelected: initialValue == P2PTradeType.buy,
            onTap: () => onChanged(P2PTradeType.buy),
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // Sell option
          _TradeTypeCard(
            type: P2PTradeType.sell,
            title: 'Sell Crypto',
            subtitle: 'I want to sell cryptocurrency for fiat money',
            icon: Icons.sell_outlined,
            color: context.sellColor,
            isSelected: initialValue == P2PTradeType.sell,
            onTap: () => onChanged(P2PTradeType.sell),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TradeTypeCard extends StatelessWidget {
  const _TradeTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final P2PTradeType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (context.cardBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (context.borderColor),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? context.textSecondary
                              : context.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Wallet Type Step - Choose wallet type
class WalletTypeStep extends StatelessWidget {
  const WalletTypeStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final P2PWalletType? initialValue;
  final ValueChanged<P2PWalletType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Wallet Type',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which wallet you want to use for trading',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? context.textSecondary
                      : context.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // Wallet options
          ...P2PWalletType.values.map((walletType) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _WalletTypeCard(
                walletType: walletType,
                isSelected: initialValue == walletType,
                onTap: () => onChanged(walletType),
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WalletTypeCard extends StatelessWidget {
  const _WalletTypeCard({
    required this.walletType,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final P2PWalletType walletType;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final walletInfo = _getWalletInfo(walletType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : (context.cardBackground),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : (context.borderColor),
          ),
        ),
        child: Row(
          children: [
            Icon(
              walletInfo['icon'],
              color: isSelected ? context.colors.primary : null,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletInfo['title'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? context.colors.primary : null,
                        ),
                  ),
                  Text(
                    walletInfo['subtitle'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? context.textSecondary
                              : context.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.colors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getWalletInfo(P2PWalletType type) {
    switch (type) {
      case P2PWalletType.fiat:
        return {
          'title': 'Fiat Wallet',
          'subtitle': 'Use your fiat currency wallet',
          'icon': Icons.account_balance_wallet,
        };
      case P2PWalletType.spot:
        return {
          'title': 'Spot Wallet',
          'subtitle': 'Use your spot trading wallet',
          'icon': Icons.currency_exchange,
        };
      case P2PWalletType.eco:
        return {
          'title': 'Eco Wallet',
          'subtitle': 'Use your ecosystem wallet',
          'icon': Icons.eco,
        };
    }
  }
}

/// Select Crypto Step - Choose cryptocurrency
class SelectCryptoStep extends StatelessWidget {
  const SelectCryptoStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final String? initialValue;
  final ValueChanged<String> onChanged;

  // Popular cryptocurrencies
  final List<Map<String, String>> _cryptos = const [
    {'symbol': 'BTC', 'name': 'Bitcoin'},
    {'symbol': 'ETH', 'name': 'Ethereum'},
    {'symbol': 'USDT', 'name': 'Tether'},
    {'symbol': 'BNB', 'name': 'Binance Coin'},
    {'symbol': 'ADA', 'name': 'Cardano'},
    {'symbol': 'SOL', 'name': 'Solana'},
    {'symbol': 'XRP', 'name': 'Ripple'},
    {'symbol': 'DOT', 'name': 'Polkadot'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Cryptocurrency',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which cryptocurrency you want to trade',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? context.textSecondary
                      : context.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _cryptos.length,
              itemBuilder: (context, index) {
                final crypto = _cryptos[index];
                final isSelected = initialValue == crypto['symbol'];

                return InkWell(
                  onTap: () => onChanged(crypto['symbol']!),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary.withValues(alpha: 0.1)
                          : (context.cardBackground),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary
                            : (isDark
                                ? context.borderColor
                                : context.borderColor),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          crypto['symbol']!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? context.colors.primary : null,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          crypto['name']!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? context.textSecondary
                                        : context.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder steps for remaining functionality
class AmountPriceStep extends StatelessWidget {
  const AmountPriceStep({
    super.key,
    this.tradeType,
    this.currency,
    this.initialAmountConfig,
    this.initialPriceConfig,
    required this.onAmountChanged,
    required this.onPriceChanged,
  });

  final P2PTradeType? tradeType;
  final String? currency;
  final AmountConfiguration? initialAmountConfig;
  final PriceConfiguration? initialPriceConfig;
  final ValueChanged<AmountConfiguration> onAmountChanged;
  final ValueChanged<PriceConfiguration> onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Amount & Price Step - Coming Soon'),
    );
  }
}

class PaymentMethodsStep extends StatelessWidget {
  const PaymentMethodsStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final List<String>? initialValue;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Payment Methods Step - Coming Soon'),
    );
  }
}

class TradeSettingsStep extends StatelessWidget {
  const TradeSettingsStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final TradeSettings? initialValue;
  final ValueChanged<TradeSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Trade Settings Step - Coming Soon'),
    );
  }
}

class LocationSettingsStep extends StatelessWidget {
  const LocationSettingsStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final LocationSettings? initialValue;
  final ValueChanged<LocationSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Location Settings Step - Coming Soon'),
    );
  }
}

class UserRequirementsStep extends StatelessWidget {
  const UserRequirementsStep({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final UserRequirements? initialValue;
  final ValueChanged<UserRequirements> onChanged;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('User Requirements Step - Coming Soon'),
    );
  }
}

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.offerData,
    required this.onCreateOffer,
  });

  final Map<String, dynamic> offerData;
  final VoidCallback onCreateOffer;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Review Step - Coming Soon'),
    );
  }
}
