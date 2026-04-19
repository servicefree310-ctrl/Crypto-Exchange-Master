import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../bloc/trades/trade_execution_bloc.dart';
import '../../bloc/trades/trade_execution_event.dart';
import '../../bloc/trades/trade_execution_state.dart';

class BuyTradeBottomSheet extends StatefulWidget {
  const BuyTradeBottomSheet({
    super.key,
    required this.offer,
    required this.onTradeInitiated,
  });

  final dynamic offer;
  final Function(String tradeId) onTradeInitiated;

  @override
  State<BuyTradeBottomSheet> createState() => _BuyTradeBottomSheetState();
}

class _BuyTradeBottomSheetState extends State<BuyTradeBottomSheet> {
  late TextEditingController _amountController;
  double? buyAmount;
  double? totalCost;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      setState(() {
        buyAmount = amount;
        totalCost = amount * 50000; // Mock price
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: BlocListener<TradeExecutionBloc, TradeExecutionState>(
            listener: (context, state) {
              if (state is TradeExecutionSuccess && state.trade != null) {
                widget.onTradeInitiated(state.trade!.id);
              }
            },
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: context.buyColor),
                      const SizedBox(width: 12),
                      Text(
                        'Buy Crypto',
                        style: context.h6.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount to Buy',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (totalCost != null)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.buyColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('You will pay:'),
                                    Text(
                                      '\$${totalCost!.toStringAsFixed(2)}',
                                      style: context.bodyL.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: context.buyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                buyAmount != null ? _initiateTrade : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.buyColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Buy Crypto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _initiateTrade() {
    if (buyAmount == null || widget.offer == null) return;

    // Call the trade creation with actual offer data
    context.read<TradeExecutionBloc>().add(
          TradeInitiateRequested(
            offerId: widget.offer!.id,
            amount: buyAmount!,
            paymentMethodId:
                'selected-payment-method-id', // Should be selected from offer's payment methods
            notes: null, // Optional notes for the trade
          ),
        );
  }
}
