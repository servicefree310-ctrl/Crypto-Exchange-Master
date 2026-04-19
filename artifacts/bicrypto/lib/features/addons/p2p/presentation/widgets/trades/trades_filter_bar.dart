import 'package:flutter/material.dart';

class TradesFilterBar extends StatefulWidget {
  const TradesFilterBar({
    super.key,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final Function(Map<String, dynamic> filters) onFilterChanged;
  final Function(String sortBy, bool ascending) onSortChanged;

  @override
  State<TradesFilterBar> createState() => _TradesFilterBarState();
}

class _TradesFilterBarState extends State<TradesFilterBar> {
  String _selectedSort = 'updatedAt';
  bool _ascending = false;
  String? _selectedCurrency;
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1C1E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort dropdown
          Expanded(
            child: _FilterDropdown(
              value: _selectedSort,
              hint: 'Sort by',
              icon: Icons.sort,
              items: const [
                {'value': 'updatedAt', 'label': 'Last Updated'},
                {'value': 'createdAt', 'label': 'Date Created'},
                {'value': 'amount', 'label': 'Amount'},
                {'value': 'price', 'label': 'Price'},
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                widget.onSortChanged(_selectedSort, _ascending);
              },
            ),
          ),

          const SizedBox(width: 8),

          // Sort direction toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _ascending = !_ascending;
              });
              widget.onSortChanged(_selectedSort, _ascending);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3A3A3C)),
              ),
              child: Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                color: const Color(0xFF24CE85),
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // More filters button
          GestureDetector(
            onTap: _showMoreFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3A3A3C)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Color(0xFF8E8E93),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FiltersBottomSheet(
        selectedCurrency: _selectedCurrency,
        selectedPaymentMethod: _selectedPaymentMethod,
        onApply: (currency, paymentMethod) {
          setState(() {
            _selectedCurrency = currency;
            _selectedPaymentMethod = paymentMethod;
          });

          widget.onFilterChanged({
            'currency': currency,
            'paymentMethod': paymentMethod,
          });
        },
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final IconData icon;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Row(
          children: [
            Icon(icon, color: const Color(0xFF8E8E93), size: 16),
            const SizedBox(width: 8),
            Text(
              hint,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: const Color(0xFF2C2C2E),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  const _FiltersBottomSheet({
    required this.selectedCurrency,
    required this.selectedPaymentMethod,
    required this.onApply,
  });

  final String? selectedCurrency;
  final String? selectedPaymentMethod;
  final Function(String?, String?) onApply;

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  String? _currency;
  String? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _currency = widget.selectedCurrency;
    _paymentMethod = widget.selectedPaymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Trades',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currency = null;
                    _paymentMethod = null;
                  });
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Color(0xFF24CE85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Currency Filter
          const Text(
            'Currency',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            value: _currency,
            hint: 'All Currencies',
            icon: Icons.currency_bitcoin,
            items: const [
              {'value': 'BTC', 'label': 'Bitcoin (BTC)'},
              {'value': 'USDT', 'label': 'Tether (USDT)'},
              {'value': 'ETH', 'label': 'Ethereum (ETH)'},
              {'value': 'BNB', 'label': 'BNB'},
            ],
            onChanged: (value) {
              setState(() {
                _currency = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Payment Method Filter
          const Text(
            'Payment Method',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            value: _paymentMethod,
            hint: 'All Payment Methods',
            icon: Icons.payment,
            items: const [
              {'value': 'bank_transfer', 'label': 'Bank Transfer'},
              {'value': 'paypal', 'label': 'PayPal'},
              {'value': 'cash', 'label': 'Cash'},
              {'value': 'revolut', 'label': 'Revolut'},
            ],
            onChanged: (value) {
              setState(() {
                _paymentMethod = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_currency, _paymentMethod);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24CE85),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
