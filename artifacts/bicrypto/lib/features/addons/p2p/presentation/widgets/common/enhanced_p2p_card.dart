import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';

/// Enhanced P2P Card Component
/// Follows the same high-quality design standards as dashboard components
/// with responsive design, visual polish, and proper interactions
class EnhancedP2PCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showBorder;
  final bool showShadow;
  final bool isInteractive;
  final String? heroTag;

  const EnhancedP2PCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showBorder = true,
    this.showShadow = false,
    this.isInteractive = true,
    this.heroTag,
  });

  @override
  State<EnhancedP2PCard> createState() => _EnhancedP2PCardState();
}

class _EnhancedP2PCardState extends State<EnhancedP2PCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? (context.isSmallScreen ? 12.0 : 14.0);

    final effectivePadding =
        widget.padding ?? EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0);

    final effectiveMargin = widget.margin ??
        EdgeInsets.symmetric(
          horizontal: context.isSmallScreen ? 12.0 : 16.0,
          vertical: context.isSmallScreen ? 6.0 : 8.0,
        );

    return Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.cardBackground,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? context.borderColor,
                width: 1,
              )
            : null,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: context.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: context.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: widget.isInteractive && widget.onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                  child: Padding(
                    padding: effectivePadding,
                    child: widget.child,
                  ),
                ),
              )
            : Padding(
                padding: effectivePadding,
                child: widget.child,
              ),
      ),
    );
  }
}
