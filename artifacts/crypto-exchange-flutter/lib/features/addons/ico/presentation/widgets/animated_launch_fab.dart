import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import 'dart:math' as math;

class AnimatedLaunchFAB extends StatefulWidget {
  const AnimatedLaunchFAB({
    super.key,
    required this.onPressed,
    this.extended = false,
  });

  final VoidCallback onPressed;
  final bool extended;

  @override
  State<AnimatedLaunchFAB> createState() => _AnimatedLaunchFABState();
}

class _AnimatedLaunchFABState extends State<AnimatedLaunchFAB>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: widget.onPressed,
              backgroundColor: context.colors.primary,
              elevation: 8,
              extendedPadding: widget.extended
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.extended ? 28 : 56),
              ),
              icon: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        // Icon
                        const Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
              label: widget.extended
                  ? ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.8),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Launch Token',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

// Compact version for screens with less space
class MiniLaunchFAB extends StatefulWidget {
  const MiniLaunchFAB({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  State<MiniLaunchFAB> createState() => _MiniLaunchFABState();
}

class _MiniLaunchFABState extends State<MiniLaunchFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary,
                context.colors.primary.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.4),
                blurRadius: 12 + (8 * _animation.value),
                offset: Offset(0, 4 + (2 * _animation.value)),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Transform.scale(
                  scale: 1 + (0.1 * _animation.value),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
