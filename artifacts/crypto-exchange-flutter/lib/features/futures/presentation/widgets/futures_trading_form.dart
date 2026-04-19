import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../injection/injection.dart';
import '../bloc/futures_form_bloc.dart';
import '../bloc/futures_header_bloc.dart';
import '../bloc/futures_header_state.dart';

class FuturesTradingForm extends StatefulWidget {
  const FuturesTradingForm({super.key, required this.symbol});

  final String symbol;

  @override
  State<FuturesTradingForm> createState() => _FuturesTradingFormState();
}

class _FuturesTradingFormState extends State<FuturesTradingForm>
    with TickerProviderStateMixin {
  late TabController _sideController;
  late TabController _orderTypeController;
  late FuturesFormBloc _formBloc;

  // Controllers
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _takeProfitController = TextEditingController();
  final _slPercentageController = TextEditingController();
  final _tpPercentageController = TextEditingController();

  // State variables
  double _leverage = 10.0;
  final int _selectedPercentage = 0;
  bool _showRiskManagement = false;
  double? _riskRewardRatio;
  double? _estimatedLoss;
  double? _estimatedProfit;

  // Quick amounts for mobile
  final _quickAmounts = [100, 500, 1000, 5000];
  final _quickSlPercentages = [1, 2, 5, 10];
  final _quickTpPercentages = [2, 5, 10, 20];

  @override
  void initState() {
    super.initState();
    _sideController = TabController(length: 2, vsync: this);
    _orderTypeController = TabController(length: 2, vsync: this);
    _formBloc = getIt<FuturesFormBloc>();

    // Initialize form with symbol
    _formBloc.add(FuturesFormInitialized(symbol: widget.symbol));
  }

  @override
  void dispose() {
    _sideController.dispose();
    _orderTypeController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _slPercentageController.dispose();
    _tpPercentageController.dispose();
    super.dispose();
  }

  void _calculateRiskReward() {
    final currentPrice =
        context.read<FuturesHeaderBloc>().state is FuturesHeaderLoaded
            ? (context.read<FuturesHeaderBloc>().state as FuturesHeaderLoaded)
                .currentPrice
            : 0.0;

    if (currentPrice == 0) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final slPrice = double.tryParse(_stopLossController.text) ?? 0;
    final tpPrice = double.tryParse(_takeProfitController.text) ?? 0;

    if (amount > 0 && slPrice > 0 && tpPrice > 0) {
      final isLong = _sideController.index == 0;

      // Calculate losses and profits
      final slDiff = (currentPrice - slPrice).abs();
      final tpDiff = (tpPrice - currentPrice).abs();

      _estimatedLoss = amount * slDiff * _leverage;
      _estimatedProfit = amount * tpDiff * _leverage;

      // Calculate risk/reward ratio
      if (_estimatedLoss! > 0) {
        _riskRewardRatio = _estimatedProfit! / _estimatedLoss!;
      }

      setState(() {});
    }
  }

  void _handleSlPercentageChange(String value) {
    final percent = double.tryParse(value) ?? 0;
    final currentPrice =
        context.read<FuturesHeaderBloc>().state is FuturesHeaderLoaded
            ? (context.read<FuturesHeaderBloc>().state as FuturesHeaderLoaded)
                .currentPrice
            : 0.0;

    if (percent > 0 && currentPrice > 0) {
      final isLong = _sideController.index == 0;
      final slPrice = isLong
          ? currentPrice * (1 - percent / 100)
          : currentPrice * (1 + percent / 100);

      _stopLossController.text = slPrice.toStringAsFixed(2);
      _calculateRiskReward();
    }
  }

  void _handleTpPercentageChange(String value) {
    final percent = double.tryParse(value) ?? 0;
    final currentPrice =
        context.read<FuturesHeaderBloc>().state is FuturesHeaderLoaded
            ? (context.read<FuturesHeaderBloc>().state as FuturesHeaderLoaded)
                .currentPrice
            : 0.0;

    if (percent > 0 && currentPrice > 0) {
      final isLong = _sideController.index == 0;
      final tpPrice = isLong
          ? currentPrice * (1 + percent / 100)
          : currentPrice * (1 - percent / 100);

      _takeProfitController.text = tpPrice.toStringAsFixed(2);
      _calculateRiskReward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _formBloc,
      child: BlocBuilder<FuturesFormBloc, FuturesFormState>(
        builder: (context, formState) {
          return BlocBuilder<FuturesHeaderBloc, FuturesHeaderState>(
            builder: (context, headerState) {
              if (headerState is! FuturesHeaderLoaded) {
                return _buildLoadingState(context);
              }

              return Container(
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Futures indicator with funding info
                    _buildFuturesIndicator(context, headerState),

                    // Available balance display
                    _buildBalanceDisplay(context, headerState),

                    // Order type tabs (Market/Limit)
                    _buildOrderTypeTabs(context),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Long/Short selector
                          _buildSideSelector(context),
                          const SizedBox(height: 12),

                          // Price input (for limit orders)
                          if (_orderTypeController.index == 1) ...[
                            _buildPriceInput(context, headerState.currentPrice),
                            const SizedBox(height: 12),
                          ],

                          // Amount input with quick buttons
                          _buildAmountInput(context, headerState),
                          const SizedBox(height: 8),
                          _buildQuickAmountButtons(context),
                          const SizedBox(height: 12),

                          // Leverage slider with visual feedback
                          _buildLeverageSlider(context, headerState),
                          const SizedBox(height: 12),

                          // Risk Management section (collapsible)
                          _buildRiskManagementSection(context, headerState),

                          // Position summary
                          _buildPositionSummary(context, headerState),
                          const SizedBox(height: 12),

                          // Submit button
                          _buildSubmitButton(context, headerState),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const FuturesTradingFormShimmer();
  }

  Widget _buildFuturesIndicator(
      BuildContext context, FuturesHeaderLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.zap,
            size: 14,
            color: Colors.amber[600],
          ),
          const SizedBox(width: 6),
          Text(
            'Futures Trading',
            style: context.bodyXS.copyWith(
              color: Colors.amber[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.symbol,
              style: context.bodyXS.copyWith(
                color: Colors.amber[700],
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDisplay(BuildContext context, FuturesHeaderLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.inputBackground.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: context.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: context.bodyXS.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.availableBalance.toStringAsFixed(2)} USDT',
                    style: context.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Funding Rate',
                    style: context.bodyXS.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${state.fundingRate >= 0 ? '+' : ''}${(state.fundingRate * 100).toStringAsFixed(4)}%',
                        style: context.bodyS.copyWith(
                          color: state.fundingRate >= 0
                              ? context.priceUpColor
                              : context.priceDownColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.fundingCountdown,
                        style: context.bodyXS.copyWith(
                          color: context.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeTabs(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.borderColor),
        ),
      ),
      child: TabBar(
        controller: _orderTypeController,
        onTap: (_) {
          HapticFeedback.selectionClick();
          setState(() {});
        },
        indicatorColor: context.priceUpColor,
        indicatorWeight: 2,
        labelColor: context.textPrimary,
        unselectedLabelColor: context.textSecondary,
        labelStyle: context.bodyS.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Market'),
          Tab(text: 'Limit'),
        ],
      ),
    );
  }

  Widget _buildSideSelector(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: TabBar(
        controller: _sideController,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() {});
          _formBloc.add(FuturesFormSideChanged(index == 0 ? 'long' : 'short'));
        },
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: _sideController.index == 0
              ? context.priceUpColor
              : context.priceDownColor,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: context.textSecondary,
        labelStyle: context.bodyS.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Long'),
          Tab(text: 'Short'),
        ],
      ),
    );
  }

  Widget _buildPriceInput(BuildContext context, double currentPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price',
              style: context.bodyXS.copyWith(color: context.textSecondary),
            ),
            GestureDetector(
              onTap: () {
                _priceController.text = currentPrice.toStringAsFixed(2);
                HapticFeedback.selectionClick();
              },
              child: Row(
                children: [
                  Text(
                    'Market: ${PriceFormatter.formatPrice(currentPrice)}',
                    style: context.bodyXS.copyWith(
                      color: context.priceUpColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.sync,
                    size: 12,
                    color: context.priceUpColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  style: context.bodyS,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle:
                        context.bodyS.copyWith(color: context.textTertiary),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0;
                    _formBloc.add(FuturesFormPriceChanged(price));
                  },
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: context.borderColor,
              ),
              // Price adjustment buttons
              Row(
                children: [
                  _buildPriceAdjustButton(context, '-', () {
                    final price =
                        double.tryParse(_priceController.text) ?? currentPrice;
                    final newPrice = price * 0.99;
                    _priceController.text = newPrice.toStringAsFixed(2);
                    _formBloc.add(FuturesFormPriceChanged(newPrice));
                  }),
                  _buildPriceAdjustButton(context, '+', () {
                    final price =
                        double.tryParse(_priceController.text) ?? currentPrice;
                    final newPrice = price * 1.01;
                    _priceController.text = newPrice.toStringAsFixed(2);
                    _formBloc.add(FuturesFormPriceChanged(newPrice));
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAdjustButton(
      BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        HapticFeedback.selectionClick();
      },
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            label,
            style: context.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  label == '+' ? context.priceUpColor : context.priceDownColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context, FuturesHeaderLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (USDT)',
          style: context.bodyXS.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor),
          ),
          child: TextField(
            controller: _amountController,
            style: context.bodyS,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: context.bodyS.copyWith(color: context.textTertiary),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixText: 'USDT',
              suffixStyle:
                  context.bodyXS.copyWith(color: context.textSecondary),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              _formBloc.add(FuturesFormAmountChanged(amount));
              _calculateRiskReward();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButtons(BuildContext context) {
    return Row(
      children: _quickAmounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: amount != _quickAmounts.last ? 4 : 0,
            ),
            child: InkWell(
              onTap: () {
                _amountController.text = amount.toString();
                _formBloc.add(FuturesFormAmountChanged(amount.toDouble()));
                HapticFeedback.selectionClick();
                _calculateRiskReward();
              },
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: context.inputBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.borderColor),
                ),
                child: Center(
                  child: Text(
                    '\$$amount',
                    style: context.bodyXS.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeverageSlider(BuildContext context, FuturesHeaderLoaded state) {
    final maxLeverage = state.maxLeverage ?? 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leverage',
              style: context.bodyXS.copyWith(color: context.textSecondary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_leverage.toStringAsFixed(0)}x',
                style: context.bodyS.copyWith(
                  color: context.priceUpColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: context.priceUpColor,
            inactiveTrackColor: context.borderColor,
            thumbColor: context.priceUpColor,
            overlayColor: context.priceUpColor.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _leverage,
            min: 1,
            max: maxLeverage.toDouble(),
            divisions: maxLeverage - 1,
            onChanged: (value) {
              setState(() {
                _leverage = value;
              });
              _formBloc.add(FuturesFormLeverageChanged(value));
              HapticFeedback.selectionClick();
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1x',
                style: context.bodyXS.copyWith(color: context.textTertiary)),
            Text('${maxLeverage}x',
                style: context.bodyXS.copyWith(color: context.textTertiary)),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskManagementSection(
      BuildContext context, FuturesHeaderLoaded state) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showRiskManagement = !_showRiskManagement;
            });
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _showRiskManagement ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Risk Management',
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Optional',
                    style: context.bodyXS.copyWith(
                      color: context.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 8),
              // Stop Loss
              _buildStopLossSection(context, state),
              const SizedBox(height: 12),
              // Take Profit
              _buildTakeProfitSection(context, state),
              // Risk/Reward Analysis
              if (_riskRewardRatio != null) ...[
                const SizedBox(height: 12),
                _buildRiskRewardAnalysis(context),
              ],
            ],
          ),
          crossFadeState: _showRiskManagement
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildStopLossSection(
      BuildContext context, FuturesHeaderLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.priceDownColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.priceDownColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.shield,
                size: 14,
                color: context.priceDownColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Stop Loss',
                style: context.bodyS.copyWith(
                  color: context.priceDownColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Percentage',
                      style: context.bodyXS.copyWith(
                        color: context.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextField(
                        controller: _slPercentageController,
                        style: context.bodyXS,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: context.bodyXS
                              .copyWith(color: context.textTertiary),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          suffixText: '%',
                          suffixStyle: context.bodyXS
                              .copyWith(color: context.textSecondary),
                        ),
                        onChanged: _handleSlPercentageChange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: context.bodyXS.copyWith(
                        color: context.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextField(
                        controller: _stopLossController,
                        style: context.bodyXS,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: context.bodyXS
                              .copyWith(color: context.textTertiary),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          // Update percentage when price changes
                          final slPrice = double.tryParse(value) ?? 0;
                          if (slPrice > 0 && state.currentPrice > 0) {
                            final isLong = _sideController.index == 0;
                            final percent = isLong
                                ? ((state.currentPrice - slPrice) /
                                        state.currentPrice) *
                                    100
                                : ((slPrice - state.currentPrice) /
                                        state.currentPrice) *
                                    100;
                            _slPercentageController.text =
                                percent.abs().toStringAsFixed(2);
                            _calculateRiskReward();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _quickSlPercentages.map((percent) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: percent != _quickSlPercentages.last ? 4 : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      _slPercentageController.text = percent.toString();
                      _handleSlPercentageChange(percent.toString());
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.priceDownColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: context.priceDownColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$percent%',
                          style: context.bodyXS.copyWith(
                            color: context.priceDownColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_estimatedLoss != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.priceDownColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    size: 12,
                    color: context.priceDownColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated Loss: ',
                    style: context.bodyXS.copyWith(
                      color: context.priceDownColor,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '-\$${_estimatedLoss!.toStringAsFixed(2)}',
                    style: context.bodyXS.copyWith(
                      color: context.priceDownColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTakeProfitSection(
      BuildContext context, FuturesHeaderLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.priceUpColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.priceUpColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.target,
                size: 14,
                color: context.priceUpColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Take Profit',
                style: context.bodyS.copyWith(
                  color: context.priceUpColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Percentage',
                      style: context.bodyXS.copyWith(
                        color: context.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextField(
                        controller: _tpPercentageController,
                        style: context.bodyXS,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: context.bodyXS
                              .copyWith(color: context.textTertiary),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          suffixText: '%',
                          suffixStyle: context.bodyXS
                              .copyWith(color: context.textSecondary),
                        ),
                        onChanged: _handleTpPercentageChange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: context.bodyXS.copyWith(
                        color: context.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextField(
                        controller: _takeProfitController,
                        style: context.bodyXS,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: context.bodyXS
                              .copyWith(color: context.textTertiary),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          // Update percentage when price changes
                          final tpPrice = double.tryParse(value) ?? 0;
                          if (tpPrice > 0 && state.currentPrice > 0) {
                            final isLong = _sideController.index == 0;
                            final percent = isLong
                                ? ((tpPrice - state.currentPrice) /
                                        state.currentPrice) *
                                    100
                                : ((state.currentPrice - tpPrice) /
                                        state.currentPrice) *
                                    100;
                            _tpPercentageController.text =
                                percent.abs().toStringAsFixed(2);
                            _calculateRiskReward();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _quickTpPercentages.map((percent) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: percent != _quickTpPercentages.last ? 4 : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      _tpPercentageController.text = percent.toString();
                      _handleTpPercentageChange(percent.toString());
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.priceUpColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: context.priceUpColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$percent%',
                          style: context.bodyXS.copyWith(
                            color: context.priceUpColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_estimatedProfit != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.target,
                    size: 12,
                    color: context.priceUpColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated Profit: ',
                    style: context.bodyXS.copyWith(
                      color: context.priceUpColor,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '+\$${_estimatedProfit!.toStringAsFixed(2)}',
                    style: context.bodyXS.copyWith(
                      color: context.priceUpColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskRewardAnalysis(BuildContext context) {
    final riskLevel = _getRiskLevel();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskLevel['color'].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: riskLevel['color'].withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.calculator,
                    size: 14,
                    color: riskLevel['color'],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Risk/Reward Analysis',
                    style: context.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: riskLevel['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  riskLevel['level'],
                  style: context.bodyXS.copyWith(
                    color: riskLevel['color'],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ratio',
                    style: context.bodyXS.copyWith(
                      color: context.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '1:${_riskRewardRatio!.toStringAsFixed(2)}',
                    style: context.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_estimatedLoss != null && _estimatedProfit != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Net Potential',
                      style: context.bodyXS.copyWith(
                        color: context.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '\$${(_estimatedProfit! - _estimatedLoss!).toStringAsFixed(2)}',
                      style: context.bodyS.copyWith(
                        color: _estimatedProfit! > _estimatedLoss!
                            ? context.priceUpColor
                            : context.priceDownColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRiskLevel() {
    if (_riskRewardRatio == null) {
      return {
        'level': 'Unknown',
        'color': context.textSecondary,
      };
    }

    if (_riskRewardRatio! >= 3) {
      return {
        'level': 'Low Risk',
        'color': context.priceUpColor,
      };
    } else if (_riskRewardRatio! >= 2) {
      return {
        'level': 'Medium Risk',
        'color': Colors.amber,
      };
    } else {
      return {
        'level': 'High Risk',
        'color': context.priceDownColor,
      };
    }
  }

  Widget _buildPositionSummary(
      BuildContext context, FuturesHeaderLoaded state) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final price = _orderTypeController.index == 0
        ? state.currentPrice
        : (double.tryParse(_priceController.text) ?? state.currentPrice);

    final positionValue = amount * price * _leverage;
    final margin = positionValue / _leverage;

    // Use dynamic fee from market metadata
    final isMarketOrder = _orderTypeController.index == 0;
    final feeRate = isMarketOrder
        ? (state.takerFee ?? 0.0004) // Default to 0.04% if not provided
        : (state.makerFee ?? 0.0004); // Default to 0.04% if not provided
    final fee = positionValue * feeRate;
    final feePercentage = (feeRate * 100).toStringAsFixed(2);

    if (amount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.inputBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, 'Position Value',
              '\$${positionValue.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _buildSummaryRow(
              context, 'Margin Required', '\$${margin.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _buildSummaryRow(context, 'Fees (~$feePercentage%)',
              '\$${fee.toStringAsFixed(2)}'),
          if (_estimatedLoss != null && _estimatedProfit != null) ...[
            const SizedBox(height: 4),
            _buildSummaryRow(
              context,
              'Max Loss/Profit',
              '-\$${_estimatedLoss!.toStringAsFixed(2)} / +\$${_estimatedProfit!.toStringAsFixed(2)}',
              valueColor: context.textPrimary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyXS.copyWith(
            color: context.textSecondary,
          ),
        ),
        Text(
          value,
          style: context.bodyXS.copyWith(
            color: valueColor ?? context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, FuturesHeaderLoaded state) {
    final isLong = _sideController.index == 0;
    final hasAmount = double.tryParse(_amountController.text) != null &&
        double.tryParse(_amountController.text)! > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasAmount
            ? () async {
                HapticFeedback.mediumImpact();

                final orderData = {
                  'symbol': widget.symbol,
                  'side': isLong ? 'LONG' : 'SHORT',
                  'type': _orderTypeController.index == 0 ? 'MARKET' : 'LIMIT',
                  'amount': double.parse(_amountController.text),
                  'leverage': _leverage.toInt(),
                  if (_orderTypeController.index == 1)
                    'price': double.parse(_priceController.text),
                  if (_stopLossController.text.isNotEmpty)
                    'stopLoss': double.parse(_stopLossController.text),
                  if (_takeProfitController.text.isNotEmpty)
                    'takeProfit': double.parse(_takeProfitController.text),
                };

                _formBloc.add(FuturesFormSubmitted(orderData));

                // Clear form after submission
                _amountController.clear();
                _priceController.clear();
                _stopLossController.clear();
                _takeProfitController.clear();
                _slPercentageController.clear();
                _tpPercentageController.clear();
                setState(() {
                  _estimatedLoss = null;
                  _estimatedProfit = null;
                  _riskRewardRatio = null;
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLong ? context.priceUpColor : context.priceDownColor,
          disabledBackgroundColor: context.borderColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLong ? LucideIcons.trendingUp : LucideIcons.trendingDown,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              isLong ? 'Long' : 'Short',
              style: context.bodyS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
