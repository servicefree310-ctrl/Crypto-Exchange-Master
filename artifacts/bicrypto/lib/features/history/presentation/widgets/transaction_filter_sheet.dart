import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    super.key,
    required this.onFilterApplied,
    required this.onFilterCleared,
    this.currentFilter,
  });

  final Function(TransactionFilterEntity) onFilterApplied;
  final VoidCallback onFilterCleared;
  final TransactionFilterEntity? currentFilter;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionType? _selectedType;
  late TransactionStatus? _selectedStatus;
  late String? _selectedWalletType;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter?.type;
    _selectedStatus = widget.currentFilter?.status;
    _selectedWalletType = widget.currentFilter?.walletType;
    _startDate = widget.currentFilter?.startDate;
    _endDate = widget.currentFilter?.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filter Transactions',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear',
                    style: TextStyle(color: context.colors.primary),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textTertiary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Filter Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Filter
                  _buildSectionTitle(context, 'Transaction Type'),
                  const SizedBox(height: 12),
                  _buildTypeChips(context),
                  const SizedBox(height: 24),

                  // Status Filter
                  _buildSectionTitle(context, 'Status'),
                  const SizedBox(height: 12),
                  _buildStatusChips(context),
                  const SizedBox(height: 24),

                  // Wallet Type Filter
                  _buildSectionTitle(context, 'Wallet Type'),
                  const SizedBox(height: 12),
                  _buildWalletTypeChips(context),
                  const SizedBox(height: 24),

                  // Date Range Filter
                  _buildSectionTitle(context, 'Date Range'),
                  const SizedBox(height: 12),
                  _buildDateRangeSelector(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBackground,
              border: Border(
                top: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.bodyL.copyWith(
        fontWeight: FontWeight.w600,
        color: context.textPrimary,
      ),
    );
  }

  Widget _buildTypeChips(BuildContext context) {
    final types = [
      TransactionType.DEPOSIT,
      TransactionType.WITHDRAW,
      TransactionType.TRANSFER,
      TransactionType.TRADE,
      TransactionType.STAKING_STAKE,
      TransactionType.P2P_TRADE,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(_getTypeLabel(type)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedType = selected ? type : null;
            });
          },
          selectedColor: context.colors.primary,
          backgroundColor: context.background,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : context.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? context.colors.primary
                  : context.borderColor.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusChips(BuildContext context) {
    final statuses = [
      TransactionStatus.COMPLETED,
      TransactionStatus.PENDING,
      TransactionStatus.PROCESSING,
      TransactionStatus.FAILED,
      TransactionStatus.CANCELLED,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = _selectedStatus == status;
        return ChoiceChip(
          label: Text(_getStatusLabel(status)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedStatus = selected ? status : null;
            });
          },
          selectedColor: context.colors.primary,
          backgroundColor: context.background,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : context.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? context.colors.primary
                  : context.borderColor.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWalletTypeChips(BuildContext context) {
    final walletTypes = ['SPOT', 'FIAT', 'ECO', 'FUTURES'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: walletTypes.map((type) {
        final isSelected = _selectedWalletType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedWalletType = selected ? type : null;
            });
          },
          selectedColor: context.colors.primary,
          backgroundColor: context.background,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : context.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? context.colors.primary
                  : context.borderColor.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Column(
      children: [
        // Quick date options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickDateChip(context, 'Today', () {
              final now = DateTime.now();
              setState(() {
                _startDate = DateTime(now.year, now.month, now.day);
                _endDate = now;
              });
            }),
            _buildQuickDateChip(context, 'Yesterday', () {
              final yesterday =
                  DateTime.now().subtract(const Duration(days: 1));
              setState(() {
                _startDate =
                    DateTime(yesterday.year, yesterday.month, yesterday.day);
                _endDate = DateTime(
                    yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
              });
            }),
            _buildQuickDateChip(context, 'Last 7 days', () {
              final now = DateTime.now();
              setState(() {
                _startDate = now.subtract(const Duration(days: 7));
                _endDate = now;
              });
            }),
            _buildQuickDateChip(context, 'Last 30 days', () {
              final now = DateTime.now();
              setState(() {
                _startDate = now.subtract(const Duration(days: 30));
                _endDate = now;
              });
            }),
          ],
        ),
        const SizedBox(height: 16),
        // Custom date range
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                context,
                'Start Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                context,
                'End Date',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateChip(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: context.bodyS.copyWith(
            color: context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: context.colors.primary,
                  onPrimary: Colors.white,
                  onSurface: context.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.bodyS.copyWith(
                color: context.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'Select date',
              style: context.bodyM.copyWith(
                color: selectedDate != null
                    ? context.textPrimary
                    : context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOSIT:
        return 'Deposit';
      case TransactionType.WITHDRAW:
        return 'Withdraw';
      case TransactionType.TRANSFER:
        return 'Transfer';
      case TransactionType.TRADE:
        return 'Trade';
      case TransactionType.STAKING_STAKE:
        return 'Staking';
      case TransactionType.P2P_TRADE:
        return 'P2P';
      default:
        return type.name;
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.PENDING:
        return 'Pending';
      case TransactionStatus.COMPLETED:
        return 'Completed';
      case TransactionStatus.CANCELLED:
        return 'Cancelled';
      case TransactionStatus.FAILED:
        return 'Failed';
      case TransactionStatus.PROCESSING:
        return 'Processing';
      case TransactionStatus.REJECTED:
        return 'Rejected';
      case TransactionStatus.EXPIRED:
        return 'Expired';
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedWalletType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    final filter = TransactionFilterEntity(
      type: _selectedType,
      status: _selectedStatus,
      walletType: _selectedWalletType,
      startDate: _startDate,
      endDate: _endDate,
    );

    widget.onFilterApplied(filter);
    Navigator.pop(context);
  }
}
