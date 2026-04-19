import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 3: Cryptocurrency Selection
class Step3SelectCrypto extends StatefulWidget {
  const Step3SelectCrypto({
    super.key,
    required this.bloc,
  });

  final CreateOfferBloc bloc;

  @override
  State<Step3SelectCrypto> createState() => _Step3SelectCryptoState();
}

class _Step3SelectCryptoState extends State<Step3SelectCrypto> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCurrencies);

    // Fetch currencies when step is initialized
    final state = widget.bloc.state;
    if (state is CreateOfferEditing && state.walletType != null) {
      widget.bloc
          .add(CreateOfferFetchCurrencies(walletType: state.walletType!));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final state = widget.bloc.state;
    if (state is CreateOfferEditing) {
      final availableCurrencies =
          state.formData['availableCurrencies'] as List<dynamic>? ?? [];
      final query = _searchController.text.toLowerCase();

      setState(() {
        if (query.isEmpty) {
          _filteredCurrencies = availableCurrencies;
        } else {
          _filteredCurrencies = availableCurrencies.where((currency) {
            final symbol =
                (currency['currency'] ?? '').toString().toLowerCase();
            final name = (currency['name'] ?? '').toString().toLowerCase();
            return symbol.contains(query) || name.contains(query);
          }).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferBloc, CreateOfferState>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is! CreateOfferEditing) {
          return const Center(child: CircularProgressIndicator());
        }

        final selectedCurrency = state.currency;
        final walletType = state.walletType;
        final availableCurrencies =
            state.formData['availableCurrencies'] as List<dynamic>? ?? [];
        final isLoading = state.isLoading;

        // Update filtered currencies when available currencies change
        if (_filteredCurrencies.isEmpty && availableCurrencies.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _filteredCurrencies = availableCurrencies;
            });
          });
        }

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Cryptocurrency',
                    style: context.h5.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose which cryptocurrency to trade from your ${_getWalletDisplayName(walletType)} wallet',
                    style: context.bodyM.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search cryptocurrencies...',
                      prefixIcon:
                          Icon(Icons.search, color: context.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: context.colors.primary, width: 2),
                      ),
                      fillColor: context.cardBackground,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),

            // Currency List
            Expanded(
              child: _buildCurrencyList(context, isLoading, selectedCurrency),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrencyList(
      BuildContext context, bool isLoading, String? selectedCurrency) {
    if (isLoading && _filteredCurrencies.isEmpty) {
      return _buildLoadingState(context);
    }

    if (_filteredCurrencies.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredCurrencies.length,
      itemBuilder: (context, index) {
        final currency = _filteredCurrencies[index];
        final symbol = currency['currency'] ?? '';
        final name = currency['name'] ?? '';
        final network = currency['network'] ?? '';
        final isSelected = selectedCurrency == symbol;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildCurrencyCard(
            context: context,
            symbol: symbol,
            name: name,
            network: network,
            isSelected: isSelected,
            onTap: () {
              widget.bloc.add(CreateOfferCurrencySelected(currency: symbol));
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrencyCard({
    required BuildContext context,
    required String symbol,
    required String name,
    required String network,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Currency Icon/Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  symbol
                      .substring(0, symbol.length > 3 ? 3 : symbol.length)
                      .toUpperCase(),
                  style: context.bodyM.copyWith(
                    color: isSelected ? Colors.white : context.colors.primary,
                    fontWeight: FontWeight.bold,
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
                  Text(
                    symbol.toUpperCase(),
                    style: context.bodyL.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (name.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (network.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        network.toUpperCase(),
                        style: context.bodyS.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selection Indicator
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading cryptocurrencies...',
            style: context.bodyM.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: context.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No cryptocurrencies found',
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'No currencies available for this wallet type',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getWalletDisplayName(String? walletType) {
    switch (walletType) {
      case 'FIAT':
        return 'Fiat';
      case 'SPOT':
        return 'Spot';
      case 'ECO':
        return 'Ecosystem';
      default:
        return 'selected';
    }
  }
}
