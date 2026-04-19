// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transfer_option_entity.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';

class SourceWalletSelectorWidget extends StatefulWidget {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final String? selectedWalletType;
  final List<CurrencyOptionEntity>? currencies;

  const SourceWalletSelectorWidget({
    super.key,
    required this.walletTypes,
    required this.transferType,
    this.selectedWalletType,
    this.currencies,
  });

  @override
  State<SourceWalletSelectorWidget> createState() =>
      _SourceWalletSelectorWidgetState();
}

class _SourceWalletSelectorWidgetState extends State<SourceWalletSelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedWalletType == null
                        ? 'Select Source Wallet'
                        : 'Select Currency',
                    style: context.h4.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.selectedWalletType == null
                        ? 'Choose the wallet type you want to transfer from'
                        : 'Choose the currency you want to transfer',
                    style: context.bodyM.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Show wallet selection if no wallet is selected yet
          if (widget.selectedWalletType == null) ...[
            // Wallet Type Grid with animations
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: widget.walletTypes.length,
                itemBuilder: (context, index) {
                  final wallet = widget.walletTypes[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: _WalletTypeCard(
                            wallet: wallet,
                            isSelected: widget.selectedWalletType == wallet.id,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.read<TransferBloc>().add(
                                    SourceWalletSelected(walletType: wallet.id),
                                  );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],

          // Show currency selection if wallet is selected and currencies are available
          if (widget.selectedWalletType != null &&
              widget.currencies != null &&
              widget.currencies!.isNotEmpty) ...[
            // Selected wallet type indicator with enhanced design
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colors.primary.withValues(alpha: 0.1),
                      context.colors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colors.primary,
                            context.colors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _getWalletIcon(widget.selectedWalletType!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Wallet',
                            style: context.labelM.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.walletTypes
                                .firstWhere(
                                    (w) => w.id == widget.selectedWalletType)
                                .name,
                            style: context.h6.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<TransferBloc>().add(const TransferReset());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Currency List with enhanced design
            Expanded(
              child: ListView.builder(
                itemCount: widget.currencies!.length,
                itemBuilder: (context, index) {
                  final currency = widget.currencies![index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 50)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CurrencyCard(
                              currency: currency,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.read<TransferBloc>().add(
                                      SourceCurrencySelected(
                                          currency: currency.value),
                                    );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],

          // Show loading if wallet is selected but currencies are loading
          if (widget.selectedWalletType != null &&
              (widget.currencies == null || widget.currencies!.isEmpty)) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 1),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: context.colors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.colors.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading currencies...',
                      style: context.bodyL.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to get wallet icons
  Widget _getWalletIcon(String walletType) {
    IconData iconData;
    switch (walletType) {
      case 'FIAT':
        iconData = Icons.attach_money_rounded;
        break;
      case 'SPOT':
        iconData = Icons.currency_bitcoin_rounded;
        break;
      case 'ECO':
        iconData = Icons.eco_rounded;
        break;
      case 'FUTURES':
        iconData = Icons.trending_up_rounded;
        break;
      default:
        iconData = Icons.account_balance_wallet_rounded;
    }
    return Icon(iconData, color: Colors.white, size: 20);
  }
}

class _WalletTypeCard extends StatefulWidget {
  final TransferOptionEntity wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletTypeCard({
    required this.wallet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WalletTypeCard> createState() => _WalletTypeCardState();
}

class _WalletTypeCardState extends State<_WalletTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.colors.primary.withValues(alpha: 0.2),
                          context.colors.primary.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: !widget.isSelected
                    ? context.isDarkMode
                        ? context.colors.surface
                        : context.colors.surfaceContainerHighest
                    : null,
                border: Border.all(
                  color: widget.isSelected
                      ? context.colors.primary
                      : context.borderColor.withValues(alpha: 0.5),
                  width: widget.isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: widget.isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  context.colors.primary,
                                  context.colors.primary.withValues(alpha: 0.8),
                                ],
                              )
                            : null,
                        color: !widget.isSelected
                            ? context.isDarkMode
                                ? context.colors.surfaceContainerHighest
                                : context.colors.surface
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getWalletIcon(widget.wallet.id),
                        color: widget.isSelected
                            ? Colors.white
                            : context.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        widget.wallet.name,
                        style: context.labelM.copyWith(
                          color: widget.isSelected
                              ? context.textPrimary
                              : context.textSecondary,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.wallet.id,
                      style: context.labelS.copyWith(
                        color: context.textTertiary,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getWalletIcon(String walletType) {
    switch (walletType) {
      case 'FIAT':
        return Icons.attach_money_rounded;
      case 'SPOT':
        return Icons.currency_bitcoin_rounded;
      case 'ECO':
        return Icons.eco_rounded;
      case 'FUTURES':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

class _CurrencyCard extends StatefulWidget {
  final CurrencyOptionEntity currency;
  final VoidCallback onTap;

  const _CurrencyCard({
    required this.currency,
    required this.onTap,
  });

  @override
  State<_CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<_CurrencyCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Parse balance from label
    final balance = _parseBalanceFromLabel(widget.currency.label);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.isDarkMode
                ? [
                    Colors.white.withValues(alpha: _isPressed ? 0.08 : 0.05),
                    Colors.white.withValues(alpha: _isPressed ? 0.05 : 0.03),
                  ]
                : [
                    Colors.black.withValues(alpha: _isPressed ? 0.05 : 0.03),
                    Colors.black.withValues(alpha: _isPressed ? 0.03 : 0.01),
                  ],
          ),
          border: Border.all(
            color: _isPressed
                ? context.colors.primary.withValues(alpha: 0.3)
                : context.borderColor.withValues(alpha: 0.5),
            width: _isPressed ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? context.colors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isPressed ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.2),
                    context.colors.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  widget.currency.value
                      .toUpperCase()
                      .substring(0, widget.currency.value.length >= 2 ? 2 : 1),
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currency.value.toUpperCase(),
                    style: context.h6.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Balance: ${balance.toStringAsFixed(2)}',
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Available',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.textTertiary,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _parseBalanceFromLabel(String label) {
    // Format: "usd - 52.76" -> extract 52.76
    final parts = label.split(' - ');
    if (parts.length >= 2) {
      try {
        return double.parse(parts[1]);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }
}
