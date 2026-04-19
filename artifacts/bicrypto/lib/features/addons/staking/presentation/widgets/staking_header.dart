import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class StakingHeader extends StatelessWidget {
  const StakingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button (optional, can be removed if not needed)
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: context.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staking',
                  style: context.h4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Earn passive income',
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Info button
          InkWell(
            onTap: () {
              // Show staking info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Staking'),
                  content: const Text(
                    'Staking allows you to earn rewards by locking your cryptocurrency for a certain period. The longer you stake, the more rewards you earn.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.info_outline,
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
