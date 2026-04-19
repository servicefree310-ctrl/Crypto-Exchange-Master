import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../bloc/spot_deposit_bloc.dart';
import '../../bloc/spot_deposit_state.dart';

class SpotCurrencySelector extends StatefulWidget {
  const SpotCurrencySelector({
    super.key,
    required this.onCurrencySelected,
  });

  final Function(String) onCurrencySelected;

  @override
  State<SpotCurrencySelector> createState() => _SpotCurrencySelectorState();
}

class _SpotCurrencySelectorState extends State<SpotCurrencySelector>
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
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
              hintText: 'Search cryptocurrency...',
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

        // Currency List
        Expanded(
          child: BlocBuilder<SpotDepositBloc, SpotDepositState>(
            builder: (context, state) {
              if (state is SpotCurrenciesLoaded) {
                // Filter currencies based on search
                final filteredCurrencies = state.currencies.where((currency) {
                  final query = _searchQuery.toLowerCase();
                  return currency.label.toLowerCase().contains(query) ||
                      currency.value.toLowerCase().contains(query);
                }).toList();

                if (filteredCurrencies.isEmpty) {
                  return _buildNoResultsState();
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];
                      return AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          final delay = index * 0.05;
                          final progress =
                              (_fadeAnimation.value - delay).clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, 10 * (1 - progress)),
                            child: Opacity(
                              opacity: progress,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildCurrencyCard(currency),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyCard(dynamic currency) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardBackground,
            context.cardBackground.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onCurrencySelected(currency.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Currency Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.2),
                        Colors.blue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: currency.icon != null
                        ? Image.network(
                            currency.icon!.startsWith('http')
                                ? currency.icon!
                                : '${ApiConstants.baseUrl}${currency.icon}',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.currency_bitcoin_rounded,
                                color: Colors.blue,
                                size: 20,
                              );
                            },
                          )
                        : Icon(
                            Icons.currency_bitcoin_rounded,
                            color: Colors.blue,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Currency Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.label,
                        style: context.bodyM.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currency.value.toUpperCase(),
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.textTertiary,
                  size: 14,
                ),
              ],
            ),
          ),
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
            'No currencies found',
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
}
