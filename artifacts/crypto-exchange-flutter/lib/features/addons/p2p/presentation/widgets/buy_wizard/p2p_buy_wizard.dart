import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../wallet/domain/entities/currency_option_entity.dart';
import 'package:mobile/features/wallet/presentation/bloc/deposit_bloc.dart';
import '../../bloc/payment_methods/payment_methods_bloc.dart';
import '../../bloc/payment_methods/payment_methods_event.dart';
import '../../bloc/payment_methods/payment_methods_state.dart';
import '../../bloc/offers/offers_bloc.dart';
import '../../bloc/offers/offers_event.dart';
import '../../bloc/offers/offers_state.dart';

import '../../../../../wallet/presentation/bloc/currency_price_bloc.dart';

class P2PBuyWizard extends StatefulWidget {
  const P2PBuyWizard({
    super.key,
    this.initialTradeType,
    this.onTradeTypeChanged,
  });

  final String? initialTradeType;
  final Function(String?)? onTradeTypeChanged;

  @override
  State<P2PBuyWizard> createState() => _P2PBuyWizardState();
}

class _P2PBuyWizardState extends State<P2PBuyWizard>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  late AnimationController _animationController;

  int _currentStep = 0;
  final int _totalSteps = 7; // ✅ V5 has 7 steps: 6 wizard steps + results

  // Form data - matching v5 structure exactly
  String? _selectedTradeType;
  String? _selectedWalletType;
  String? _selectedCurrency;
  double? _amount;
  final List<String> _selectedPaymentMethods = [];
  String _pricePreference = 'best'; // V5: best, market, average, flexible
  String _traderPreference = 'any'; // V5: any, verified, experienced, trusted
  String _location = 'any'; // V5: any or specific location
  double? _minAmount; // V5: minimum amount filter
  double? _maxAmount; // V5: maximum amount filter

  // Removed hardcoded state - now using BLoC

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Pre-select trade type if provided
    if (widget.initialTradeType != null) {
      _selectedTradeType = widget.initialTradeType;
      // Defer the callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTradeTypeChanged?.call(widget.initialTradeType!);
      });
    }

    // Initialize amount controller listener
    _amountController.addListener(() {
      final value = double.tryParse(_amountController.text);
      if (value != _amount) {
        setState(() => _amount = value);
      }
    });

    // Load initial data
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Clean Architecture - Use BLoC for price fetching
  void _fetchCurrencyPrice() {
    if (_selectedCurrency == null || _selectedWalletType == null) return;

    context.read<CurrencyPriceBloc>().add(FetchCurrencyPrice(
          currency: _selectedCurrency!,
          walletType: _selectedWalletType!,
        ));
  }

  // Clean Architecture - Use BLoC for wallet balance fetching
  void _fetchWalletBalance() {
    if (_selectedCurrency == null || _selectedWalletType == null) return;

    context.read<CurrencyPriceBloc>().add(FetchWalletBalance(
          currency: _selectedCurrency!,
          walletType: _selectedWalletType!,
        ));
  }

  // Clean Architecture - Amount validation using BLoC state
  bool _isAmountValid(CurrencyPriceState currencyState) {
    if (_selectedTradeType == 'SELL') {
      if (currencyState is CurrencyPriceLoaded &&
          currencyState.balance != null) {
        final balance = currencyState.balance!;
        if (balance <= 0) return false;
        final amount = _amount ?? 0;
        return amount > 0 && amount <= balance;
      }
      return false;
    }
    return (_amount ?? 0) > 0;
  }

  // Clean Architecture - Estimated value calculation using BLoC state
  double _getEstimatedValue(CurrencyPriceState currencyState) {
    // Use current text field value for real-time updates
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (currencyState is CurrencyPriceLoaded) {
      return amount * currencyState.price;
    }
    return 0.0;
  }

  // Clean Architecture - Max sell amount using BLoC state
  double _getMaxSellAmount(CurrencyPriceState currencyState) {
    if (_selectedTradeType == 'SELL' && currencyState is CurrencyPriceLoaded) {
      return currencyState.balance ?? 0.0;
    }
    return 0;
  }

  void _updateAmount(double newAmount) {
    setState(() => _amount = newAmount);
    _amountController.text = newAmount.toStringAsFixed(8);
    // setState automatically triggers rebuild of estimated value card
  }

  void _onCurrencyChanged(String? currency) {
    setState(() {
      _selectedCurrency = currency;
      _amount = null; // Reset amount like v5
      _amountController.clear();
    });

    // Fetch price and balance when currency changes (like v5)
    if (currency != null && _selectedWalletType != null) {
      _fetchCurrencyPrice();
      if (_selectedTradeType == 'SELL') {
        _fetchWalletBalance();
      }
    }
  }

  void _loadInitialData() {
    // Load currencies for wallet - for SPOT wallet type initially
    context
        .read<DepositBloc>()
        .add(const CurrencyOptionsRequested(walletType: 'SPOT'));
    // Load payment methods
    context.read<PaymentMethodsBloc>().add(const PaymentMethodsRequested());
  }

  void _showValidationError() {
    String message = '';
    switch (_currentStep) {
      case 0:
        message = 'Please select trade type (Buy or Sell)';
        break;
      case 1:
        message = 'Please select wallet type';
        break;
      case 2:
        message = 'Please select cryptocurrency and enter amount';
        break;
      case 3:
        message = 'Please select at least one payment method';
        break;
      default:
        message = 'Please complete this step';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _findMatches() async {
    // 🚀 V5-style guided matching - production ready with debug logging
    try {
      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Finding matches...'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // ✅ Prepare V5-compatible form data (exact match with your API payload)
      final formData = {
        'tradeType': _selectedTradeType
            ?.toLowerCase(), // ✅ NOT opposite - exact trade type
        'walletType': _selectedWalletType,
        'cryptocurrency': _selectedCurrency,
        'amount': _amountController.text.trim(),
        'paymentMethods': _selectedPaymentMethods,
        'pricePreference': _pricePreference,
        'traderPreference': _traderPreference,
        'minAmount': _minAmountController.text.trim().isEmpty
            ? ''
            : _minAmountController.text.trim(),
        'maxAmount': _maxAmountController.text.trim().isEmpty
            ? ''
            : _maxAmountController.text.trim(),
        'location': _location,
      };

      // 🔥 DEBUG LOGGING - Print payload to terminal
      dev.log('\n🚀 ===== P2P GUIDED MATCHING PAYLOAD =====');
      dev.log('📤 Sending to: /api/p2p/guided-matching');
      dev.log('📦 Payload:');
      formData.forEach((key, value) {
        if (value is List) {
          dev.log('   $key: [${value.join(', ')}]');
        } else {
          dev.log('   $key: "$value"');
        }
      });
      dev.log('============================================\n');

      // Call the V5 guided matching API endpoint
      context.read<OffersBloc>().add(GuidedMatchingRequested(
            criteria: formData,
          ));

      // Show success message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Looking for matches...'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // ✅ Show results within same page context to avoid provider scope issues
      setState(() {
        _currentStep = _totalSteps; // Move to results step
      });
    } catch (error) {
      // ❌ Handle errors properly with debug info
      dev.log('\n❌ ===== P2P GUIDED MATCHING ERROR =====');
      dev.log('Error: ${error.toString()}');
      dev.log('Stack trace: ${StackTrace.current}');
      dev.log('========================================\n');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Failed to find matches: ${error.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _findMatches,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyPriceBloc, CurrencyPriceState>(
      builder: (context, currencyState) {
        return Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swiping
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep1TradeType(),
                  _buildStep2WalletType(),
                  _buildStep3CryptoAmount(currencyState),
                  _buildStep4PaymentMethods(),
                  _buildStep5Preferences(), // ✅ Preferences including location
                  _buildStep6Summary(), // ✅ Summary & Find Matches
                  _buildStep7Results(), // ✅ Results with proper error handling
                ],
              ),
            ),
            _buildNavigationButtons(currencyState),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin:
                      EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? theme.primaryColor
                        : theme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1TradeType() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Trade Type',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Select whether you want to buy or sell cryptocurrency',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 24),
          _buildTradeTypeOption(
              'BUY',
              'Buy Crypto',
              'Purchase cryptocurrency from sellers',
              Icons.trending_up,
              Colors.green),
          const SizedBox(height: 16),
          _buildTradeTypeOption('SELL', 'Sell Crypto',
              'Sell cryptocurrency to buyers', Icons.trending_down, Colors.red),
        ],
      ),
    );
  }

  Widget _buildTradeTypeOption(
      String type, String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = _selectedTradeType == type;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTradeType = type);
        // Notify parent about trade type change for dynamic app bar
        widget.onTradeTypeChanged?.call(type);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(
            color: isSelected ? color : theme.dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? color : color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2WalletType() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Wallet Type',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Choose which wallet to use for this trade',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 24),
          _buildWalletTypeOption(
              'FIAT',
              'Fiat Wallet',
              'Traditional currency wallet',
              Icons.account_balance,
              const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildWalletTypeOption(
              'SPOT',
              'Spot Wallet',
              'Cryptocurrency trading wallet',
              Icons.currency_exchange,
              const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildWalletTypeOption('ECO', 'Ecosystem Wallet',
              'Token ecosystem wallet', Icons.eco, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildWalletTypeOption(
      String type, String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = _selectedWalletType == type;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedWalletType = type);
        // Load currencies for selected wallet type using real API
        context
            .read<DepositBloc>()
            .add(CurrencyOptionsRequested(walletType: type));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : theme.cardColor,
          border: Border.all(
              color: isSelected ? color : theme.dividerColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : null,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3CryptoAmount(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Select cryptocurrency and amount',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Choose your crypto and how much to trade',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Cryptocurrency Selection Card
                  _buildCryptocurrencyCard(),
                  const SizedBox(height: 20),

                  // Amount Input Card
                  _buildAmountCard(currencyState),
                  const SizedBox(height: 20),

                  // Quick Select Section (BUY) or Balance Actions (SELL)
                  if (_selectedTradeType == 'BUY')
                    _buildBuyQuickSelect()
                  else if (_selectedTradeType == 'SELL')
                    _buildSellActions(currencyState),

                  const SizedBox(height: 20),

                  // Estimated Value Card
                  _buildEstimatedValueCard(currencyState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptocurrencyCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.currency_bitcoin,
                      color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Cryptocurrency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            _buildCurrencySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.savings, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Amount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            _buildAmountInput(),

            // Balance info for SELL trades
            if (_selectedTradeType == 'SELL') ...[
              const SizedBox(height: 12),
              _buildBalanceChip(currencyState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceChip(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);
    final cryptoSymbol = _selectedCurrency ?? 'CRYPTO';

    if (currencyState is CurrencyPriceLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 6),
            Text(
              'Loading balance...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    double balance = 0.0;
    if (currencyState is CurrencyPriceLoaded && currencyState.balance != null) {
      balance = currencyState.balance!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet, size: 16, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            'Available: ${balance.toStringAsFixed(8)} $cryptoSymbol',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyQuickSelect() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tune, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Quick Select',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Slider
            _buildAmountSlider(),
            const SizedBox(height: 16),

            // Preset Amount Buttons
            _buildPresetAmountButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSellActions(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.speed, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Quick Sell',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // Percentage buttons in a beautiful grid
            _buildPercentageGrid(currencyState),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSlider() {
    final theme = Theme.of(context);
    final maxAmount = 1.0;
    final currentValue = (_amount ?? 0.1).clamp(0.01, maxAmount);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Amount: ${currentValue.toStringAsFixed(3)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
            Text(_selectedCurrency ?? 'CRYPTO',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: theme.primaryColor.withValues(alpha: 0.2),
            thumbColor: theme.primaryColor,
            overlayColor: theme.primaryColor.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: currentValue,
            min: 0.01,
            max: maxAmount,
            divisions: 99,
            onChanged: (value) => _updateAmount(value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.01', style: theme.textTheme.bodySmall),
            Text('0.5', style: theme.textTheme.bodySmall),
            Text('1.0', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetAmountButtons() {
    final presets = [0.1, 0.25, 0.5, 1.0];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((amount) => _buildPresetButton(amount)).toList(),
    );
  }

  Widget _buildPresetButton(double amount) {
    final theme = Theme.of(context);
    final isSelected = _amount == amount;

    return GestureDetector(
      onTap: () => _updateAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          '$amount ${_selectedCurrency ?? 'CRYPTO'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageGrid(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);
    final percentages = [
      {'label': '25%', 'value': 0.25, 'color': Colors.blue},
      {'label': '50%', 'value': 0.5, 'color': Colors.green},
      {'label': '75%', 'value': 0.75, 'color': Colors.orange},
      {'label': 'MAX', 'value': 1.0, 'color': Colors.red},
    ];

    // Get balance from BLoC state
    double availableBalance = 0.0;
    if (currencyState is CurrencyPriceLoaded && currencyState.balance != null) {
      availableBalance = currencyState.balance!;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: percentages.length,
      itemBuilder: (context, index) {
        final percentage = percentages[index];
        // Clean Architecture: use real available balance from BLoC
        final amount = availableBalance * (percentage['value'] as double);

        return GestureDetector(
          onTap: () => _updateAmount(amount),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (percentage['color'] as Color).withValues(alpha: 0.1),
                  (percentage['color'] as Color).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (percentage['color'] as Color).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  percentage['label'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: percentage['color'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount.toStringAsFixed(8), // Show full precision like v5
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelector() {
    final theme = Theme.of(context);

    return BlocBuilder<DepositBloc, DepositState>(
      builder: (context, state) {
        if (state is DepositLoading) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        if (state is CurrencyOptionsLoaded) {
          return GestureDetector(
            onTap: () => _showCurrencyPicker(state.currencies),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  if (_selectedCurrency != null) ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      child: Text(_selectedCurrency!.substring(0, 1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          )),
                    ),
                    const SizedBox(width: 12),
                    Text(_selectedCurrency!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ] else
                    Text('Select Cryptocurrency',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        )),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down,
                      color:
                          theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Text('Select wallet type first',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  )),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(List<CurrencyOptionEntity> currencies) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Select Cryptocurrency',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    return InkWell(
                      onTap: () {
                        _onCurrencyChanged(currency.value);
                        Navigator.pop(context); // ✅ Auto-close dropdown
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            // Compact crypto icon
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  currency.value.substring(0, 1).toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Currency info - compact layout
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency.value, // Show symbol prominently
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (currency.label != currency.value)
                                    Text(
                                      currency.label,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (_selectedCurrency == currency.value)
                              Icon(
                                Icons.check_circle,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountInput() {
    final theme = Theme.of(context);
    // For validation in input field, use a default state or current BLoC state
    final hasValidationError = !_isAmountValidWithDefaultState();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasValidationError ? Colors.amber : theme.dividerColor,
          width: hasValidationError ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          final newAmount = double.tryParse(value) ?? 0;
          setState(() => _amount = newAmount);
          // This triggers rebuild of estimated value card
        },
        enabled: !_isAmountDisabled(),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          suffixText: _selectedCurrency ?? 'CRYPTO',
          suffixStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isAmountDisabled() {
    if (_selectedTradeType == 'BUY') {
      return _selectedWalletType == null || _selectedCurrency == null;
    } else {
      // For SELL, also need wallet balance loaded
      return _selectedWalletType == null || _selectedCurrency == null;
    }
  }

  Widget _buildEstimatedValueCard(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final estimatedValue = _getEstimatedValue(currencyState);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Top accent bar like v5
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Value',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 4),
                      Text(
                          currencyState is CurrencyPriceLoading
                              ? 'Loading price...'
                              : currencyState is CurrencyPriceLoaded
                                  ? 'Price: \$${currencyState.price.toStringAsFixed(2)}'
                                  : _selectedCurrency == null
                                      ? 'Select cryptocurrency first'
                                      : 'Enter amount to calculate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                            fontSize: 11,
                          )),
                    ],
                  ),
                ),
                if (currencyState is CurrencyPriceLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (amount > 0 && estimatedValue > 0)
                  Text(
                    '\$${estimatedValue.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  )
                else
                  Text(
                    '\$0.00',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4PaymentMethods() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Payment Methods',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Choose your preferred payment methods',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
              builder: (context, state) {
                if (state is PaymentMethodsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PaymentMethodsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error,
                            size: 64, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Failed to load payment methods',
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<PaymentMethodsBloc>()
                              .add(const PaymentMethodsRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PaymentMethodsLoaded) {
                  final methods = state.methods;

                  if (methods.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_outlined,
                              size: 64,
                              color: theme.primaryColor.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No payment methods available',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: methods.length,
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      final isSelected =
                          _selectedPaymentMethods.contains(method.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedPaymentMethods.add(method.id);
                              } else {
                                _selectedPaymentMethods.remove(method.id);
                              }
                            });
                          },
                          title: Text(method.name),
                          subtitle: Text(method.type),
                          secondary: Icon(_getPaymentIcon(method.type)),
                        ),
                      );
                    },
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment,
                          size: 64, color: theme.primaryColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('Loading payment methods...',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
      case 'bank_transfer':
        return Icons.account_balance;
      case 'card':
      case 'credit_card':
        return Icons.credit_card;
      case 'mobile':
      case 'mobile_money':
        return Icons.smartphone;
      case 'wallet':
      case 'e_wallet':
        return Icons.account_balance_wallet;
      case 'crypto':
        return Icons.currency_bitcoin;
      default:
        return Icons.payment;
    }
  }

  Widget _buildStep5Preferences() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Preferences',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Set your trading preferences to find the best matches',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Preference - V5 Style
                  _buildV5PricePreference(theme),
                  const SizedBox(height: 32),

                  // Trader Preference - V5 Style
                  _buildV5TraderPreference(theme),
                  const SizedBox(height: 32),

                  // Location Preference - V5 Style
                  _buildV5LocationPreference(theme),
                  const SizedBox(height: 32),

                  // Amount Range Preference - V5 Style
                  _buildV5AmountRangePreference(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput(String hint, Function(String) onChanged) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // V5-Style Price Preference Widget
  Widget _buildV5PricePreference(ThemeData theme) {
    final priceOptions = [
      {
        'value': 'best',
        'title': 'Best Price',
        'desc': 'Cheapest offers first',
        'icon': Icons.trending_down
      },
      {
        'value': 'market',
        'title': 'Market Price',
        'desc': 'Close to market value',
        'icon': Icons.timeline
      },
      {
        'value': 'average',
        'title': 'Average Price',
        'desc': 'Balanced pricing',
        'icon': Icons.balance
      },
      {
        'value': 'flexible',
        'title': 'Flexible',
        'desc': 'Show all available offers',
        'icon': Icons.attach_money
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Preference',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...priceOptions.map((option) => _buildPreferenceOption(
              theme,
              option['value'] as String,
              option['title'] as String,
              option['desc'] as String,
              option['icon'] as IconData,
              _pricePreference == option['value'],
              (value) => setState(() => _pricePreference = value),
            )),
      ],
    );
  }

  // V5-Style Trader Preference Widget
  Widget _buildV5TraderPreference(ThemeData theme) {
    final traderOptions = [
      {
        'value': 'any',
        'title': 'Any Trader',
        'desc': 'No trader restrictions',
        'icon': Icons.people
      },
      {
        'value': 'verified',
        'title': 'Verified Only',
        'desc': 'KYC verified traders',
        'icon': Icons.verified_user
      },
      {
        'value': 'experienced',
        'title': 'Experienced',
        'desc': 'High-volume traders',
        'icon': Icons.star
      },
      {
        'value': 'trusted',
        'title': 'Trusted',
        'desc': 'Highly rated traders',
        'icon': Icons.verified
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trader Preference',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...traderOptions.map((option) => _buildPreferenceOption(
              theme,
              option['value'] as String,
              option['title'] as String,
              option['desc'] as String,
              option['icon'] as IconData,
              _traderPreference == option['value'],
              (value) => setState(() => _traderPreference = value),
            )),
      ],
    );
  }

  // Reusable preference option widget matching V5 design
  Widget _buildPreferenceOption(
    ThemeData theme,
    String value,
    String title,
    String description,
    IconData icon,
    bool isSelected,
    Function(String) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isSelected
                      ? theme.primaryColor
                      : theme.primaryColor.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: isSelected ? Colors.white : theme.primaryColor,
                    size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        )),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // V5-Style Location Preference Widget
  Widget _buildV5LocationPreference(ThemeData theme) {
    final locationOptions = [
      {
        'value': 'any',
        'title': 'Any Location',
        'desc': 'No location restrictions',
        'icon': Icons.public
      },
      {
        'value': 'local',
        'title': 'Local Only',
        'desc': 'Same country/region',
        'icon': Icons.location_on
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location Preference',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...locationOptions.map((option) => _buildPreferenceOption(
              theme,
              option['value'] as String,
              option['title'] as String,
              option['desc'] as String,
              option['icon'] as IconData,
              _location == option['value'],
              (value) => setState(() => _location = value),
            )),
      ],
    );
  }

  // V5-Style Amount Range Preference Widget
  Widget _buildV5AmountRangePreference(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount Range (Optional)',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Set minimum and maximum amounts for offers',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
        const SizedBox(height: 16),
        Row(
          children: [
            // Min Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Min Amount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _minAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: _selectedCurrency ?? 'CRYPTO',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _minAmount = double.tryParse(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Max Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Max Amount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maxAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: _selectedCurrency ?? 'CRYPTO',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _maxAmount = double.tryParse(value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Leave empty to see all available amounts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Step 6: Summary & Find Matches (V5-style)
  Widget _buildStep6Summary() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Your Criteria',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Check your trading preferences before finding matches',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSummaryCard(theme),
                  const SizedBox(height: 24),
                  _buildFindMatchesButton(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Summary card showing all selected criteria
  Widget _buildSummaryCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.summarize,
                      color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Your Trading Criteria',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 20),
            _buildSummaryItem(theme, 'Trade Type',
                _selectedTradeType ?? 'Not selected', Icons.swap_horiz),
            _buildSummaryItem(
                theme,
                'Wallet Type',
                _selectedWalletType ?? 'Not selected',
                Icons.account_balance_wallet),
            _buildSummaryItem(theme, 'Cryptocurrency',
                _selectedCurrency ?? 'Not selected', Icons.currency_bitcoin),
            _buildSummaryItem(
                theme,
                'Amount',
                '${double.tryParse(_amountController.text) ?? 0} ${_selectedCurrency ?? 'CRYPTO'}',
                Icons.monetization_on),
            _buildSummaryItem(
                theme,
                'Payment Methods',
                _selectedPaymentMethods.isEmpty
                    ? 'None selected'
                    : '${_selectedPaymentMethods.length} methods',
                Icons.payment),
            _buildSummaryItem(theme, 'Price Preference',
                _getPricePreferenceLabel(), Icons.trending_up),
            _buildSummaryItem(theme, 'Trader Preference',
                _getTraderPreferenceLabel(), Icons.people),
            _buildSummaryItem(
                theme, 'Location', _getLocationLabel(), Icons.location_on),
            if (_minAmount != null || _maxAmount != null)
              _buildSummaryItem(
                  theme, 'Amount Range', _getAmountRangeLabel(), Icons.tune),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      ThemeData theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.primaryColor.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    )),
                Text(value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindMatchesButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: _findMatches,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 12),
            Text('Find Matches',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  // Helper methods for labels
  String _getPricePreferenceLabel() {
    switch (_pricePreference) {
      case 'best':
        return 'Best Price';
      case 'market':
        return 'Market Price';
      case 'average':
        return 'Average Price';
      case 'flexible':
        return 'Flexible';
      default:
        return 'Best Price';
    }
  }

  String _getTraderPreferenceLabel() {
    switch (_traderPreference) {
      case 'any':
        return 'Any Trader';
      case 'verified':
        return 'Verified Only';
      case 'experienced':
        return 'Experienced';
      case 'trusted':
        return 'Trusted';
      default:
        return 'Any Trader';
    }
  }

  String _getLocationLabel() {
    switch (_location) {
      case 'any':
        return 'Any Location';
      case 'local':
        return 'Local Only';
      default:
        return 'Any Location';
    }
  }

  String _getAmountRangeLabel() {
    final minText =
        _minAmount != null ? '${_minAmount?.toStringAsFixed(2)}' : '';
    final maxText =
        _maxAmount != null ? '${_maxAmount?.toStringAsFixed(2)}' : '';
    final currency = _selectedCurrency ?? 'CRYPTO';

    if (_minAmount != null && _maxAmount != null) {
      return '$minText - $maxText $currency';
    } else if (_minAmount != null) {
      return 'Min: $minText $currency';
    } else if (_maxAmount != null) {
      return 'Max: $maxText $currency';
    }
    return 'Any Amount';
  }

  Widget _buildNavigationButtons(CurrencyPriceState currencyState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: theme.textTheme.bodyLarge?.color,
                ),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _validateCurrentStep(currencyState) ? _nextStep : null,
              child: Text(_currentStep == _totalSteps - 2
                  ? 'Review'
                  : _currentStep == _totalSteps - 1
                      ? 'Back'
                      : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // For non-BLoC context, use default validation
    if (!_validateCurrentStepWithDefaultState()) {
      _showValidationError();
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Note: Step 6 has its own Find Matches button, no action needed here
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep(CurrencyPriceState currencyState) {
    switch (_currentStep) {
      case 0: // Trade Type
        return _selectedTradeType != null;
      case 1: // Wallet Type
        return _selectedWalletType != null;
      case 2: // Crypto & Amount
        return _selectedCurrency != null && _isAmountValid(currencyState);
      case 3: // Payment Methods
        return _selectedPaymentMethods.isNotEmpty;
      case 4: // Preferences (including location)
        return true; // All optional
      case 5: // Summary
        return true; // Just a review step
      case 6: // Results
        return true; // Results step - always valid
      default:
        return false;
    }
  }

  // Helper methods for non-BLoC contexts
  bool _isAmountValidWithDefaultState() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (_selectedTradeType == 'BUY') {
      return amount >= 0.001; // Min amount validation
    } else if (_selectedTradeType == 'SELL') {
      return amount > 0; // Basic validation without balance check
    }

    return amount > 0;
  }

  bool _validateCurrentStepWithDefaultState() {
    switch (_currentStep) {
      case 0: // Trade Type
        return _selectedTradeType != null;
      case 1: // Wallet Type
        return _selectedWalletType != null;
      case 2: // Crypto & Amount
        return _selectedCurrency != null && _isAmountValidWithDefaultState();
      case 3: // Payment Methods
        return _selectedPaymentMethods.isNotEmpty;
      case 4: // Preferences (including location)
        return true; // All optional
      case 5: // Summary
        return true; // Just a review step
      case 6: // Results
        return true; // Results step - always valid
      default:
        return false;
    }
  }

  // ✅ Step 7: Results with graceful error handling
  Widget _buildStep7Results() {
    final theme = Theme.of(context);

    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search Results',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Finding the best P2P offers for you',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.textTheme.bodySmall?.color)),
              const SizedBox(height: 24),
              Expanded(
                child: _buildResultsContent(theme, state),
              ),
              const SizedBox(height: 16),
              _buildResultsNavigation(theme, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsContent(ThemeData theme, OffersState state) {
    if (state is OffersLoading) {
      return _buildLoadingState(theme);
    } else if (state is OffersError) {
      return _buildErrorState(theme, state);
    } else if (state is OffersLoaded) {
      if (state.offers.isEmpty) {
        return _buildEmptyState(theme);
      }
      return _buildSuccessState(theme, state);
    }
    return _buildInitialState(theme);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 16),
          Text('Searching for offers...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text('This may take a few seconds',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, OffersError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Search Failed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _getErrorMessage(state.failure),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _retrySearch(),
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No Offers Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text('Try adjusting your search criteria',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _goBackToSearch(),
            icon: Icon(Icons.tune),
            label: Text('Adjust Criteria'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme, OffersLoaded state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Found ${state.offers.length} matching offer${state.offers.length == 1 ? '' : 's'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: state.offers.length,
            itemBuilder: (context, index) {
              final offer = state.offers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    'Price: \$${offer.priceConfig.finalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Amount: ${offer.amountConfig.total.toStringAsFixed(4)} ${offer.currency}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _selectOffer(offer.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Select'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Ready to Search',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text('Tap the search button to find offers',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              )),
        ],
      ),
    );
  }

  Widget _buildResultsNavigation(ThemeData theme, OffersState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _goBackToSearch(),
            icon: Icon(Icons.arrow_back),
            label: Text('Back to Search'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.primaryColor),
              foregroundColor: theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (state is! OffersLoading)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _retrySearch(),
              icon: Icon(Icons.refresh),
              label: Text('Search Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  String _getErrorMessage(dynamic failure) {
    if (failure.toString().contains('p2pReview') ||
        failure.toString().contains('receivedReviews')) {
      return 'Backend Database Issue: The v5 server has a model association bug in the guided-matching endpoint. '
          'It uses wrong alias "receivedReviews" instead of "p2pReviews" defined in user model. '
          'This is a known backend configuration issue that needs server-side fix.';
    } else if (failure.toString().contains('Network')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (failure.toString().contains('ValidationFailure')) {
      return 'Invalid search criteria. Please adjust your preferences.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  void _retrySearch() {
    // Re-trigger the search
    final formData = {
      'tradeType': _selectedTradeType?.toLowerCase(),
      'walletType': _selectedWalletType,
      'cryptocurrency': _selectedCurrency,
      'amount': _amountController.text.trim(),
      'paymentMethods': _selectedPaymentMethods,
      'pricePreference': _pricePreference,
      'traderPreference': _traderPreference,
      'minAmount': _minAmountController.text.trim().isEmpty
          ? ''
          : _minAmountController.text.trim(),
      'maxAmount': _maxAmountController.text.trim().isEmpty
          ? ''
          : _maxAmountController.text.trim(),
      'location': _location,
    };

    context.read<OffersBloc>().add(GuidedMatchingRequested(criteria: formData));
  }

  void _goBackToSearch() {
    setState(() {
      _currentStep = 5; // Go back to summary step
    });
  }

  void _selectOffer(String offerId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected offer: $offerId'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navigate to offer details
          },
        ),
      ),
    );
  }
}
