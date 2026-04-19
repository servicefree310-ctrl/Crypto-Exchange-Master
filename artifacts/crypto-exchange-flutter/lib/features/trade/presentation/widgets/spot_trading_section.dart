import 'package:flutter/material.dart';

import '../widgets/trading_chart.dart';
import '../widgets/order_book_widget.dart';
import '../widgets/trading_form_widget.dart';
import '../widgets/trading_bottom_tabs.dart';

class SpotTradingSection extends StatefulWidget {
  const SpotTradingSection({super.key, required this.symbol});

  final String symbol;

  @override
  State<SpotTradingSection> createState() => _SpotTradingSectionState();
}

class _SpotTradingSectionState extends State<SpotTradingSection> {
  final ValueNotifier<double> _tradingFormHeight = ValueNotifier(0.0);

  @override
  void dispose() {
    _tradingFormHeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart
          TradingChart(symbol: widget.symbol),

          // Order book + form
          ValueListenableBuilder<double>(
            valueListenable: _tradingFormHeight,
            builder: (context, formHeight, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order book (left)
                  Expanded(
                    flex: 2,
                    child: OrderBookWidget(
                      symbol: widget.symbol,
                      expectedHeight: formHeight,
                    ),
                  ),

                  // Trading form (right)
                  Expanded(
                    flex: 3,
                    child: TradingFormWidget(
                      symbol: widget.symbol,
                      onHeightChanged: (height) {
                        if (height != _tradingFormHeight.value) {
                          _tradingFormHeight.value = height;
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom tabs
          SizedBox(
            height: 300,
            child: TradingBottomTabs(symbol: widget.symbol),
          ),
        ],
      ),
    );
  }
}
