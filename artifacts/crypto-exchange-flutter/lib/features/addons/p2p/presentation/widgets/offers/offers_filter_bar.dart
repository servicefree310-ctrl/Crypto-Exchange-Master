import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';

/// P2P Offers Filter Bar - KuCoin style compact filters
/// Provides currency selection, sorting, and filtering options
class OffersFilterBar extends StatefulWidget {
  const OffersFilterBar({
    super.key,
    required this.tradingPairs,
    required this.onFiltersChanged,
    this.initialFilters = const {},
  });

  final List<String> tradingPairs;
  final ValueChanged<Map<String, dynamic>> onFiltersChanged;
  final Map<String, dynamic> initialFilters;

  @override
  State<OffersFilterBar> createState() => _OffersFilterBarState();
}

class _OffersFilterBarState extends State<OffersFilterBar> {
  late String _selectedPair;
  String _sortBy = 'price';
  bool _sortAscending = true;
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _selectedPair = widget.tradingPairs.first;
    _filters = Map.from(widget.initialFilters);
  }

  void _updateFilters() {
    _filters['currency'] = _selectedPair == 'All' ? null : _selectedPair;
    _filters['sortBy'] = _sortBy;
    _filters['sortAscending'] = _sortAscending;
    widget.onFiltersChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Currency selection chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.tradingPairs.length,
              itemBuilder: (context, index) {
                final pair = widget.tradingPairs[index];
                final isSelected = pair == _selectedPair;

                return Container(
                  margin: EdgeInsets.only(
                      right: index == widget.tradingPairs.length - 1 ? 0 : 8),
                  child: FilterChip(
                    label: Text(
                      pair,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? context.textSecondary
                                : context.textSecondary),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPair = pair);
                        _updateFilters();
                      }
                    },
                    backgroundColor:
                        context.cardBackground,
                    selectedColor: context.colors.primary,
                    side: BorderSide(
                      color: isSelected
                          ? context.colors.primary
                          : (isDark
                              ? context.borderColor
                              : context.borderColor),
                    ),
                    showCheckmark: false,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Sort and filter options
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: _buildSortDropdown(isDark),
              ),

              const SizedBox(width: 12),

              // Sort direction toggle
              _buildSortDirectionButton(isDark),

              const SizedBox(width: 12),

              // Advanced filters button
              _buildAdvancedFiltersButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(bool isDark) {
    final sortOptions = [
      {'value': 'price', 'label': 'Price'},
      {'value': 'amount', 'label': 'Amount'},
      {'value': 'created', 'label': 'Latest'},
      {'value': 'completion', 'label': 'Completion Rate'},
    ];

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: isDark
                ? context.textSecondary
                : context.textSecondary,
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          dropdownColor: context.cardBackground,
          items: sortOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _sortBy = value);
              _updateFilters();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortDirectionButton(bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: IconButton(
        onPressed: () {
          setState(() => _sortAscending = !_sortAscending);
          _updateFilters();
        },
        padding: EdgeInsets.zero,
        icon: Icon(
          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: context.colors.primary,
        ),
        tooltip: _sortAscending ? 'Ascending' : 'Descending',
      ),
    );
  }

  Widget _buildAdvancedFiltersButton(bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: IconButton(
        onPressed: () => _showAdvancedFilters(context),
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.tune,
          size: 16,
          color: isDark
              ? context.textSecondary
              : context.textSecondary,
        ),
        tooltip: 'Advanced Filters',
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFiltersSheet(),
    );
  }

  Widget _buildAdvancedFiltersSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Advanced Filters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() => _filters.clear());
                            _updateFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFilterSection(
                      'Payment Methods',
                      [
                        'Bank Transfer',
                        'PayPal',
                        'Cash',
                        'Wise',
                        'Revolut',
                        'Zelle',
                      ],
                      isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildFilterSection(
                      'Trader Requirements',
                      [
                        'Verified Only',
                        'High Completion Rate',
                        'Experienced Traders',
                      ],
                      isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildPriceRangeFilter(isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected =
                _filters[title.toLowerCase().replaceAll(' ', '_')]
                        ?.contains(option) ??
                    false;

            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? context.textSecondary
                          : context.textSecondary),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final key = title.toLowerCase().replaceAll(' ', '_');
                _filters[key] ??= <String>[];
                if (selected) {
                  (_filters[key] as List<String>).add(option);
                } else {
                  (_filters[key] as List<String>).remove(option);
                }
                setState(() {});
              },
              backgroundColor:
                  context.cardBackground,
              selectedColor: context.colors.primary,
              side: BorderSide(
                color: isSelected
                    ? context.colors.primary
                    : (context.borderColor),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range (USD)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Min',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color:
                          context.borderColor,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'to',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? context.textSecondary
                        : context.textSecondary,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Max',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color:
                          context.borderColor,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
