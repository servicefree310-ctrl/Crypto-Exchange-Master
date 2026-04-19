import 'dart:math';
import 'package:flutter/material.dart';

class PriceFormatter {
  /// Format price for display with smart truncation based on available width
  static String formatPrice(
    double price, {
    double? availableWidth,
    double? fontSize = 14.0,
    int maxDecimals = 8,
    bool useCompactNotation = true,
  }) {
    if (price == 0) return '0.00';

    // Calculate approximate character width based on font size
    final charWidth = (fontSize ?? 14.0) * 0.6; // Rough estimate

    String formattedPrice;

    if (price >= 1000000 && useCompactNotation) {
      // Use compact notation for very large numbers
      if (price >= 1000000000) {
        formattedPrice = '${(price / 1000000000).toStringAsFixed(2)}B';
      } else if (price >= 1000000) {
        formattedPrice = '${(price / 1000000).toStringAsFixed(2)}M';
      } else {
        formattedPrice = '${(price / 1000).toStringAsFixed(2)}K';
      }
    } else if (price >= 1) {
      // Regular formatting for prices >= 1
      formattedPrice = price.toStringAsFixed(min(2, maxDecimals));
    } else {
      // For prices < 1, show more decimal places
      final decimals = _calculateOptimalDecimals(price, maxDecimals);
      formattedPrice = price.toStringAsFixed(decimals);
    }

    // If available width is provided, truncate if necessary
    if (availableWidth != null && charWidth > 0) {
      final maxChars = (availableWidth / charWidth).floor();
      if (formattedPrice.length > maxChars && maxChars > 3) {
        // Leave space for ellipsis
        formattedPrice = '${formattedPrice.substring(0, maxChars - 1)}…';
      }
    }

    return formattedPrice;
  }

  /// Calculate optimal number of decimal places for small prices
  static int _calculateOptimalDecimals(double price, int maxDecimals) {
    if (price >= 0.1) return 4;
    if (price >= 0.01) return 6;
    if (price >= 0.001) return 6;
    if (price >= 0.0001) return 6;
    return min(8, maxDecimals);
  }

  /// Format price for order book with skeleton loading support and animated color transitions
  static Widget formatPriceWidget(
    double? price, {
    required double availableWidth,
    double fontSize = 14.0,
    Color? color,
    FontWeight fontWeight = FontWeight.bold,
    bool isLoading = false,
    bool enableColorAnimation = false,
  }) {
    if (isLoading || price == null) {
      return _buildSkeleton(availableWidth, fontSize);
    }

    final formattedPrice = formatPrice(
      price,
      availableWidth: availableWidth * 0.9, // Leave some margin
      fontSize: fontSize,
    );

    final textWidget = Text(
      formattedPrice,
      style: TextStyle(
        color: color ?? const Color(0xFF00D4AA),
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 0.5,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    // Add color animation if enabled
    if (enableColorAnimation && color != null && color != Colors.white) {
      return _AnimatedPriceColor(
        color: color,
        duration: const Duration(milliseconds: 300),
        child: textWidget,
      );
    }

    return textWidget;
  }

  /// Build skeleton loading placeholder
  static Widget _buildSkeleton(double width, double fontSize) {
    return Container(
      height: fontSize + 4,
      width: width * 0.7, // Use 70% of available width
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const _SkeletonShimmer(),
    );
  }

  /// Format change percentage with proper color
  static String formatChangePercent(double changePercent) {
    final formatted = changePercent.toStringAsFixed(2);
    return changePercent >= 0 ? '+$formatted%' : '$formatted%';
  }

  /// Get color for change percentage
  static Color getChangeColor(double changePercent) {
    if (changePercent > 0) {
      return const Color(0xFF00D4AA); // Green for positive
    } else if (changePercent < 0) {
      return const Color(0xFFFF4757); // Red for negative
    } else {
      return Colors.grey; // Neutral for zero
    }
  }

  /// Format volume with K/M/B notation
  static String formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    } else {
      return volume.toStringAsFixed(2);
    }
  }
}

/// Animated color transition widget for price changes
class _AnimatedPriceColor extends StatefulWidget {
  final Color color;
  final Duration duration;
  final Widget child;

  const _AnimatedPriceColor({
    required this.color,
    required this.duration,
    required this.child,
  });

  @override
  State<_AnimatedPriceColor> createState() => _AnimatedPriceColorState();
}

class _AnimatedPriceColorState extends State<_AnimatedPriceColor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color? _previousColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _previousColor = Colors.white;
    _updateAnimation();
  }

  @override
  void didUpdateWidget(_AnimatedPriceColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _previousColor = oldWidget.color;
      _updateAnimation();
      _controller.forward(from: 0.0);
    }
  }

  void _updateAnimation() {
    _colorAnimation = ColorTween(
      begin: _previousColor,
      end: widget.color,
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
      animation: _colorAnimation,
      builder: (context, child) {
        return DefaultTextStyle.merge(
          style: TextStyle(color: _colorAnimation.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton shimmer animation widget
class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer();

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.withValues(alpha: 0.3),
                Colors.grey.withValues(alpha: 0.1),
                Colors.grey.withValues(alpha: 0.3),
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
