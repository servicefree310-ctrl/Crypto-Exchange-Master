import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/services/chart_service.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/chart_data_entity.dart';

class RealtimeMiniChart extends StatefulWidget {
  const RealtimeMiniChart({
    super.key,
    required this.symbol,
    required this.color,
    this.height = 50,
    this.showGlow = true,
    this.strokeWidth = 2.0,
    this.isCompact = false,
  });

  final String symbol;
  final Color color;
  final double height;
  final bool showGlow;
  final double strokeWidth;
  final bool isCompact;

  @override
  State<RealtimeMiniChart> createState() => _RealtimeMiniChartState();
}

class _RealtimeMiniChartState extends State<RealtimeMiniChart>
    with SingleTickerProviderStateMixin {
  late final ChartService _chartService;
  late AnimationController _animationController;
  late Animation<double> _animation;

  MarketChartEntity? _chartData;
  List<double> _previousPrices = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _chartService = getIt<ChartService>();

    // Set up animation for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Listen to chart updates for this symbol
    _chartService.getChartStreamForSymbol(widget.symbol).listen((chartData) {
      if (mounted && chartData != null) {
        setState(() {
          _previousPrices = _chartData?.priceValues ?? [];
          _chartData = chartData;
          _animateToNewData();
        });
      }
    });
  }

  void _animateToNewData() {
    if (_previousPrices.isNotEmpty && _chartData != null) {
      _isAnimating = true;
      _animationController.reset();
      _animationController.forward().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size.fromHeight(widget.height),
            painter: RealtimeChartPainter(
              chartData: _chartData,
              previousPrices: _previousPrices,
              color: widget.color,
              animationProgress: _isAnimating ? _animation.value : 1.0,
              showGlow: widget.showGlow &&
                  !widget.isCompact, // No glow in compact mode
              strokeWidth: widget.isCompact
                  ? widget.strokeWidth * 0.8
                  : widget.strokeWidth,
              isCompact: widget.isCompact,
            ),
          );
        },
      ),
    );
  }
}

class RealtimeChartPainter extends CustomPainter {
  final MarketChartEntity? chartData;
  final List<double> previousPrices;
  final Color color;
  final double animationProgress;
  final bool showGlow;
  final double strokeWidth;
  final bool isCompact;

  RealtimeChartPainter({
    required this.chartData,
    required this.previousPrices,
    required this.color,
    required this.animationProgress,
    required this.showGlow,
    required this.strokeWidth,
    this.isCompact = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData == null || chartData!.dataPoints.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    final currentPrices = chartData!.priceValues;

    // Interpolate between previous and current prices during animation
    final displayPrices = _isAnimatingBetweenData()
        ? _interpolatePrices(previousPrices, currentPrices, animationProgress)
        : currentPrices;

    if (displayPrices.length < 2) {
      _drawPlaceholder(canvas, size);
      return;
    }

    _drawChart(canvas, size, displayPrices);

    // Add pulse effect for the latest point when data updates
    if (animationProgress < 1.0 && !isCompact) {
      _drawPulseEffect(canvas, size, displayPrices);
    }
  }

  bool _isAnimatingBetweenData() {
    return previousPrices.isNotEmpty &&
        previousPrices.length == chartData!.priceValues.length &&
        animationProgress < 1.0;
  }

  List<double> _interpolatePrices(
    List<double> from,
    List<double> to,
    double progress,
  ) {
    if (from.length != to.length) return to;

    return List.generate(from.length, (index) {
      final fromPrice = from[index];
      final toPrice = to[index];
      return fromPrice + (toPrice - fromPrice) * progress;
    });
  }

  void _drawChart(Canvas canvas, Size size, List<double> prices) {
    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) {
      _drawFlatLine(canvas, size);
      return;
    }

    // Reduce padding in compact mode for better use of space
    final padding = isCompact ? size.height * 0.05 : size.height * 0.1;
    final chartHeight = size.height - 2 * padding;
    final stepX = size.width / (prices.length - 1);

    // Create paths for line and fill
    final linePath = Path();
    final fillPath = Path();

    // Calculate first point
    final firstY = padding +
        chartHeight -
        ((prices[0] - minPrice) / priceRange) * chartHeight;

    linePath.moveTo(0, firstY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, firstY);

    // Draw smooth curves through all points, with optimizations for compact mode
    final pointCount = isCompact && prices.length > 30
        ? prices.length ~/ 2 // Use fewer points in compact mode
        : prices.length;

    final skipFactor = prices.length / pointCount;

    for (int i = 1; i < pointCount; i++) {
      final realIndex = (i * skipFactor).toInt().clamp(1, prices.length - 1);
      final x = realIndex * stepX;
      final y = padding +
          chartHeight -
          ((prices[realIndex] - minPrice) / priceRange) * chartHeight;

      if (isCompact || i == 1) {
        // Use simpler lines for compact mode
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        // Create smooth curves for normal mode
        final prevRealIndex =
            ((i - 1) * skipFactor).toInt().clamp(0, prices.length - 1);
        final prevX = prevRealIndex * stepX;
        final prevY = padding +
            chartHeight -
            ((prices[prevRealIndex] - minPrice) / priceRange) * chartHeight;

        final cp1x = prevX + stepX * 0.3;
        final cp1y = prevY;
        final cp2x = x - stepX * 0.3;
        final cp2y = y;

        linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
        fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
      }
    }

    // Make sure the path reaches the right edge
    if (pointCount < prices.length) {
      final lastIndex = prices.length - 1;
      final x = lastIndex * stepX;
      final y = padding +
          chartHeight -
          ((prices[lastIndex] - minPrice) / priceRange) * chartHeight;
      linePath.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: isCompact ? 0.15 : 0.25),
          color.withValues(alpha: isCompact ? 0.05 : 0.10),
          color.withValues(alpha: 0.02),
        ],
        stops: isCompact ? const [0.0, 0.5, 1.0] : const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw glow effect if enabled
    if (showGlow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth * 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawPath(linePath, glowPaint);
    }

    // Draw main line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);
  }

  void _drawPulseEffect(Canvas canvas, Size size, List<double> prices) {
    if (prices.isEmpty) return;

    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    final padding = size.height * 0.1;
    final chartHeight = size.height - 2 * padding;

    // Position of the last point
    final lastY = padding +
        chartHeight -
        ((prices.last - minPrice) / priceRange) * chartHeight;

    // Animated pulse circle
    final pulseRadius = 4.0 * (1.0 + animationProgress * 0.5);
    final pulseOpacity = (1.0 - animationProgress) * 0.6;

    final pulsePaint = Paint()
      ..color = color.withValues(alpha: pulseOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width, lastY),
      pulseRadius,
      pulsePaint,
    );

    // Center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width, lastY),
      2.0,
      dotPaint,
    );
  }

  void _drawFlatLine(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    // Draw a subtle placeholder pattern
    final paint = Paint()
      ..color = color.withValues(alpha: isCompact ? 0.1 : 0.2)
      ..strokeWidth = isCompact ? 0.5 : 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    const points = 20;
    final stepX = size.width / points;
    final centerY = size.height / 2;

    for (int i = 0; i <= points; i++) {
      final x = i * stepX;
      final noise = math.sin(i * 0.5) *
          (isCompact ? 3 : 5); // Smaller amplitude for compact mode
      final y = centerY + noise;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RealtimeChartPainter oldDelegate) {
    return oldDelegate.chartData != chartData ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.isCompact != isCompact;
  }
}
