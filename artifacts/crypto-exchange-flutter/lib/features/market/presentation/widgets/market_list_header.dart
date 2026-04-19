import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class MarketListHeader extends StatelessWidget {
  const MarketListHeader({
    super.key,
    this.onSortByPair,
    this.onSortByPrice,
    this.onSortByChange,
    this.sortColumn = MarketSortColumn.none,
    this.ascending = true,
    this.compact = true, // Default to compact mode
  });

  final VoidCallback? onSortByPair;
  final VoidCallback? onSortByPrice;
  final VoidCallback? onSortByChange;
  final MarketSortColumn sortColumn;
  final bool ascending;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompactHeader(context) : _buildNormalHeader(context);
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: context.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pair/Amount column
          Expanded(
            flex: 4,
            child: _buildSortableHeader(
              context: context,
              title: 'Asset',
              onTap: onSortByPair,
              isActive: sortColumn == MarketSortColumn.pair,
              ascending: ascending,
              fontSize: 10,
            ),
          ),

          // Chart column (center) - just a placeholder in compact mode
          Expanded(
            flex: 3,
            child: Center(
              child: _buildSortableHeader(
                context: context,
                title: '24h Chart',
                onTap: null, // Non-sortable
                isActive: false,
                ascending: true,
                fontSize: 10,
                alignment: TextAlign.center,
              ),
            ),
          ),

          // Price/Change column
          Expanded(
            flex: 3,
            child: _buildSortableHeader(
              context: context,
              title: 'Price/Change',
              onTap: onSortByPrice,
              isActive: sortColumn == MarketSortColumn.price,
              ascending: ascending,
              fontSize: 10,
              alignment: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: context.dividerColor,
            width: 0.3,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pair/Amount column
          Expanded(
            flex: 3,
            child: _buildSortableHeader(
              context: context,
              title: 'Pair/Amount',
              onTap: onSortByPair,
              isActive: sortColumn == MarketSortColumn.pair,
              ascending: ascending,
            ),
          ),

          // Price column
          Expanded(
            flex: 2,
            child: _buildSortableHeader(
              context: context,
              title: 'Price',
              onTap: onSortByPrice,
              isActive: sortColumn == MarketSortColumn.price,
              ascending: ascending,
              alignment: TextAlign.right,
            ),
          ),

          // 24h Change column
          Expanded(
            flex: 2,
            child: _buildSortableHeader(
              context: context,
              title: '24h Change',
              onTap: onSortByChange,
              isActive: sortColumn == MarketSortColumn.change,
              ascending: ascending,
              alignment: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader({
    required BuildContext context,
    required String title,
    VoidCallback? onTap,
    bool isActive = false,
    bool ascending = true,
    TextAlign alignment = TextAlign.left,
    double fontSize = 10,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment == TextAlign.right
            ? MainAxisAlignment.end
            : alignment == TextAlign.center
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
        children: [
          if (alignment == TextAlign.right && isActive) ...[
            Icon(
              ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: context.textSecondary,
              size: 14,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            title,
            style: context.labelS.copyWith(
              color: isActive ? context.textPrimary : context.textSecondary,
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
            textAlign: alignment,
          ),
          if (alignment != TextAlign.right && isActive) ...[
            const SizedBox(width: 2),
            Icon(
              ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: context.textSecondary,
              size: 14,
            ),
          ],
        ],
      ),
    );
  }
}

enum MarketSortColumn {
  none,
  pair,
  price,
  change,
}
