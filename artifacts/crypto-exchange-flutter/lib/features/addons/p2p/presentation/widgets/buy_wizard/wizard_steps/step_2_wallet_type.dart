import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';
import '../../common/p2p_state_widgets.dart';

/// Step 2: Wallet Type Selection
/// Matches v5 step 2 - "Select your wallet type"
class Step2WalletType extends StatelessWidget {
  final Map<String, dynamic> formData;
  final List<Map<String, dynamic>> walletOptions;
  final bool loading;
  final Function(String, dynamic) onChanged;

  const Step2WalletType({
    super.key,
    required this.formData,
    required this.walletOptions,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Title
          Text(
            'Select your wallet type',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 32),

          // Wallet options
          if (loading)
            _buildLoadingWallets(context)
          else
            _buildWalletOptions(context),

          const SizedBox(height: 24),

          // Selected wallet info
          if (formData['walletType']?.isNotEmpty == true && !loading)
            _buildSelectedWalletInfo(context),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLoadingWallets(BuildContext context) {
    return const P2PShimmerLoading(
      itemCount: 3,
      itemHeight: 140,
    );
  }

  Widget _buildWalletOptions(BuildContext context) {
    return Row(
      children: walletOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final wallet = entry.value;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                right: index < walletOptions.length - 1 ? 16 : 0),
            child: _buildWalletCard(
              context: context,
              wallet: wallet,
              isSelected: formData['walletType'] == wallet['id'],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWalletCard({
    required BuildContext context,
    required Map<String, dynamic> wallet,
    required bool isSelected,
  }) {
    final walletId = wallet['id'] as String;
    final walletIcon = _getWalletIcon(walletId);
    final walletColor = _getWalletColor(walletId);

    return GestureDetector(
      onTap: () => onChanged('walletType', walletId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? walletColor.withValues(alpha: 0.08)
              : context.cardBackground,
          border: Border.all(
            color: isSelected ? walletColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: walletColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? walletColor.withValues(alpha: 0.15)
                    : walletColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                walletIcon,
                color: walletColor,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            // Wallet name
            Text(
              wallet['name'],
              style: context.bodyL.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Wallet description
            Text(
              _getWalletDescription(walletId),
              style: context.bodyS.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedWalletInfo(BuildContext context) {
    final selectedWallet = walletOptions.firstWhere(
      (wallet) => wallet['id'] == formData['walletType'],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.buyColor.withValues(alpha: 0.05),
        border: Border.all(
          color: context.buyColor.withValues(alpha: 0.2),
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
              color: context.buyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getWalletIcon(formData['walletType']),
              color: context.buyColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedWallet['name']} Wallet Selected',
                  style: context.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getWalletDescription(formData['walletType']),
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWalletIcon(String walletId) {
    switch (walletId) {
      case 'FIAT':
        return Icons.account_balance;
      case 'SPOT':
        return Icons.trending_up;
      case 'ECO':
        return Icons.eco;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getWalletColor(String walletId) {
    switch (walletId) {
      case 'FIAT':
        return const Color(0xFF3B82F6); // Blue
      case 'SPOT':
        return const Color(0xFF10B981); // Green
      case 'ECO':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getWalletDescription(String walletId) {
    switch (walletId) {
      case 'FIAT':
        return 'Traditional currencies like USD, EUR, etc.';
      case 'SPOT':
        return 'Cryptocurrencies for spot trading';
      case 'ECO':
        return 'Funding wallet for earning and lending';
      default:
        return 'Digital wallet for trading';
    }
  }
}
