import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';

class SellTradeBottomSheet extends StatelessWidget {
  const SellTradeBottomSheet({
    super.key,
    required this.offer,
    required this.onTradeInitiated,
  });

  final dynamic offer;
  final Function(String tradeId) onTradeInitiated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Icon(Icons.sell, color: context.sellColor),
              const SizedBox(width: 12),
              Text(
                'Sell Crypto',
                style: context.h6.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Sell trade functionality coming soon'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.sellColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
