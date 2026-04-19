import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/withdraw_response_entity.dart';
import '../bloc/withdraw_bloc.dart';
import '../bloc/withdraw_event.dart';

class WithdrawSuccessWidget extends StatefulWidget {
  final WithdrawResponseEntity response;

  const WithdrawSuccessWidget({
    super.key,
    required this.response,
  });

  @override
  State<WithdrawSuccessWidget> createState() => _WithdrawSuccessWidgetState();
}

class _WithdrawSuccessWidgetState extends State<WithdrawSuccessWidget>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon with Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CheckmarkPainter(
                          progress: _checkAnimation.value,
                          color: context.priceUpColor,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success Message
              Text(
                'Withdrawal Submitted!',
                style: context.h5.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                widget.response.message,
                style: context.bodyL.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.response.transaction?.status == 'PENDING') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.warningColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: context.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Your withdrawal is pending approval',
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (widget.response.transaction != null) ...[
                const SizedBox(height: 32),

                // Transaction Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        'Transaction ID',
                        widget.response.transaction!.id,
                        canCopy: true,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Amount',
                        '${widget.response.transaction!.amount} ${widget.response.currency ?? ''}',
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Fee',
                        '${widget.response.transaction!.fee} ${widget.response.currency ?? ''}',
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Status',
                        widget.response.transaction!.status.toUpperCase(),
                        valueColor: _getStatusColor(
                          context,
                          widget.response.transaction!.status,
                        ),
                      ),
                      if (widget.response.transaction!.referenceId != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          'Reference',
                          widget.response.transaction!.referenceId!,
                          canCopy: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: context.borderColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Back to Wallet',
                        style: context.buttonText(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<WithdrawBloc>().add(const WithdrawReset());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'New Withdrawal',
                        style: context.buttonText(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool canCopy = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyM.copyWith(
            color: context.textSecondary,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: context.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? context.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied to clipboard',
                          style: context.bodyS.copyWith(color: Colors.white),
                        ),
                        backgroundColor: context.colors.primary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return context.priceUpColor;
      case 'pending':
      case 'processing':
        return context.warningColor;
      case 'failed':
      case 'rejected':
        return context.priceDownColor;
      default:
        return context.textPrimary;
    }
  }
}

// Custom painter for animated checkmark
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
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (progress > 0) {
      // Draw checkmark
      final firstLineProgress = (progress * 2).clamp(0.0, 1.0);
      if (firstLineProgress > 0) {
        path.moveTo(centerX - 20, centerY);
        path.lineTo(
          centerX - 20 + (15 * firstLineProgress),
          centerY + (15 * firstLineProgress),
        );
      }

      if (progress > 0.5) {
        final secondLineProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
        path.lineTo(
          centerX - 5 + (25 * secondLineProgress),
          centerY + 15 - (30 * secondLineProgress),
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
