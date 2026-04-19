import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../bloc/deposit_bloc.dart';
import '../../../domain/entities/currency_option_entity.dart';

class CurrencySelector extends StatefulWidget {
  final String walletType;
  final String? selectedCurrency;
  final Function(String) onCurrencySelected;

  const CurrencySelector({
    super.key,
    required this.walletType,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger currency options fetch when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepositBloc>().add(
            CurrencyOptionsRequested(walletType: widget.walletType),
          );
    });
  }

  @override
  void dispose() {
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

        if (state is CurrencyOptionsLoaded) {
          return _buildCurrencyContent(state.currencies);
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
          const SizedBox(height: 16),
          Text(
            'Loading currencies...',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.priceDownColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.priceDownColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Currencies',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<DepositBloc>().add(
                    CurrencyOptionsRequested(walletType: widget.walletType),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 20),
                const SizedBox(width: 8),
                const Text('Retry'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyContent(List<CurrencyOptionEntity> currencies) {
    if (currencies.isEmpty) {
      return _buildEmptyState();
    }

    // Filter currencies based on search
    final filteredCurrencies = currencies.where((currency) {
      final query = _searchQuery.toLowerCase();
      return currency.value.toLowerCase().contains(query) ||
          currency.label.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: context.bodyM.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search currency...',
              hintStyle: context.bodyM.copyWith(color: context.textTertiary),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.textTertiary,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: context.textTertiary,
                        size: 20,
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
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        // Currency List
        Expanded(
          child: filteredCurrencies.isEmpty
              ? _buildNoResultsState()
              : ListView.builder(
                  itemCount: filteredCurrencies.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final currency = filteredCurrencies[index];
                    final isSelected =
                        widget.selectedCurrency == currency.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCurrencyCard(currency, isSelected),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.borderColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.currency_exchange_rounded,
              size: 48,
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Currencies Available',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No ${widget.walletType} currencies are currently available for deposits.',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
            size: 48,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: context.bodyL.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different term',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(CurrencyOptionEntity currency, bool isSelected) {
    // Extract currency code and name from the label
    // Format is "USD - United States Dollar"
    final parts = currency.label.split(' - ');
    final currencyCode = parts.isNotEmpty ? parts[0] : currency.value;
    final currencyName = parts.length > 1 ? parts[1] : currency.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => widget.onCurrencySelected(currency.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Currency Icon with Gradient
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCurrencyColor(currencyCode),
                        _getCurrencyColor(currencyCode).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getCurrencyColor(currencyCode).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getCurrencySymbol(currencyCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Currency Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currencyCode,
                            style: context.h6.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.priceUpColor.withValues(alpha: 0.2),
                                  context.priceUpColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: context.priceUpColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              widget.walletType,
                              style: TextStyle(
                                color: context.priceUpColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyName,
                        style: context.bodyM.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection Indicator with Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 28 : 24,
                  height: isSelected ? 28 : 24,
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
                            color: context.borderColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.colors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
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

  Color _getCurrencyColor(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return const Color(0xFF10B981);
      case 'EUR':
        return const Color(0xFF3B82F6);
      case 'GBP':
        return const Color(0xFF8B5CF6);
      case 'JPY':
        return const Color(0xFFEF4444);
      case 'CAD':
        return const Color(0xFFF59E0B);
      case 'AUD':
        return const Color(0xFF06B6D4);
      case 'CHF':
        return const Color(0xFFEC4899);
      case 'AED':
        return const Color(0xFFEAB308);
      case 'ZAR':
        return const Color(0xFF84CC16);
      default:
        return context.colors.primary;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'Fr';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'AED':
        return 'د.إ';
      case 'ZAR':
        return 'R';
      default:
        return currency.substring(0, 1);
    }
  }
}
