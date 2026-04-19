import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../features/settings/presentation/widgets/settings_provider.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../../../injection/injection.dart';

class ChartTradingButtons extends StatelessWidget {
  const ChartTradingButtons({
    super.key,
    required this.symbol,
    required this.currentPrice,
    this.onBuyPressed,
    this.onSellPressed,
    this.marketData, // Add market data for passing to trade page
  });

  final String symbol;
  final String currentPrice;
  final VoidCallback? onBuyPressed;
  final VoidCallback? onSellPressed;
  final dynamic marketData; // Market data to pass to trade page

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // BUY
            Expanded(
              child: _GradientActionButton(
                label: 'BUY',
                gradient: [
                  context.priceUpColor,
                  context.priceUpColor.withValues(alpha: 0.8),
                ],
                icon: Icons.add_circle_outline,
                onPressed:
                    onBuyPressed ?? () => _navigateToTrade(context, 'BUY'),
                isBuy: true,
              ),
            ),
            const SizedBox(width: 12),
            // SELL
            Expanded(
              child: _GradientActionButton(
                label: 'SELL',
                gradient: [
                  context.priceDownColor,
                  context.priceDownColor.withValues(alpha: 0.8),
                ],
                icon: Icons.remove_circle_outline,
                onPressed:
                    onSellPressed ?? () => _navigateToTrade(context, 'SELL'),
                isBuy: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTrade(BuildContext context, String action) {
    // Navigate to HomePage with Trading tab selected
    // This ensures the bottom navigation bar is visible
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: getIt<AuthBloc>(),
            ),
            BlocProvider.value(
              value: getIt<ProfileBloc>(),
            ),
          ],
          child: SettingsProvider(
            child: HomePage(
              initialTabKey: 'trade', // Use tab key instead of index
              tradingSymbol: symbol,
              tradingMarketData: marketData,
              tradingInitialAction: action,
            ),
          ),
        ),
      ),
      (route) => false, // Remove all previous routes
    );
  }
}

class _GradientActionButton extends StatefulWidget {
  const _GradientActionButton({
    required this.label,
    required this.gradient,
    required this.icon,
    required this.onPressed,
    required this.isBuy,
  });

  final String label;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isBuy;

  @override
  State<_GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<_GradientActionButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _updateScale(0.96);
        setState(() => _isPressed = true);
      },
      onTapCancel: () {
        _updateScale(1.0);
        setState(() => _isPressed = false);
      },
      onTapUp: (_) {
        _updateScale(1.0);
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPressed
                  ? widget.gradient.map((c) => c.withValues(alpha: 0.8)).toList()
                  : widget.gradient,
            ),
            borderRadius: BorderRadius.circular(12), // Reduced from 30
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: widget.gradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
            ],
            border: Border.all(
              color: widget.gradient.first.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              onTap: widget.onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isBuy ? 'Long Position' : 'Short Position',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateScale(double value) {
    setState(() => _scale = value);
  }
}
