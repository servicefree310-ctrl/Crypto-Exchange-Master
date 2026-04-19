import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/global_theme_extensions.dart';

enum PremiumButtonStyle {
  primary,
  secondary,
  outline,
  gradient,
  glass,
}

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PremiumButtonStyle style;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final bool expanded;
  final List<Color>? gradientColors;
  final double elevation;
  final bool hapticFeedback;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = PremiumButtonStyle.primary,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 50,
    this.borderRadius = 12,
    this.expanded = true,
    this.gradientColors,
    this.elevation = 0,
    this.hapticFeedback = true,
  });

  const PremiumButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 50,
    this.borderRadius = 12,
    this.expanded = true,
    this.elevation = 0,
    this.hapticFeedback = true,
  })  : style = PremiumButtonStyle.primary,
        gradientColors = null;

  const PremiumButton.gradient({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradientColors,
    this.textColor,
    this.icon,
    this.height = 50,
    this.borderRadius = 12,
    this.expanded = true,
    this.elevation = 2,
    this.hapticFeedback = true,
  })  : style = PremiumButtonStyle.gradient,
        backgroundColor = null;

  const PremiumButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 50,
    this.borderRadius = 12,
    this.expanded = true,
    this.elevation = 0,
    this.hapticFeedback = true,
  })  : style = PremiumButtonStyle.outline,
        gradientColors = null;

  const PremiumButton.glass({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 50,
    this.borderRadius = 12,
    this.expanded = true,
    this.elevation = 0,
    this.hapticFeedback = true,
  })  : style = PremiumButtonStyle.glass,
        gradientColors = null;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pressController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _loadingAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(PremiumButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pressController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
      _animationController.reverse();
    }
  }

  void _handleTap() {
    dev.log('🔵 PREMIUM_BUTTON: Tap detected on button: ${widget.text}');
    dev.log('🔵 PREMIUM_BUTTON: onPressed is ${widget.onPressed != null ? "set" : "null"}');
    dev.log('🔵 PREMIUM_BUTTON: isLoading: ${widget.isLoading}');

    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    if (widget.onPressed != null) {
      dev.log('🟢 PREMIUM_BUTTON: Calling onPressed for: ${widget.text}');
      widget.onPressed!();
    } else {
      dev.log('🔴 PREMIUM_BUTTON: onPressed is null, button disabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _elevationAnimation,
        _loadingAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.height,
            width: widget.expanded ? double.infinity : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.style != PremiumButtonStyle.outline
                  ? [
                      BoxShadow(
                        color: _getButtonColor(context).withValues(alpha: 0.3),
                        blurRadius: _elevationAnimation.value * 2,
                        offset: Offset(0, _elevationAnimation.value),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                onTap: isEnabled ? _handleTap : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: isEnabled
                    ? _getButtonColor(context).withValues(alpha: 0.1)
                    : Colors.transparent,
                highlightColor: isEnabled
                    ? _getButtonColor(context).withValues(alpha: 0.05)
                    : Colors.transparent,
                child: Ink(
                  decoration: _getButtonDecoration(context, isEnabled),
                  child: _buildButtonContent(context, isEnabled),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getButtonDecoration(BuildContext context, bool isEnabled) {
    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return BoxDecoration(
          color: isEnabled
              ? _getButtonColor(context)
              : _getButtonColor(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );

      case PremiumButtonStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? (widget.gradientColors ??
                    [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.8),
                    ])
                : [
                    context.colors.primary.withValues(alpha: 0.3),
                    context.colors.primary.withValues(alpha: 0.2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );

      case PremiumButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isEnabled
                ? _getButtonColor(context)
                : _getButtonColor(context).withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );

      case PremiumButtonStyle.glass:
        return BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case PremiumButtonStyle.secondary:
        return BoxDecoration(
          color: isEnabled
              ? context.cardBackground
              : context.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        );
    }
  }

  Color _getButtonColor(BuildContext context) {
    return widget.backgroundColor ?? context.colors.primary;
  }

  Color _getTextColor(BuildContext context, bool isEnabled) {
    if (widget.textColor != null) {
      return isEnabled ? widget.textColor! : widget.textColor!.withValues(alpha: 0.5);
    }

    switch (widget.style) {
      case PremiumButtonStyle.primary:
      case PremiumButtonStyle.gradient:
        return Colors.white;
      case PremiumButtonStyle.outline:
      case PremiumButtonStyle.glass:
        return context.colors.primary;
      case PremiumButtonStyle.secondary:
        return context.textPrimary;
    }
  }

  Widget _buildButtonContent(BuildContext context, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(context, isEnabled),
                ),
              ),
            ),
          ] else ...[
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 10),
            ],
            Text(
              widget.text,
              style: TextStyle(
                color: _getTextColor(context, isEnabled),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
