import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/global_theme_extensions.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabData,
  });

  final int currentIndex;
  final Function(int) onTap;
  final List<dynamic> tabData;

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.tabData.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _rotationAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _bounceAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.bounceOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 60 + bottomPadding,
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
        child: Row(
          children: List.generate(
            widget.tabData.length,
            (index) => _NavBarItem(
              data: _NavBarItemData(
                key: widget.tabData[index].key,
                label: widget.tabData[index].label,
                iconData: _getIconData(widget.tabData[index].key),
              ),
              isSelected: widget.currentIndex == index,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onTap(index);
                _animateTab(index);
              },
              scaleAnimation: _scaleAnimations[index],
              rotationAnimation: _rotationAnimations[index],
              bounceAnimation: _bounceAnimations[index],
              tabCount: widget.tabData.length,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String tabKey) {
    switch (tabKey) {
      case 'dashboard':
        return Icons.home_rounded;
      case 'market':
        return Icons.trending_up_rounded;
      case 'trade':
        return Icons.swap_horiz_rounded;
      case 'futures':
        return Icons.auto_graph_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'profile':
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  void _animateTab(int index) {
    // Reset all animations
    for (int i = 0; i < _animationControllers.length; i++) {
      if (i != index) {
        _animationControllers[i].reset();
      }
    }

    // Animate the tapped item
    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });
  }
}

class _NavBarItemData {
  const _NavBarItemData({
    required this.key,
    required this.label,
    required this.iconData,
  });

  final String key;
  final String label;
  final IconData iconData;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.scaleAnimation,
    required this.rotationAnimation,
    required this.bounceAnimation,
    required this.tabCount,
  });

  final _NavBarItemData data;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> scaleAnimation;
  final Animation<double> rotationAnimation;
  final Animation<double> bounceAnimation;
  final int tabCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with unique animations
              AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: scaleAnimation.value,
                    child: Transform.rotate(
                      angle:
                          _getRotationAngle(data.key, rotationAnimation.value),
                      child: _buildIcon(context),
                    ),
                  );
                },
              ),

              const SizedBox(height: 4),

              // Label with smaller text
              Text(
                data.label,
                style: context.labelS.copyWith(
                  color:
                      isSelected ? context.textPrimary : context.textTertiary,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final iconSize = 24.0;
    final color = isSelected ? context.textPrimary : context.textTertiary;

    switch (data.key) {
      case 'trade':
        // Trade: Two arrows that spin when active
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.swap_horiz_rounded,
              size: iconSize,
              color: color,
            ),
            if (isSelected)
              AnimatedBuilder(
                animation: rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: rotationAnimation.value * 2 * 3.14159,
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: iconSize * 0.6,
                      color: color,
                    ),
                  );
                },
              ),
          ],
        );

      case 'wallet':
        // Wallet: Pop animation with bounce
        return AnimatedBuilder(
          animation: bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (bounceAnimation.value * 0.2),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: iconSize,
                color: color,
              ),
            );
          },
        );

      case 'market':
        // Market: Line chart with growing animation
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: iconSize,
              color: color,
            ),
            if (isSelected)
              AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (scaleAnimation.value * 0.4),
                    child: Icon(
                      Icons.show_chart_rounded,
                      size: iconSize * 0.7,
                      color: color.withValues(alpha: 0.7),
                    ),
                  );
                },
              ),
          ],
        );

      case 'futures':
        // Futures: Graph with pulse animation
        return AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (scaleAnimation.value * 0.1),
              child: Icon(
                Icons.auto_graph_rounded,
                size: iconSize,
                color: color,
              ),
            );
          },
        );

      case 'dashboard':
        // Home: Gentle scale animation
        return AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (scaleAnimation.value * 0.15),
              child: Icon(
                Icons.home_rounded,
                size: iconSize,
                color: color,
              ),
            );
          },
        );

      case 'profile':
        // Profile: Rotate animation
        return AnimatedBuilder(
          animation: rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: rotationAnimation.value * 0.5,
              child: Icon(
                Icons.person_rounded,
                size: iconSize,
                color: color,
              ),
            );
          },
        );

      default:
        return Icon(
          data.iconData,
          size: iconSize,
          color: color,
        );
    }
  }

  double _getRotationAngle(String tabKey, double animationValue) {
    switch (tabKey) {
      case 'trade':
        return animationValue * 2 * 3.14159; // Full rotation
      case 'profile':
        return animationValue * 0.5; // Half rotation
      default:
        return 0.0;
    }
  }
}
