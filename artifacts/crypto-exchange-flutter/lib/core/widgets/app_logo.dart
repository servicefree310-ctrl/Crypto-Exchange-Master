import 'package:flutter/material.dart';
import '../theme/global_theme_extensions.dart';
import '../constants/api_constants.dart';

class AppLogo extends StatelessWidget {
  final double? fontSize;
  final bool showIcon;
  final LogoStyle style;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.fontSize = 32,
    this.showIcon = false,
    this.style = LogoStyle.elegant,
    this.textColor,
  });

  const AppLogo.textOnly({
    super.key,
    this.fontSize = 32,
    this.style = LogoStyle.elegant,
    this.textColor,
  }) : showIcon = false;

  const AppLogo.withIcon({
    super.key,
    this.fontSize = 32,
    this.style = LogoStyle.elegant,
    this.textColor,
  }) : showIcon = true;

  @override
  Widget build(BuildContext context) {
    final appName = AppConstants.appName;

    if (appName.isEmpty) {
      return const SizedBox.shrink();
    }

    if (showIcon) {
      return _buildWithIcon(context, appName);
    }

    return _buildTextOnly(context, appName);
  }

  Widget _buildTextOnly(BuildContext context, String appName) {
    return _buildStylizedText(context, appName);
  }

  Widget _buildWithIcon(BuildContext context, String appName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/ICON.png',
          width: fontSize! * 1.5,
          height: fontSize! * 1.5,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a simple icon if ICON.png doesn't exist
            return Icon(
              Icons.account_balance_wallet,
              size: fontSize! * 1.2,
              color: context.colors.primary,
            );
          },
        ),
        const SizedBox(width: 12),
        _buildStylizedText(context, appName),
      ],
    );
  }

  Widget _buildStylizedText(BuildContext context, String appName) {
    final effectiveFontSize = fontSize ?? 32;
    // Use textPrimary from theme if no custom color is provided
    final baseColor = textColor ?? context.textPrimary;

    switch (style) {
      case LogoStyle.elegant:
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              baseColor,
              baseColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            appName,
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        );

      case LogoStyle.gradient:
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              context.colors.primary,
              context.colors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            appName,
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        );

      case LogoStyle.shadow:
        return Text(
          appName,
          style: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: baseColor,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.3),
              ),
              Shadow(
                offset: const Offset(0, 0),
                blurRadius: 8,
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
        );

      case LogoStyle.simple:
        return Text(
          appName,
          style: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: baseColor,
          ),
        );

      case LogoStyle.outlined:
        return Stack(
          children: [
            // Outline
            Text(
              appName,
              style: TextStyle(
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = context.colors.primary,
              ),
            ),
            // Fill
            Text(
              appName,
              style: TextStyle(
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: baseColor,
              ),
            ),
          ],
        );
    }
  }
}

enum LogoStyle {
  elegant, // White gradient - best for dark backgrounds
  gradient, // Primary/secondary gradient
  shadow, // Text with shadows
  simple, // Plain text
  outlined, // Outlined text
}

// Animated version for splash screens
class AnimatedAppLogo extends StatefulWidget {
  final double? fontSize;
  final bool showIcon;
  final LogoStyle style;
  final Duration duration;
  final Color? textColor;

  const AnimatedAppLogo({
    super.key,
    this.fontSize = 32,
    this.showIcon = false,
    this.style = LogoStyle.elegant,
    this.duration = const Duration(milliseconds: 1500),
    this.textColor,
  });

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AppLogo(
              fontSize: widget.fontSize,
              showIcon: widget.showIcon,
              style: widget.style,
              textColor: widget.textColor,
            ),
          ),
        );
      },
    );
  }
}
