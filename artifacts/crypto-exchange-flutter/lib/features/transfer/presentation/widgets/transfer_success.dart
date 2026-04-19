import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transfer_response_entity.dart';

class TransferSuccessWidget extends StatefulWidget {
  final TransferResponseEntity response;

  const TransferSuccessWidget({
    super.key,
    required this.response,
  });

  @override
  State<TransferSuccessWidget> createState() => _TransferSuccessWidgetState();
}

class _TransferSuccessWidgetState extends State<TransferSuccessWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward().then((_) {
      _checkController.forward();
      HapticFeedback.heavyImpact();
    });

    // Auto navigate back after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _navigateBack();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
    // Show toast message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: context.priceUpColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Transfer Successful!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Your funds have been transferred successfully',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: context.priceUpColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon with Animation
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.priceUpColor.withValues(alpha: 0.2),
                        context.priceUpColor.withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.priceUpColor.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CheckmarkPainter(
                          progress: _checkAnimation.value,
                          color: context.priceUpColor,
                        ),
                        size: const Size(120, 120),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Success Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Transfer Successful!',
              style: context.h3.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Success Message
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.response.message,
              style: context.bodyL.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Transfer Details Card with enhanced design
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? context.colors.surface
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.priceUpColor.withValues(alpha: 0.2),
                              context.priceUpColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.receipt_rounded,
                          color: context.priceUpColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Transfer Details',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    context,
                    'From',
                    '${widget.response.fromType} Wallet',
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'To',
                    '${widget.response.toType} Wallet',
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Amount',
                    '${widget.response.fromTransfer.amount.toStringAsFixed(2)} ${widget.response.fromCurrency.toUpperCase()}',
                    icon: Icons.monetization_on_rounded,
                    isHighlight: true,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Status',
                    widget.response.fromTransfer.status.toUpperCase(),
                    icon: Icons.check_circle_rounded,
                    valueColor: context.priceUpColor,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: context.textTertiary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ID: ${widget.response.fromTransfer.id}',
                            style: context.labelS.copyWith(
                              color: context.textTertiary,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                              text: widget.response.fromTransfer.id,
                            ));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Transfer ID copied'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            color: context.colors.primary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons with enhanced design
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _navigateBack,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.borderColor.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 18,
                          color: context.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View Wallets',
                          style: context.labelL.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to transfer page again for another transfer
                      Navigator.of(context).pushNamed('/transfer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'New Transfer',
                          style: context.buttonText(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Auto navigation hint
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Returning to wallets in 5 seconds...',
              style: context.labelS.copyWith(
                color: context.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (valueColor ?? context.textSecondary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: valueColor ?? context.textSecondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.labelS.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.labelL.copyWith(
                  color: valueColor ?? context.textPrimary,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom checkmark painter for animated check
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    if (progress > 0) {
      // Draw checkmark
      final path = Path();
      final startX = center.dx - radius * 0.5;
      final startY = center.dy;

      path.moveTo(startX, startY);

      if (progress > 0.5) {
        path.lineTo(
          center.dx - radius * 0.1,
          center.dy + radius * 0.4,
        );

        final secondProgress = (progress - 0.5) * 2;
        path.lineTo(
          center.dx - radius * 0.1 + (radius * 0.6 * secondProgress),
          center.dy + radius * 0.4 - (radius * 0.8 * secondProgress),
        );
      } else {
        final firstProgress = progress * 2;
        path.lineTo(
          startX + (radius * 0.4 * firstProgress),
          startY + (radius * 0.4 * firstProgress),
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
