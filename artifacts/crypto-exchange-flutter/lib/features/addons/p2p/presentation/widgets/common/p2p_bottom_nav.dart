import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';

/// P2P Bottom Navigation Bar
/// KuCoin-style compact design with tab navigation
class P2PBottomNavigation extends StatelessWidget {
  const P2PBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          top: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.swap_horiz_outlined,
                activeIcon: Icons.swap_horiz,
                label: 'Offers',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'Trades',
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? context.colors.primary : context.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.bodyS.copyWith(
                color:
                    isActive ? context.colors.primary : context.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P2P Floating Action Button
/// Used for quick actions like creating offers
class P2PFloatingActionButton extends StatelessWidget {
  const P2PFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? context.colors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(icon, size: 20),
      label: label != null
          ? Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// P2P Mini FAB for compact actions
class P2PMiniFloatingActionButton extends StatelessWidget {
  const P2PMiniFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? context.colors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: tooltip,
      child: Icon(icon, size: 18),
    );
  }
}
