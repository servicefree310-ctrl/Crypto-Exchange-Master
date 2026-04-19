import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class PremiumLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? overlayColor;
  final bool showBlur;

  const PremiumLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.overlayColor,
    this.showBlur = true,
  });

  @override
  State<PremiumLoadingOverlay> createState() => _PremiumLoadingOverlayState();
}

class _PremiumLoadingOverlayState extends State<PremiumLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.isLoading) {
      _showLoading();
    }
  }

  @override
  void didUpdateWidget(PremiumLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _showLoading();
      } else {
        _hideLoading();
      }
    }
  }

  void _showLoading() {
    _fadeController.forward();
    _scaleController.forward();
    _rotationController.repeat();
  }

  void _hideLoading() {
    _fadeController.reverse();
    _scaleController.reverse();
    _rotationController.stop();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _scaleAnimation,
              _rotationAnimation,
            ]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  color: widget.overlayColor ??
                      context.colors.surface.withValues(alpha: 0.8),
                  child: widget.showBlur
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: _buildLoadingContent(context),
                        )
                      : _buildLoadingContent(context),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: context.cardBackground.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoadingIndicator(context),
              if (widget.loadingText != null) ...[
                const SizedBox(height: 24),
                Text(
                  widget.loadingText!,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
        ),
        // Inner ring
        Transform.rotate(
          angle: -_rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
        ),
        // Center dot
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                context.colors.primary,
                context.colors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Pulsing effect
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Container(
              width: 60 + (10 * (0.5 + 0.5 * _rotationAnimation.value)),
              height: 60 + (10 * (0.5 + 0.5 * _rotationAnimation.value)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 
                    0.2 * (1 - _rotationAnimation.value),
                  ),
                  width: 1,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
