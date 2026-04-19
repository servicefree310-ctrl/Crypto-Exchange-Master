import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';

/// Filter bar for P2P Buy page
/// Allows filtering by crypto currency, fiat currency, payment methods, price range, etc.
class P2PBuyFilterBar extends StatefulWidget {
  const P2PBuyFilterBar({
    super.key,
    required this.cryptoCurrencies,
    required this.fiatCurrencies,
    required this.paymentMethods,
    required this.onFiltersChanged,
  });

  final List<String> cryptoCurrencies;
  final List<String> fiatCurrencies;
  final List<String> paymentMethods;
  final Function(Map<String, dynamic>) onFiltersChanged;

  @override
  State<P2PBuyFilterBar> createState() => _P2PBuyFilterBarState();
}

class _P2PBuyFilterBarState extends State<P2PBuyFilterBar> {
  String selectedCrypto = 'All';
  String selectedFiat = 'All';
  String selectedPayment = 'All';
  bool showAdvancedFilters = false;
  double minAmount = 0;
  double maxAmount = 10000;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: Column(
        children: [
          // Basic filters
          _buildBasicFilters(context),

          // Advanced filters toggle
          if (showAdvancedFilters) _buildAdvancedFilters(context),

          // Filter actions
          _buildFilterActions(context),
        ],
      ),
    );
  }

  Widget _buildBasicFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Crypto filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Crypto',
              selectedCrypto,
              widget.cryptoCurrencies,
              (value) => setState(() {
                selectedCrypto = value;
                _applyFilters();
              }),
            ),
          ),
          const SizedBox(width: 8),

          // Fiat filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Currency',
              selectedFiat,
              widget.fiatCurrencies,
              (value) => setState(() {
                selectedFiat = value;
                _applyFilters();
              }),
            ),
          ),
          const SizedBox(width: 8),

          // Payment method filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Payment',
              selectedPayment,
              widget.paymentMethods,
              (value) => setState(() {
                selectedPayment = value;
                _applyFilters();
              }),
            ),
          ),
          const SizedBox(width: 8),

          // Advanced filter toggle
          IconButton(
            onPressed: () => setState(() {
              showAdvancedFilters = !showAdvancedFilters;
            }),
            icon: Icon(
              showAdvancedFilters ? Icons.expand_less : Icons.tune,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            label,
            style: context.bodyS.copyWith(color: context.textSecondary),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: context.bodyS.copyWith(
                  color: context.textPrimary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) => onChanged(value ?? items.first),
          icon: Icon(
            Icons.arrow_drop_down,
            color: context.textSecondary,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount Range',
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Amount range slider
          RangeSlider(
            values: RangeValues(minAmount, maxAmount),
            min: 0,
            max: 100000,
            divisions: 100,
            labels: RangeLabels(
              '\$${minAmount.toInt()}',
              '\$${maxAmount.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                minAmount = values.start;
                maxAmount = values.end;
              });
            },
            onChangeEnd: (values) => _applyFilters(),
          ),

          // Amount range display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: \$${minAmount.toInt()}',
                style: context.bodyS.copyWith(color: context.textSecondary),
              ),
              Text(
                'Max: \$${maxAmount.toInt()}',
                style: context.bodyS.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Clear filters
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          const Spacer(),

          // Apply filters button
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.buyColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Apply',
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedCrypto = 'All';
      selectedFiat = 'All';
      selectedPayment = 'All';
      minAmount = 0;
      maxAmount = 10000;
      showAdvancedFilters = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'cryptoCurrency': selectedCrypto == 'All' ? null : selectedCrypto,
      'fiatCurrency': selectedFiat == 'All' ? null : selectedFiat,
      'paymentMethod': selectedPayment == 'All' ? null : selectedPayment,
      'minAmount': minAmount > 0 ? minAmount : null,
      'maxAmount': maxAmount < 10000 ? maxAmount : null,
    };

    widget.onFiltersChanged(filters);
  }
}
