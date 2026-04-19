import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/trading_form_bloc.dart';
import '../../../wallet/presentation/bloc/spot_deposit_bloc.dart';
import '../../../wallet/presentation/pages/spot_deposit_page.dart';

class TradingFormWidget extends StatefulWidget {
  final String symbol;
  final Function(double height)? onHeightChanged;

  const TradingFormWidget({
    super.key,
    required this.symbol,
    this.onHeightChanged,
  });

  @override
  State<TradingFormWidget> createState() => _TradingFormWidgetState();
}

class _TradingFormWidgetState extends State<TradingFormWidget>
    with TickerProviderStateMixin {
  final GlobalKey _formKey = GlobalKey();
  late TradingFormBloc _formBloc;

  @override
  void initState() {
    super.initState();
    _formBloc = getIt<TradingFormBloc>()
      ..add(TradingFormInitialized(symbol: widget.symbol));
  }

  @override
  void didUpdateWidget(TradingFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _formBloc.add(TradingFormInitialized(symbol: widget.symbol));
    }
  }

  @override
  void dispose() {
    _formBloc.close();
    super.dispose();
  }

  void _measureHeight() {
    if (widget.onHeightChanged != null && _formKey.currentContext != null) {
      final RenderBox renderBox =
          _formKey.currentContext!.findRenderObject() as RenderBox;
      widget.onHeightChanged!(renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _formBloc,
      child: BlocConsumer<TradingFormBloc, TradingFormState>(
        listenWhen: (previous, current) => current is TradingFormMessage,
        buildWhen: (previous, current) => current is! TradingFormMessage,
        listener: (context, state) {
          if (state is TradingFormMessage) {
            final color =
                state.isError ? context.priceDownColor : context.priceUpColor;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: color,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          // Schedule height measurement after state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _measureHeight();
          });

          return Container(
            key: _formKey,
            padding:
                const EdgeInsets.only(left: 2, right: 8, top: 5, bottom: 8),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
            ),
            child: _buildFormContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, TradingFormState state) {
    if (state is TradingFormLoading) {
      return _buildSkeletonLoader(context);
    }

    if (state is TradingFormError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: context.priceDownColor, size: 20),
            const SizedBox(height: 4),
            Text(
              state.message,
              style: TextStyle(color: context.priceDownColor, fontSize: 10),
            ),
          ],
        ),
      );
    }

    if (state is TradingFormLoaded) {
      return _buildLoadedForm(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadedForm(BuildContext context, TradingFormLoaded state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buy/Sell tabs
        _buildBuySellTabs(context, state),
        const SizedBox(height: 8),

        // Order type dropdown
        _buildCustomDropdown(context, state),
        const SizedBox(height: 8),

        // Price input (only for limit and stop orders)
        if (state.orderType == OrderType.stop) ...[
          _buildStopPriceInput(context, state),
          const SizedBox(height: 8),
          _buildPriceInput(context, state), // limit price optional
          const SizedBox(height: 8),
        ] else if (state.orderType == OrderType.limit) ...[
          _buildPriceInput(context, state),
          const SizedBox(height: 8),
        ],

        // Quantity input
        _buildQuantityInput(context, state),
        const SizedBox(height: 8),

        // Percentage buttons
        _buildPercentageButtons(context, state),
        const SizedBox(height: 8),

        // Amount section
        _buildAmountSection(context, state),
        const SizedBox(height: 8),

        // Available balance
        _buildAvailableBalance(context, state),
        const SizedBox(height: 12),

        // Buy/Sell button
        _buildActionButton(context, state),
      ],
    );
  }

  Widget _buildBuySellTabs(BuildContext context, TradingFormLoaded state) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Buy tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!state.isBuy) {
                  _formBloc.add(
                    const TradingFormTabChanged(isBuy: true),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      state.isBuy ? context.priceUpColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      color: state.isBuy ? Colors.black : context.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // Sell tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (state.isBuy) {
                  _formBloc.add(
                    const TradingFormTabChanged(isBuy: false),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !state.isBuy
                      ? context.priceDownColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Sell',
                    style: TextStyle(
                      color:
                          !state.isBuy ? Colors.white : context.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown(BuildContext context, TradingFormLoaded state) {
    return Column(
      children: [
        // Dropdown button
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: context.inputBackground,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: OrderType.values.map((type) {
                  final isSelected = state.orderType == type;
                  return ListTile(
                    dense: true,
                    title: Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? context.textPrimary
                            : context.textSecondary,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      _formBloc
                          .add(TradingFormOrderTypeChanged(orderType: type));
                      Navigator.pop(context);
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
            );
            HapticFeedback.selectionClick();
          },
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  state.orderType.displayName,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: context.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInput(BuildContext context, TradingFormLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Limit(${state.quoteCurrency})',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: context.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          key: ValueKey(state.formattedPrice),
                          initialValue: state.formattedPrice,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (value) {
                            final price = double.tryParse(value) ?? 0.0;
                            _formBloc
                                .add(TradingFormPriceChanged(price: price));
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final current = state;
                        final newPrice = (current.price - 0.0001)
                            .clamp(0.0, double.infinity);
                        _formBloc.add(TradingFormPriceChanged(price: newPrice));
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: context.inputBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.remove,
                            color: context.textPrimary, size: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final current = state;
                        final newPrice = current.price + 0.0001;
                        _formBloc.add(TradingFormPriceChanged(price: newPrice));
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: state.isBuy
                              ? context.priceUpColor
                              : context.priceDownColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '≈${(state.price * 20).toStringAsFixed(2)} USD',
          style: TextStyle(
            color: context.textTertiary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStopPriceInput(BuildContext context, TradingFormLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stop (${state.quoteCurrency})',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: context.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          key: ValueKey(state.formattedStopPrice),
                          initialValue: state.formattedStopPrice,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (value) {
                            final sp = double.tryParse(value) ?? 0.0;
                            _formBloc.add(
                                TradingFormStopPriceChanged(stopPrice: sp));
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final current = state;
                        final newVal = (current.stopPrice - 0.0001)
                            .clamp(0.0, double.infinity);
                        _formBloc.add(
                            TradingFormStopPriceChanged(stopPrice: newVal));
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: context.inputBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.remove,
                            color: context.textPrimary, size: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final current = state;
                        final newVal = current.stopPrice + 0.0001;
                        _formBloc.add(
                            TradingFormStopPriceChanged(stopPrice: newVal));
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: context.inputBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.add,
                            color: context.textPrimary, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityInput(BuildContext context, TradingFormLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity(${state.baseCurrency})',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextFormField(
                    key: ValueKey(state.formattedQuantity),
                    initialValue:
                        state.quantity > 0 ? state.formattedQuantity : '',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 0.0;
                      _formBloc.add(
                        TradingFormQuantityChanged(quantity: quantity),
                      );
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final current = state;
                  final newQuantity = (current.quantity - 0.0001)
                      .clamp(0.0, double.infinity);
                  _formBloc
                      .add(TradingFormQuantityChanged(quantity: newQuantity));
                },
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      Icon(Icons.remove, color: context.textPrimary, size: 12),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final current = state;
                  final newQuantity = current.quantity + 0.0001;
                  _formBloc
                      .add(TradingFormQuantityChanged(quantity: newQuantity));
                },
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.add, color: context.textPrimary, size: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageButtons(
      BuildContext context, TradingFormLoaded state) {
    return Row(
      children: [25, 50, 75, 100].map((percentage) {
        final isSelected = state.selectedPercentage == percentage;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: percentage == 100 ? 0 : 4),
            child: GestureDetector(
              onTap: () {
                _formBloc.add(
                  TradingFormPercentageSelected(percentage: percentage),
                );
              },
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.inputBackground
                      : context.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isSelected ? context.borderColor : context.borderColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isSelected
                          ? context.textPrimary
                          : context.textSecondary,
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
    );
  }

  Widget _buildAmountSection(BuildContext context, TradingFormLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amount',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              state.quoteCurrency,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor, width: 1),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '≈${state.formattedTotal} USD',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableBalance(BuildContext context, TradingFormLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Avail.',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 10,
          ),
        ),
        Row(
          children: [
            Text(
              '${state.formattedBalance} ${state.isBuy ? state.quoteCurrency : state.baseCurrency}',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<SpotDepositBloc>(),
                      child: const SpotDepositPage(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: state.isBuy
                      ? context.priceUpColor
                      : context.priceDownColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, TradingFormLoaded state) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: (state.quantity > 0)
            ? () {
                _formBloc.add(const TradingFormOrderPlaced());
                HapticFeedback.lightImpact();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              state.isBuy ? context.priceUpColor : context.priceDownColor,
          foregroundColor: state.isBuy ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Center(
          child: Text(
            '${state.isBuy ? 'Buy' : 'Sell'} ${state.baseCurrency}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.inputBackground,
      highlightColor: context.borderColor,
      period: const Duration(milliseconds: 1200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buy / Sell tabs row
          Row(
            children: [
              _skeletonRect(flex: 1, height: 32),
              const SizedBox(width: 4),
              _skeletonRect(flex: 1, height: 32),
            ],
          ),
          const SizedBox(height: 8),

          // Order type dropdown
          _skeletonBox(height: 34),
          const SizedBox(height: 8),

          // Price input row
          Container(width: 60, height: 10, decoration: _skeletonDecoration),
          const SizedBox(height: 4),
          _skeletonBox(height: 34),
          const SizedBox(height: 8),

          // Quantity input row
          Container(width: 80, height: 10, decoration: _skeletonDecoration),
          const SizedBox(height: 4),
          _skeletonBox(height: 34),
          const SizedBox(height: 8),

          // Percentage buttons row (4 buttons)
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 24,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                  decoration: _skeletonDecoration,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Amount section
          Container(width: 60, height: 10, decoration: _skeletonDecoration),
          const SizedBox(height: 4),
          _skeletonBox(height: 34),
          const SizedBox(height: 8),

          // Available balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 40, height: 10, decoration: _skeletonDecoration),
              Container(width: 80, height: 10, decoration: _skeletonDecoration),
            ],
          ),
          const SizedBox(height: 12),

          // Buy/Sell button
          _skeletonBox(height: 36),
        ],
      ),
    );
  }

  Widget _skeletonBox({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: _skeletonDecoration,
    );
  }

  // Common decoration for skeleton rectangles
  final BoxDecoration _skeletonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
  );

  // Helper for flexible skeleton within Row
  Widget _skeletonRect({required int flex, required double height}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: height,
        decoration: _skeletonDecoration,
      ),
    );
  }
}
