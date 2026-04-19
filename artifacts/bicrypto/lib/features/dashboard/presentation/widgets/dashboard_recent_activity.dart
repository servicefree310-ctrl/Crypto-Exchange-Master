import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/dashboard_state.dart';

class DashboardRecentActivity extends StatelessWidget {
  const DashboardRecentActivity({
    super.key,
    required this.activities,
  });

  final List<DashboardActivityData> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: context.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isSmallScreen ? 8.0 : 12.0,
                  vertical: 4.0,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: context.labelM.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius:
                BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: activities.map((activity) {
              final index = activities.indexOf(activity);
              return Container(
                padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  border: index < activities.length - 1
                      ? Border(
                          bottom: BorderSide(color: context.borderColor),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.isSmallScreen ? 32.0 : 36.0,
                      height: context.isSmallScreen ? 32.0 : 36.0,
                      decoration: BoxDecoration(
                        color: activity.isPositive
                            ? context.priceUpColor.withValues(alpha: 0.1)
                            : context.priceDownColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity.isPositive ? Icons.add : Icons.remove,
                        color: activity.isPositive
                            ? context.priceUpColor
                            : context.priceDownColor,
                        size: context.isSmallScreen ? 16.0 : 18.0,
                      ),
                    ),
                    SizedBox(width: context.isSmallScreen ? 10.0 : 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.type,
                            style: context.labelL.copyWith(
                              fontSize: context.isSmallScreen ? 13.0 : 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${activity.symbol} • ${activity.amount}',
                            style: context.bodyS.copyWith(
                              fontSize: context.isSmallScreen ? 11.0 : 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          activity.value,
                          style: context.priceMedium().copyWith(
                                color: activity.isPositive
                                    ? context.priceUpColor
                                    : context.priceDownColor,
                                fontSize: context.isSmallScreen ? 13.0 : 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          activity.timeAgo,
                          style: context.bodyS.copyWith(
                            fontSize: context.isSmallScreen ? 10.0 : 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
