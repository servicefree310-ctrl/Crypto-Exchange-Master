import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 1: Trade Type Selection (BUY or SELL)
class Step1TradeType extends StatelessWidget {
  const Step1TradeType({
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

        final selectedType = state.tradeType;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Select Trade Type',
                style: context.h5.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose whether you want to buy or sell cryptocurrency',
                style: context.bodyM.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Buy Option
              _buildTradeTypeCard(
                context: context,
                type: 'BUY',
                title: 'Buy Crypto',
                subtitle: 'Purchase cryptocurrency from other users',
                icon: Icons.shopping_cart_outlined,
                color: context.buyColor,
                isSelected: selectedType == 'BUY',
                onTap: () {
                  bloc.add(const CreateOfferFieldUpdated(
                    field: 'type',
                    value: 'BUY',
                  ));
                },
              ),

              const SizedBox(height: 16),

              // Sell Option
              _buildTradeTypeCard(
                context: context,
                type: 'SELL',
                title: 'Sell Crypto',
                subtitle: 'Sell your cryptocurrency to other users',
                icon: Icons.sell_outlined,
                color: context.sellColor,
                isSelected: selectedType == 'SELL',
                onTap: () {
                  bloc.add(const CreateOfferFieldUpdated(
                    field: 'type',
                    value: 'SELL',
                  ));
                },
              ),

              const SizedBox(height: 32),

              // Info Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.2),
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
                          color: context.colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'What happens next?',
                          style: context.bodyM.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedType == 'BUY'
                          ? '• You\'ll set the price you\'re willing to pay\n'
                              '• Choose your preferred payment methods\n'
                              '• Other users will sell crypto to you'
                          : selectedType == 'SELL'
                              ? '• You\'ll set the price for your crypto\n'
                                  '• Choose accepted payment methods\n'
                                  '• Other users will buy crypto from you'
                              : 'Select a trade type to see what happens next',
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

  Widget _buildTradeTypeCard({
    required BuildContext context,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
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
}
