import 'dart:async';
import 'package:flutter/material.dart';

import '../services/price_animation_service.dart';
import '../../injection/injection.dart';
import '../theme/global_theme_extensions.dart';

class AnimatedPrice extends StatefulWidget {
  final String symbol;
  final double price;
  final TextStyle? style;
  final int? decimalPlaces;
  final String? prefix;
  final String? suffix;
  final bool showCurrencySymbol;
  final VoidCallback? onTap;

  const AnimatedPrice({
    super.key,
    required this.symbol,
    required this.price,
    this.style,
    this.decimalPlaces,
    this.prefix,
    this.suffix,
    this.showCurrencySymbol = true,
    this.onTap,
  });

  @override
  State<AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color _currentColor = Colors.white;
  StreamSubscription<Color>? _colorSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Subscribe to price color updates
    final priceAnimationService = getIt<PriceAnimationService>();
    _colorSubscription = priceAnimationService
        .getColorStream(widget.symbol)
        .listen(_onColorChanged);

    // Update price in the service with context for theme colors
    priceAnimationService.updatePrice(widget.symbol, widget.price,
        context: context);
  }

  @override
  void didUpdateWidget(AnimatedPrice oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update price in service if it changed
    if (oldWidget.price != widget.price) {
      final priceAnimationService = getIt<PriceAnimationService>();
      priceAnimationService.updatePrice(widget.symbol, widget.price,
          context: context);
    }
  }

  void _onColorChanged(Color newColor) {
    if (_currentColor != newColor) {
      _colorAnimation = ColorTween(
        begin: _currentColor,
        end: newColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _currentColor = newColor;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _colorSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = _formatPrice();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          // For prices, use white as default unless animating
          Color displayColor = _colorAnimation.value ?? _currentColor;

          // If no animation color and it's white, keep the original style color
          if (displayColor == Colors.white &&
              (_colorAnimation.value == null ||
                  _colorAnimation.value == Colors.white)) {
            displayColor = (widget.style ?? context.priceMedium()).color ??
                context.textPrimary;
          }

          return Text(
            formattedPrice,
            style: (widget.style ?? context.priceMedium()).copyWith(
              color: displayColor,
            ),
          );
        },
      ),
    );
  }

  String _formatPrice() {
    final decimalPlaces = widget.decimalPlaces ?? _getDefaultDecimalPlaces();
    final formattedPrice = widget.price.toStringAsFixed(decimalPlaces);

    String result = '';

    if (widget.prefix != null) {
      result += widget.prefix!;
    }

    if (widget.showCurrencySymbol) {
      final quote = widget.symbol.contains('/')
          ? widget.symbol.split('/').last.toUpperCase()
          : '';
      final currencyPrefix = quote == 'INR' ? '₹' : '\$';
      result += '$currencyPrefix$formattedPrice';
    } else {
      result += formattedPrice;
    }

    if (widget.suffix != null) {
      result += widget.suffix!;
    }

    return result;
  }

  int _getDefaultDecimalPlaces() {
    // Default decimal places based on price range
    if (widget.price >= 1000) return 2;
    if (widget.price >= 1) return 4;
    if (widget.price >= 0.01) return 6;
    return 8;
  }
}

/// Animated widget for percentage changes with theme colors
class AnimatedPercentage extends StatefulWidget {
  final String symbol;
  final double percentage;
  final TextStyle? style;
  final bool showSign;
  final VoidCallback? onTap;

  const AnimatedPercentage({
    super.key,
    required this.symbol,
    required this.percentage,
    this.style,
    this.showSign = true,
    this.onTap,
  });

  @override
  State<AnimatedPercentage> createState() => _AnimatedPercentageState();
}

class _AnimatedPercentageState extends State<AnimatedPercentage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color _currentColor = Colors.white;
  StreamSubscription<Color>? _colorSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Subscribe to change percentage color updates
    final priceAnimationService = getIt<PriceAnimationService>();
    _colorSubscription = priceAnimationService
        .getColorStream(widget.symbol)
        .listen(_onColorChanged);

    // Update change percentage in the service with context for theme colors
    priceAnimationService.updateChangePercentage(
        widget.symbol, widget.percentage,
        context: context);
  }

  @override
  void didUpdateWidget(AnimatedPercentage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update change percentage in service if it changed
    if (oldWidget.percentage != widget.percentage) {
      final priceAnimationService = getIt<PriceAnimationService>();
      priceAnimationService.updateChangePercentage(
          widget.symbol, widget.percentage,
          context: context);
    }
  }

  void _onColorChanged(Color newColor) {
    if (_currentColor != newColor) {
      _colorAnimation = ColorTween(
        begin: _currentColor,
        end: newColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _currentColor = newColor;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _colorSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.percentage >= 0;
    final sign = isPositive ? '+' : '';
    final formattedPercentage =
        '${widget.showSign ? sign : ''}${widget.percentage.toStringAsFixed(2)}%';

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          // Use theme colors for positive/negative, but animate on changes
          Color displayColor;
          if (_colorAnimation.value != null &&
              _colorAnimation.value != Colors.white) {
            displayColor = _colorAnimation.value!;
          } else {
            displayColor =
                isPositive ? context.priceUpColor : context.priceDownColor;
          }

          return Text(
            formattedPercentage,
            style: (widget.style ?? context.percentageChange()).copyWith(
              color: displayColor, // Always override the color from style
            ),
          );
        },
      ),
    );
  }
}

/// Compact version for small price displays
class AnimatedPriceCompact extends StatelessWidget {
  final String symbol;
  final double price;
  final TextStyle? style;
  final int? decimalPlaces;

  const AnimatedPriceCompact({
    super.key,
    required this.symbol,
    required this.price,
    this.style,
    this.decimalPlaces,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPrice(
      symbol: symbol,
      price: price,
      style: style ?? context.priceSmall(),
      decimalPlaces: decimalPlaces ?? 2,
    );
  }
}

/// Animated container that changes background color based on price movements
class AnimatedPercentageContainer extends StatefulWidget {
  final String symbol;
  final double percentage;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double backgroundOpacity;
  final VoidCallback? onTap;

  const AnimatedPercentageContainer({
    super.key,
    required this.symbol,
    required this.percentage,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundOpacity = 0.12,
    this.onTap,
  });

  @override
  State<AnimatedPercentageContainer> createState() =>
      _AnimatedPercentageContainerState();
}

class _AnimatedPercentageContainerState
    extends State<AnimatedPercentageContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color _currentColor = Colors.white;
  StreamSubscription<Color>? _colorSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Subscribe to price animation service for background color changes
    final priceAnimationService = getIt<PriceAnimationService>();
    _colorSubscription = priceAnimationService
        .getColorStream(widget.symbol)
        .listen(_onColorChanged);

    // Update change percentage in the service with context for theme colors
    priceAnimationService.updateChangePercentage(
        widget.symbol, widget.percentage,
        context: context);
  }

  @override
  void didUpdateWidget(AnimatedPercentageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update change percentage in service if it changed
    if (oldWidget.percentage != widget.percentage) {
      final priceAnimationService = getIt<PriceAnimationService>();
      priceAnimationService.updateChangePercentage(
          widget.symbol, widget.percentage,
          context: context);
    }
  }

  void _onColorChanged(Color newColor) {
    if (_currentColor != newColor) {
      _colorAnimation = ColorTween(
        begin: _currentColor,
        end: newColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _currentColor = newColor;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _colorSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.percentage >= 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          // Use theme colors for positive/negative, but animate on changes
          Color displayColor;
          if (_colorAnimation.value != null &&
              _colorAnimation.value != Colors.white) {
            displayColor = _colorAnimation.value!;
          } else {
            displayColor =
                isPositive ? context.priceUpColor : context.priceDownColor;
          }

          return Container(
            padding: widget.padding,
            margin: widget.margin,
            decoration: BoxDecoration(
              color: displayColor.withValues(alpha: widget.backgroundOpacity),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animated trend arrow that changes color and direction based on price movements
class AnimatedTrendArrow extends StatefulWidget {
  final String symbol;
  final double percentage;
  final double size;
  final VoidCallback? onTap;

  const AnimatedTrendArrow({
    super.key,
    required this.symbol,
    required this.percentage,
    this.size = 12.0,
    this.onTap,
  });

  @override
  State<AnimatedTrendArrow> createState() => _AnimatedTrendArrowState();
}

class _AnimatedTrendArrowState extends State<AnimatedTrendArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color _currentColor = Colors.white;
  StreamSubscription<Color>? _colorSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Subscribe to price animation service for color changes
    final priceAnimationService = getIt<PriceAnimationService>();
    _colorSubscription = priceAnimationService
        .getColorStream(widget.symbol)
        .listen(_onColorChanged);

    // Update change percentage in the service with context for theme colors
    priceAnimationService.updateChangePercentage(
        widget.symbol, widget.percentage,
        context: context);
  }

  @override
  void didUpdateWidget(AnimatedTrendArrow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update change percentage in service if it changed
    if (oldWidget.percentage != widget.percentage) {
      final priceAnimationService = getIt<PriceAnimationService>();
      priceAnimationService.updateChangePercentage(
          widget.symbol, widget.percentage,
          context: context);
    }
  }

  void _onColorChanged(Color newColor) {
    if (_currentColor != newColor) {
      _colorAnimation = ColorTween(
        begin: _currentColor,
        end: newColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _currentColor = newColor;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _colorSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.percentage >= 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          // Use theme colors for positive/negative, but animate on changes
          Color displayColor;
          if (_colorAnimation.value != null &&
              _colorAnimation.value != Colors.white) {
            displayColor = _colorAnimation.value!;
          } else {
            displayColor =
                isPositive ? context.priceUpColor : context.priceDownColor;
          }

          return Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: displayColor,
            size: widget.size,
          );
        },
      ),
    );
  }
}
