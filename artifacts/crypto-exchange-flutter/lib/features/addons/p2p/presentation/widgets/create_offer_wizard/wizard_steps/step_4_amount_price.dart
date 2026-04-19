import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../../../../core/theme/global_theme_extensions.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 4: Amount & Price Configuration - V5 Compatible Mobile Implementation
class Step4AmountPrice extends StatefulWidget {
  const Step4AmountPrice({
    super.key,
    required this.bloc,
  });

  final CreateOfferBloc bloc;

  @override
  State<Step4AmountPrice> createState() => _Step4AmountPriceState();
}

class _Step4AmountPriceState extends State<Step4AmountPrice>
    with TickerProviderStateMixin {
  // Controllers
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _marginController = TextEditingController(text: '2.0');
  final _minLimitController = TextEditingController(text: '100');
  final _maxLimitController = TextEditingController(text: '5000');

  // State
  PriceModel _priceModel = PriceModel.fixed;
  MarginType _marginType = MarginType.percentage;
  double _marketPrice = 0.0;
  bool _isLoadingPrice = true;
  DateTime _lastUpdated = DateTime.now();
  Timer? _priceUpdateTimer;

  // Tab Controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _startPriceUpdates();
    });
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    _amountController.dispose();
    _priceController.dispose();
    _marginController.dispose();
    _minLimitController.dispose();
    _maxLimitController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _priceModel = PriceModel.fixed;
            break;
          case 1:
            _priceModel = PriceModel.market;
            break;
          case 2:
            _priceModel = PriceModel.margin;
            break;
        }
      });
      _updatePriceConfig();
    }
  }

  void _initializeData() {
    final state = widget.bloc.state;
    if (state is CreateOfferEditing) {
      final formData = state.formData;

      // Initialize for SELL orders with 10% of available balance
      if (state.tradeType == 'SELL' && formData['walletBalance'] != null) {
        final balance = formData['walletBalance'] as double;
        final defaultAmount = balance * 0.1;
        _amountController.text = defaultAmount.toStringAsFixed(8);
        _updateAmountConfig();
      } else if (state.tradeType == 'BUY') {
        // For BUY orders, calculate minimum amount based on min limit and price
        _calculateMinimumAmount();
      }
    }
  }

  void _startPriceUpdates() {
    _fetchMarketPrice();
    // Update price every 30 seconds like V5
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchMarketPrice();
    });
  }

  Future<void> _fetchMarketPrice() async {
    final state = widget.bloc.state;
    if (state is! CreateOfferEditing || state.currency == null) return;

    setState(() => _isLoadingPrice = true);

    try {
      widget.bloc.add(CreateOfferFetchMarketPrice(currency: state.currency!));

      // Listen for the price update
      await Future.delayed(const Duration(seconds: 1));

      final updatedState = widget.bloc.state;
      if (updatedState is CreateOfferEditing) {
        final marketPrice =
            updatedState.formData['marketPrice'] as double? ?? 0.0;
        setState(() {
          _marketPrice = marketPrice;
          _lastUpdated = DateTime.now();
          _isLoadingPrice = false;
        });

        // Update price config with new market price
        _updatePriceConfig();
      }
    } catch (e) {
      setState(() => _isLoadingPrice = false);
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

        final currency = state.currency ?? 'BTC';
        final tradeType = state.tradeType ?? 'BUY';
        final formData = state.formData;
        final availableBalance = formData['walletBalance'] as double?;
        final validationErrors = state.validationErrors ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Amount & Price', style: context.h6),
              const SizedBox(height: 4),
              Text(
                'Specify how much $currency you want to ${tradeType.toLowerCase()} and at what price.',
                style: context.bodyM.copyWith(color: context.textSecondary),
              ),
              const SizedBox(height: 24),

              // Validation Errors
              if (validationErrors.isNotEmpty)
                _buildValidationErrors(validationErrors),

              // Amount Section
              _buildAmountSection(
                  context, currency, tradeType, availableBalance),
              const SizedBox(height: 24),

              // Price Section
              _buildPriceSection(context, currency, tradeType),
              const SizedBox(height: 24),

              // Limits Section
              _buildLimitsSection(context),
              const SizedBox(height: 24),

              // Total Value Summary
              _buildTotalValueSection(context, currency, tradeType),

              // SELL flow info
              if (tradeType == 'SELL') ...[
                const SizedBox(height: 16),
                _buildSellInfo(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildValidationErrors(Map<String, String> errors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined,
                  color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Please fix the following issues:',
                style: context.labelL.copyWith(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.values.map((error) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $error',
                  style: context.bodyS.copyWith(color: Colors.amber.shade700),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, String currency,
      String tradeType, double? availableBalance) {
    final maxAmount = tradeType == 'SELL' && availableBalance != null
        ? availableBalance
        : 10.0;
    final currentAmount = double.tryParse(_amountController.text) ?? 0.0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount ($currency)', style: context.labelL),
            const SizedBox(height: 12),

            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateAmountConfig(),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: currency,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Select Slider
            Text('Quick Select', style: context.labelM),
            const SizedBox(height: 8),
            Slider(
              value: currentAmount.clamp(0.0, maxAmount),
              max: maxAmount,
              divisions: 100,
              onChanged: (value) {
                _amountController.text = value.toStringAsFixed(8);
                _updateAmountConfig();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 $currency', style: context.bodyS),
                Text('${(maxAmount / 2).toStringAsFixed(4)} $currency',
                    style: context.bodyS),
                Text('${maxAmount.toStringAsFixed(4)} $currency',
                    style: context.bodyS),
              ],
            ),

            // Available Balance for SELL
            if (tradeType == 'SELL' && availableBalance != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: context.textSecondary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Available: ${availableBalance.toStringAsFixed(8)} $currency',
                      style:
                          context.bodyS.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(
      BuildContext context, String currency, String tradeType) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Model', style: context.labelL),
            const SizedBox(height: 12),

            // Price Model Tabs
            TabBar(
              controller: _tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: context.colors.primary,
                  width: 2,
                ),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              labelColor: context.colors.primary,
              unselectedLabelColor: context.textSecondary,
              labelStyle: context.labelM.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  context.labelM.copyWith(fontWeight: FontWeight.w400),
              tabs: const [
                Tab(text: 'Fixed'),
                Tab(text: 'Market'),
                Tab(text: 'Margin'),
              ],
            ),
            const SizedBox(height: 16),

            // Price Model Content
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFixedPriceTab(context, currency),
                  _buildMarketPriceTab(context),
                  _buildMarginPriceTab(context, currency, tradeType),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedPriceTab(BuildContext context, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price per $currency (USD)', style: context.labelM),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _updatePriceConfig(),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set a specific price that won\'t change with market fluctuations.',
          style: context.bodyS.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMarketPriceTab(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Market Price', style: context.labelM),
          const SizedBox(height: 12),
          if (_isLoadingPrice)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Loading price...', style: context.bodyM),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${_marketPrice.toStringAsFixed(2)}',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last updated: ${_lastUpdated.toString().substring(11, 19)}',
                  style: context.bodyS.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            'Your offer will use live market price from data providers.',
            style: context.bodyS.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginPriceTab(
      BuildContext context, String currency, String tradeType) {
    final calculatedPrice = _calculateMarginPrice();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Margin Type Selection
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Radio<MarginType>(
                    value: MarginType.percentage,
                    groupValue: _marginType,
                    onChanged: (value) {
                      setState(() => _marginType = value!);
                      _updatePriceConfig();
                    },
                  ),
                  Text('Percentage (%)', style: context.bodyS),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Radio<MarginType>(
                    value: MarginType.fixed,
                    groupValue: _marginType,
                    onChanged: (value) {
                      setState(() => _marginType = value!);
                      _updatePriceConfig();
                    },
                  ),
                  Text('Fixed Amount (\$)', style: context.bodyS),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Margin Value Input
        TextFormField(
          controller: _marginController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _updatePriceConfig(),
          decoration: InputDecoration(
            labelText: _marginType == MarginType.percentage
                ? 'Margin Percentage'
                : 'Margin Amount',
            hintText: _marginType == MarginType.percentage ? '2.0' : '100',
            suffixText: _marginType == MarginType.percentage ? '%' : 'USD',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Calculated Price Display
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Calculated Price:', style: context.labelM),
                  Text(
                    '\$${calculatedPrice.toStringAsFixed(2)}',
                    style: context.bodyL.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Based on current market conditions',
                style: context.bodyS.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimitsSection(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trading Limits', style: context.labelL),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minimum Limit (USD)', style: context.labelM),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _minLimitController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _updateLimits(),
                        decoration: InputDecoration(
                          hintText: '100',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maximum Limit (USD)', style: context.labelM),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _maxLimitController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _updateLimits(),
                        decoration: InputDecoration(
                          hintText: '5000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalValueSection(
      BuildContext context, String currency, String tradeType) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final price = _getCurrentPrice();
    final totalValue = amount * price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Value', style: context.labelL),
              Text(
                '\$${totalValue.toStringAsFixed(2)}',
                style: context.h6.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'This is the total amount in USD for this trade.',
            style: context.bodyS.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSellInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'When selling currency, your amount will be held in escrow until the buyer completes payment.',
              style: context.bodyS.copyWith(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  double _calculateMarginPrice() {
    final marginValue = double.tryParse(_marginController.text) ?? 0.0;
    final tradeType =
        (widget.bloc.state as CreateOfferEditing).tradeType ?? 'BUY';

    if (_marginType == MarginType.percentage) {
      // For BUY: price above market, for SELL: price below market
      final multiplier = tradeType == 'BUY'
          ? 1 + (marginValue / 100)
          : 1 - (marginValue / 100);
      return _marketPrice * multiplier;
    } else {
      // Fixed amount: add or subtract from market price
      return tradeType == 'BUY'
          ? _marketPrice + marginValue
          : _marketPrice - marginValue;
    }
  }

  double _getCurrentPrice() {
    switch (_priceModel) {
      case PriceModel.fixed:
        return double.tryParse(_priceController.text) ?? 0.0;
      case PriceModel.market:
        return _marketPrice;
      case PriceModel.margin:
        return _calculateMarginPrice();
    }
  }

  void _calculateMinimumAmount() {
    final price = _getCurrentPrice();
    if (price > 0) {
      final minLimit = double.tryParse(_minLimitController.text) ?? 100.0;
      final minAmount = (minLimit / price) * 1.05; // 5% buffer
      _amountController.text = minAmount.toStringAsFixed(8);
      _updateAmountConfig();
    }
  }

  void _updateAmountConfig() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final minLimit = double.tryParse(_minLimitController.text) ?? 0.0;
    final maxLimit = double.tryParse(_maxLimitController.text) ?? 0.0;

    final state = widget.bloc.state;
    if (state is CreateOfferEditing) {
      final availableBalance = state.formData['walletBalance'] as double?;

      widget.bloc.add(CreateOfferSectionUpdated(
        section: 'amountConfig',
        data: {
          'total': amount,
          'min': minLimit,
          'max': maxLimit,
          'availableBalance': availableBalance,
        },
      ));
    }
  }

  void _updatePriceConfig() {
    final currentPrice = _getCurrentPrice();

    widget.bloc.add(CreateOfferSectionUpdated(
      section: 'priceConfig',
      data: {
        'model': _priceModel.name.toUpperCase(),
        'value': _priceModel == PriceModel.fixed
            ? (double.tryParse(_priceController.text) ?? 0.0)
            : (double.tryParse(_marginController.text) ?? 0.0),
        'marketPrice': _marketPrice,
        'finalPrice': currentPrice,
        'marginType': _marginType.name,
      },
    ));
  }

  void _updateLimits() {
    widget.bloc.add(CreateOfferFieldUpdated(
      field: 'minLimit',
      value: _minLimitController.text,
    ));
    widget.bloc.add(CreateOfferFieldUpdated(
      field: 'maxLimit',
      value: _maxLimitController.text,
    ));
    _updateAmountConfig();
  }
}

// Enums
enum PriceModel { fixed, market, margin }

enum MarginType { percentage, fixed }
