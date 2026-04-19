import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/constants/api_constants.dart';
import '../../../domain/entities/deposit_gateway_entity.dart';
import '../../../domain/entities/deposit_method_entity.dart';
import '../../bloc/deposit_bloc.dart';

class DepositMethodsList extends StatefulWidget {
  final String currency;
  final String? selectedMethodId;
  final Function(String) onMethodSelected;
  final Function(DepositGatewayEntity)? onStripeGatewaySelected;

  const DepositMethodsList({
    super.key,
    required this.currency,
    required this.selectedMethodId,
    required this.onMethodSelected,
    this.onStripeGatewaySelected,
  });

  @override
  State<DepositMethodsList> createState() => _DepositMethodsListState();
}

class _DepositMethodsListState extends State<DepositMethodsList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Trigger deposit methods fetch when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepositBloc>().add(
            DepositMethodsRequested(currency: widget.currency),
          );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositBloc, DepositState>(
      builder: (context, state) {
        if (state is DepositLoading) {
          return _buildLoadingState();
        }

        if (state is DepositError) {
          return _buildErrorState(state.failure.message);
        }

        if (state is DepositMethodsLoaded) {
          return _buildMethodsContent(state.gateways, state.methods);
        }

        // Initial state or other states
        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading payment methods...',
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.priceDownColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: context.priceDownColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to Load Methods',
              style: context.bodyL.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage,
              style: context.bodyS.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<DepositBloc>().add(
                      DepositMethodsRequested(currency: widget.currency),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Retry',
                    style: context.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsContent(
    List<DepositGatewayEntity> gateways,
    List<DepositMethodEntity> methods,
  ) {
    if (gateways.isEmpty && methods.isEmpty) {
      return _buildEmptyState();
    }

    // Filter based on search
    final filteredGateways = gateways.where((gateway) {
      final query = _searchQuery.toLowerCase();
      return gateway.title.toLowerCase().contains(query) ||
          gateway.description.toLowerCase().contains(query) ||
          (gateway.alias?.toLowerCase().contains(query) ?? false);
    }).toList();

    final filteredMethods = methods.where((method) {
      final query = _searchQuery.toLowerCase();
      return method.title.toLowerCase().contains(query) ||
          method.instructions.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Compact Search Bar
        Container(
          height: 36,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: context.bodyS.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search payment methods...',
              hintStyle: context.bodyS.copyWith(color: context.textTertiary),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.textTertiary,
                size: 18,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: context.textTertiary,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),

        // Methods List
        Expanded(
          child: filteredGateways.isEmpty && filteredMethods.isEmpty
              ? _buildNoResultsState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      // Payment Gateways Section
                      if (filteredGateways.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Payment Gateways',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...filteredGateways.asMap().entries.map((entry) {
                          final index = entry.key;
                          final gateway = entry.value;
                          return AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              final delay = index * 0.05;
                              final progress = (_fadeAnimation.value - delay)
                                  .clamp(0.0, 1.0);
                              return Transform.translate(
                                offset: Offset(0, 10 * (1 - progress)),
                                child: Opacity(
                                  opacity: progress,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildCompactGatewayCard(gateway),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        if (filteredMethods.isNotEmpty)
                          const SizedBox(height: 12),
                      ],

                      // Manual Methods Section
                      if (filteredMethods.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Manual Methods',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...filteredMethods.asMap().entries.map((entry) {
                          final index = entry.key;
                          final method = entry.value;
                          final totalIndex = filteredGateways.length + index;
                          return AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              final delay = totalIndex * 0.05;
                              final progress = (_fadeAnimation.value - delay)
                                  .clamp(0.0, 1.0);
                              return Transform.translate(
                                offset: Offset(0, 10 * (1 - progress)),
                                child: Opacity(
                                  opacity: progress,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildCompactMethodCard(method),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.borderColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment_outlined,
                size: 40,
                color: context.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Payment Methods',
              style: context.bodyL.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No deposit methods are available for ${widget.currency}.',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 36,
            color: context.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'No results found',
            style: context.bodyM.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with a different term',
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactGatewayCard(DepositGatewayEntity gateway) {
    final isSelected = widget.selectedMethodId == gateway.id;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  context.colors.primary.withValues(alpha: 0.1),
                  context.colors.primary.withValues(alpha: 0.05),
                ]
              : [
                  context.cardBackground,
                  context.cardBackground.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.4)
              : context.borderColor.withValues(alpha: 0.2),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (gateway.alias?.toLowerCase() == 'stripe' &&
                widget.onStripeGatewaySelected != null) {
              widget.onStripeGatewaySelected!(gateway);
            } else {
              widget.onMethodSelected(gateway.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Compact Gateway Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getGatewayColor(gateway.alias ?? gateway.name),
                        _getGatewayColor(gateway.alias ?? gateway.name)
                            .withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: gateway.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            gateway.image!.startsWith('http')
                                ? gateway.image!
                                : '${ApiConstants.baseUrl}${gateway.image}',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _getGatewayIcon(gateway.alias ?? gateway.name),
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : Icon(
                          _getGatewayIcon(gateway.alias ?? gateway.name),
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),

                // Gateway Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gateway.title,
                              style: context.bodyM.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (gateway.percentageFee != null ||
                              gateway.fixedFee != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.priceUpColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                gateway.percentageFee != null
                                    ? '${gateway.percentageFee}%'
                                    : '\$${gateway.fixedFee!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: context.priceUpColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gateway.description,
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              context.colors.primary,
                              context.colors.primary.withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: context.borderColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMethodCard(DepositMethodEntity method) {
    final isSelected = widget.selectedMethodId == method.id;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  context.colors.primary.withValues(alpha: 0.1),
                  context.colors.primary.withValues(alpha: 0.05),
                ]
              : [
                  context.cardBackground,
                  context.cardBackground.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.4)
              : context.borderColor.withValues(alpha: 0.2),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onMethodSelected(method.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Method Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.warningColor,
                        context.warningColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: method.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            method.image!.startsWith('http')
                                ? method.image!
                                : '${ApiConstants.baseUrl}${method.image}',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_balance_rounded,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),

                // Method Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.title,
                              style: context.bodyM.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.warningColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MANUAL',
                              style: TextStyle(
                                color: context.warningColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        method.instructions,
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              context.colors.primary,
                              context.colors.primary.withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: context.borderColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGatewayColor(String alias) {
    switch (alias.toLowerCase()) {
      case 'stripe':
        return const Color(0xFF635BFF);
      case 'paypal':
        return const Color(0xFF0070BA);
      case 'razorpay':
        return const Color(0xFF528FF0);
      case 'flutterwave':
        return const Color(0xFFF5A623);
      case 'paystack':
        return const Color(0xFF011B33);
      case 'coinbase':
        return const Color(0xFF0052FF);
      case 'square':
        return const Color(0xFF3A3A3A);
      case 'mollie':
        return const Color(0xFF02D4F8);
      default:
        return context.colors.primary;
    }
  }

  IconData _getGatewayIcon(String alias) {
    switch (alias.toLowerCase()) {
      case 'stripe':
        return Icons.credit_card_rounded;
      case 'paypal':
        return Icons.account_balance_wallet_rounded;
      case 'razorpay':
        return Icons.payment_rounded;
      case 'flutterwave':
        return Icons.waves_rounded;
      case 'paystack':
        return Icons.layers_rounded;
      case 'coinbase':
        return Icons.currency_bitcoin_rounded;
      case 'square':
        return Icons.crop_square_rounded;
      case 'mollie':
        return Icons.euro_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}
