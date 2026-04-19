import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 2: Wallet Type Selection (FIAT, SPOT, ECO)
class Step2WalletType extends StatelessWidget {
  const Step2WalletType({
    super.key,
    required this.bloc,
  });

  final CreateOfferBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferBloc, CreateOfferState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is! CreateOfferEditing) {
          return const Center(child: CircularProgressIndicator());
        }

        final selectedWalletType = state.walletType;
        final tradeType = state.tradeType;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Select Wallet Type',
                style: context.h5.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which wallet to use for this ${tradeType?.toLowerCase() ?? 'trade'}',
                style: context.bodyM.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // FIAT Wallet Option
              _buildWalletTypeCard(
                context: context,
                type: 'FIAT',
                title: 'Fiat Wallet',
                subtitle: 'Traditional currency wallet (USD, EUR, etc.)',
                icon: Icons.account_balance,
                color: const Color(0xFF10B981),
                isSelected: selectedWalletType == 'FIAT',
                tradeType: tradeType,
                onTap: () {
                  bloc.add(
                      const CreateOfferWalletTypeSelected(walletType: 'FIAT'));
                },
              ),

              const SizedBox(height: 16),

              // SPOT Wallet Option
              _buildWalletTypeCard(
                context: context,
                type: 'SPOT',
                title: 'Spot Wallet',
                subtitle: 'Cryptocurrency trading wallet',
                icon: Icons.currency_exchange,
                color: const Color(0xFF3B82F6),
                isSelected: selectedWalletType == 'SPOT',
                tradeType: tradeType,
                onTap: () {
                  bloc.add(
                      const CreateOfferWalletTypeSelected(walletType: 'SPOT'));
                },
              ),

              const SizedBox(height: 16),

              // ECO Wallet Option (Funding/Ecosystem)
              _buildWalletTypeCard(
                context: context,
                type: 'ECO',
                title: 'Ecosystem Wallet',
                subtitle: 'Platform ecosystem and funding wallet',
                icon: Icons.eco,
                color: const Color(0xFF8B5CF6),
                isSelected: selectedWalletType == 'ECO',
                tradeType: tradeType,
                onTap: () {
                  bloc.add(
                      const CreateOfferWalletTypeSelected(walletType: 'ECO'));
                },
              ),

              const SizedBox(height: 32),

              // Info Section
              if (selectedWalletType != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getWalletColor(selectedWalletType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _getWalletColor(selectedWalletType).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getWalletColor(selectedWalletType),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About ${_getWalletDisplayName(selectedWalletType)}',
                            style: context.bodyM.copyWith(
                              color: _getWalletColor(selectedWalletType),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getWalletDescription(selectedWalletType, tradeType),
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletTypeCard({
    required BuildContext context,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required String? tradeType,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyL.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Usage indicator
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getUsageText(type, tradeType),
                      style: context.bodyS.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWalletColor(String walletType) {
    switch (walletType) {
      case 'FIAT':
        return const Color(0xFF10B981);
      case 'SPOT':
        return const Color(0xFF3B82F6);
      case 'ECO':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getWalletDisplayName(String walletType) {
    switch (walletType) {
      case 'FIAT':
        return 'Fiat Wallet';
      case 'SPOT':
        return 'Spot Wallet';
      case 'ECO':
        return 'Ecosystem Wallet';
      default:
        return walletType;
    }
  }

  String _getUsageText(String walletType, String? tradeType) {
    if (tradeType == 'BUY') {
      switch (walletType) {
        case 'FIAT':
          return 'Pay with fiat money';
        case 'SPOT':
          return 'Receive crypto here';
        case 'ECO':
          return 'Ecosystem trading';
        default:
          return 'For buying';
      }
    } else if (tradeType == 'SELL') {
      switch (walletType) {
        case 'FIAT':
          return 'Receive fiat money';
        case 'SPOT':
          return 'Sell from this wallet';
        case 'ECO':
          return 'Ecosystem trading';
        default:
          return 'For selling';
      }
    }
    return 'Trading wallet';
  }

  String _getWalletDescription(String walletType, String? tradeType) {
    if (tradeType == 'BUY') {
      switch (walletType) {
        case 'FIAT':
          return '• Use traditional currencies (USD, EUR, etc.)\n'
              '• Perfect for buying crypto with cash\n'
              '• Supports bank transfers and payment methods';
        case 'SPOT':
          return '• Your crypto will be deposited here\n'
              '• Most common choice for P2P trading\n'
              '• Supports all major cryptocurrencies';
        case 'ECO':
          return '• Platform ecosystem wallet\n'
              '• Special platform features and benefits\n'
              '• May have different fee structures';
        default:
          return 'Selected wallet type information';
      }
    } else if (tradeType == 'SELL') {
      switch (walletType) {
        case 'FIAT':
          return '• Receive payment in traditional currencies\n'
              '• Funds go to your bank account\n'
              '• Supports various payment methods';
        case 'SPOT':
          return '• Sell crypto from your spot wallet\n'
              '• Your crypto will be held in escrow\n'
              '• Released when buyer confirms payment';
        case 'ECO':
          return '• Sell from ecosystem wallet\n'
              '• Special platform features available\n'
              '• May have different fee structures';
        default:
          return 'Selected wallet type information';
      }
    }
    return 'Wallet type information will appear here';
  }
}
