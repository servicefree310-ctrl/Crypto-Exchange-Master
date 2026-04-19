import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';

/// P2P Loading Widget - KuCoin style
class P2PLoadingWidget extends StatelessWidget {
  const P2PLoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.size = 32.0,
  });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// P2P Error Widget - KuCoin style
class P2PErrorWidget extends StatelessWidget {
  const P2PErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// P2P Empty State Widget - KuCoin style
class P2PEmptyStateWidget extends StatelessWidget {
  const P2PEmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.illustration,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: context.colors.primary,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// P2P Shimmer Loading for list items
class P2PShimmerLoading extends StatelessWidget {
  const P2PShimmerLoading({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildShimmerBox(48, 48, isCircle: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerBox(100, 16),
                    const SizedBox(height: 8),
                    _buildShimmerBox(150, 14),
                  ],
                ),
              ),
              _buildShimmerBox(60, 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(double width, double height,
      {bool isCircle = false}) {
    return Builder(
      builder: (context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.textSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(isCircle ? height / 2 : 4),
        ),
      ),
    );
  }
}

/// P2P Network Status Widget
class P2PNetworkStatusWidget extends StatelessWidget {
  const P2PNetworkStatusWidget({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return P2PErrorWidget(
      message: 'Please check your network connection and try again.',
      onRetry: onRetry,
    );
  }
}

/// P2P Maintenance Widget
class P2PMaintenanceWidget extends StatelessWidget {
  const P2PMaintenanceWidget({
    super.key,
    this.title = 'Maintenance Mode',
    this.message =
        'P2P trading is temporarily unavailable for maintenance. Please try again later.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_outlined,
                size: 64,
                color: context.warningColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
