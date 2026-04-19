import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Spot', Icons.swap_horiz, context.colors.primary),
      ('Futures', Icons.trending_up, context.priceUpColor),
      ('P2P', Icons.people, const Color(0xFFFF9500)),
      ('Earn', Icons.savings, const Color(0xFF5856D6)),
      ('NFT', Icons.palette, context.priceDownColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Trade',
          style: context.h5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
        Row(
          children: actions.map((action) {
            final (title, icon, color) = action;
            final index = actions.indexOf(action);
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < actions.length - 1
                      ? (context.isSmallScreen ? 6.0 : 8.0)
                      : 0,
                ),
                child: _buildActionCard(context, title, icon, color, () {}),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.isSmallScreen ? 12.0 : 16.0,
            horizontal: context.isSmallScreen ? 6.0 : 8.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: context.borderColor),
            borderRadius:
                BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
          ),
          child: Column(
            children: [
              Container(
                width: context.isSmallScreen ? 30.0 : 36.0,
                height: context.isSmallScreen ? 30.0 : 36.0,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.isSmallScreen ? 16.0 : 18.0,
                ),
              ),
              SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
              Text(
                title,
                style: context.labelM.copyWith(
                  fontSize: context.isSmallScreen ? 11.0 : 12.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
